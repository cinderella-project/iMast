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

var mastodonInstanceInfoCache: [String: MastodonInstance.Info] = [:]

#if os(macOS)
public let defaultAppName = "iMast (macOS)"
private let website = "https://cinderella-project.github.io/iMast/mac/"
#else
public let defaultAppName = "iMast"
private let website = "https://cinderella-project.github.io/iMast/"
#endif

public class MastodonInstance {
    public struct Info: Codable {
        public let version: String
        public let urls: Urls
        
        public struct Urls: Codable {
            public let streamingApi: String
            
            enum CodingKeys: String, CodingKey {
                case streamingApi = "streaming_api"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case version
            case urls
        }
    }
    
    struct CreateAppResponse: Codable {
        let clientId: String
        let clientSecret: String
        
        enum CodingKeys: String, CodingKey {
            case clientId = "client_id"
            case clientSecret = "client_secret"
        }
    }
    
    public var hostName: String
    public var url: URL {
        return URL(string: "https://\(self.hostName)")!
    }
        
    public init(hostName: String = "mastodon.social") {
        self.hostName = hostName.replacing(/.+@/, with: "").lowercased()
    }
    
    public func getInfo() async throws -> Info {
        if let cache = mastodonInstanceInfoCache[self.hostName] {
            return cache
        }
        var request = try URLRequest(url: URL(string: "https://\(hostName)/api/v1/instance")!, method: .get)
        request.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
        let data = try await MastodonAPI.handleHTTPError(URLSession.shared.data(for: request))
        let json = try JSONDecoder.forMastodonAPI.decode(Info.self, from: data)
        
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
        let json = try JSONDecoder.forMastodonAPI.decode(CreateAppResponse.self, from: data)
        
        return MastodonApp(instance: self, info: json, name: name, redirectUri: redirect_uri)
    }
}
