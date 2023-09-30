//
//  MastodonEndpoint.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/03/09.
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

public enum MastodonEndpoint {
}

extension MastodonEndpoint {
    public struct CreateReport: MastodonEndpointProtocol, Encodable {
        public init(
            account: MastodonAccount,
            comment: String = "",
            forward: Bool = false,
            posts: [MastodonPost]
        ) {
            self.accountId = account.id
            self.comment = comment
            self.forward = forward
            self.postIds = posts.map { $0.id }
        }
        
        public typealias Response = DecodableVoid
        public let endpoint = "/api/v1/reports"
        public let method = "POST"
        
        public var accountId: MastodonID
        public var comment: String = ""
        public var forward: Bool = false
        public var postIds: [MastodonID]
        
        enum CodingKeys: String, CodingKey {
            case accountId = "account_id"
            case comment
            case forward
            case postIds = "status_ids"
        }
    }
    
    public struct VerifyCredentials: MastodonEndpointProtocol {
        public struct Response: MastodonEndpointResponse, Decodable {
            let displayName: String
            let screenName: String
            let avatar: String
            public let source: Source?
            
            public struct Source: Decodable {
                public let privacy: String
            }
            
            enum CodingKeys: String, CodingKey {
                case displayName = "display_name"
                case screenName = "username"
                case avatar = "avatar_static"
                case source
            }
        }
        public let endpoint = "/api/v1/accounts/verify_credentials"
        public let method = "GET"
    }
}
