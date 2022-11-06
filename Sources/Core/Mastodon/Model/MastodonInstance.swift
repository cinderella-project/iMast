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
//import Alamofire

var mastodonInstanceInfoCache: [String: JSON] = [:]

#if os(macOS)
public let defaultAppName = "iMast (macOS)"
private let website = "https://cinderella-project.github.io/iMast/mac/"
#else
public let defaultAppName = "iMast"
private let website = "https://cinderella-project.github.io/iMast/"
#endif

public class MastodonInstance {
    public var hostName: String
    public var name: String?
    var description: String?
    var email: String?
    public var url: URL {
        return URL(string: "https://\(self.hostName)")!
    }
        
    public init(hostName: String = "mastodon.social") {
        self.hostName = hostName.replacing(/.+@/, with: "").lowercased()
    }
    
    public func getInfo() async throws -> JSON {
        if let cache = mastodonInstanceInfoCache[self.hostName] {
            return cache
        }
        var request = try URLRequest(url: URL(string: "https://\(hostName)/api/v1/instance")!, method: .get)
        request.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
        let data = try await MastodonAPI.handleHTTPError(URLSession.shared.data(for: request))
        let json = try JSON(data: data)
        
        self.name = json["name"].string
        self.description = json["description"].string
        self.email = json["email"].string
        mastodonInstanceInfoCache[self.hostName] = json
        return json
    }
    
    public func createApp(name: String = defaultAppName, redirect_uri: String = "imast://callback/") async throws -> MastodonApp {
        let params = [
            "client_name": name,
            "scopes": "read write follow",
            "redirect_uris": redirect_uri,
            "website": website,
        ]
        var request = try URLRequest(url: URL(string: "https://\(hostName)/api/v1/apps")!, method: .post)
        request.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(params)
        let data = try await MastodonAPI.handleHTTPError(URLSession.shared.data(for: request))
        let json = try JSON(data: data)
        
        return MastodonApp(instance: self, info: json, name: name, redirectUri: redirect_uri)
    }
}
