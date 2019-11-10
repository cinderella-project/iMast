//
//  MastodonInstance.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/08/24.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2019 rinsuki and other contributors.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import SwiftyJSON
import Hydra
import Alamofire

var mastodonInstanceInfoCache: [String: JSON] = [:]

public class MastodonInstance {
    public var hostName: String
    public var name: String?
    var description: String?
    var email: String?
    public var url: URL {
        return URL(string: "https://\(self.hostName)")!
    }
        
    public init(hostName: String = "mastodon.social") {
        self.hostName = hostName.pregReplace(pattern: ".+\\@", with: "").lowercased()
    }
    
    public func getInfo() -> Promise<JSON> {
        return Promise<JSON> { resolve, reject, _ in
            if let cache = mastodonInstanceInfoCache[self.hostName] {
                resolve(cache)
                return
            }
            Alamofire.request("https://\(self.hostName)/api/v1/instance").responseJSON { res in
                // print(res)
                if let error = res.error {
                    reject(error)
                    return
                }
                if res.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                let json = JSON(res.result.value!)
                self.name = json["name"].string
                self.description = json["description"].string
                self.email = json["email"].string
                mastodonInstanceInfoCache[self.hostName] = json
                resolve(json)
            }
        }
    }
    
    public func createApp(name: String = "iMast", redirect_uri: String = "imast://callback/") -> Promise<MastodonApp> {
        return Promise<MastodonApp> { resolve, reject, _ in
            let params = [
                "client_name": name,
                "scopes": "read write follow",
                "redirect_uris": redirect_uri,
                "website": "https://cinderella-project.github.io/iMast/",
            ]
            Alamofire.request("https://\(self.hostName)/api/v1/apps", method: .post, parameters: params).responseJSON { res in
                if let error = res.error {
                    reject(error)
                    return
                }
                if res.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                let json = JSON(res.result.value!)
                print(json)
                resolve(MastodonApp(instance: self, info: json, name: name, redirectUri: redirect_uri))
            }
        }
    }
}
