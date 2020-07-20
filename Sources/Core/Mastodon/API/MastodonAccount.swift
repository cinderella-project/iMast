//
//  MastodonAccount.swift
//  iMast
//
//  Created by rinsuki on 2018/01/09.
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
//

import Foundation
import Hydra

public struct MastodonAccount: Codable, EmojifyProtocol {
    public let id: MastodonID
    public let name: String
    public let screenName: String
    public let isLocked: Bool
    public let createdAt: Date
    public let followersCount: Int
    public let followingCount: Int
    public let postsCount: Int
    public let bio: String
    public let url: String
    public let avatarUrl: String
    public let headerUrl: String

    public let acct: String
    let moved: IndirectBox<MastodonAccount>?
    
    public let niconicoUrl: URL?
    
    // for pawoo
    public let oauthAuthentications: [MastodonAccountOAuthAuthenticate]?
    
    public let emojis: [MastodonCustomEmoji]?
    public let profileEmojis: [MastodonCustomEmoji]?
    enum CodingKeys: String, CodingKey {
        case id
        case name = "display_name"
        case screenName = "username"
        case isLocked = "locked"
        case createdAt = "created_at"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case postsCount = "statuses_count"
        case bio = "note"
        case url
        case avatarUrl = "avatar_static"
        case headerUrl = "header_static"

        case acct
        case moved
        
        case niconicoUrl = "nico_url"
        case oauthAuthentications = "oauth_authentications"
        
        case emojis
        case profileEmojis = "profile_emojis"
    }
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

extension MastodonAccount: Hashable {
    public static func == (lhs: MastodonAccount, rhs: MastodonAccount) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct MastodonAccountOAuthAuthenticate: Codable {
    public let provider: String
    public let uid: String
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

public enum MastodonFollowFetchType: String {
    case following
    case followers
}

struct MastodonFollowList {
    var accounts: [MastodonAccount]
    var prev: MastodonID?
    var next: MastodonID?
    
}

extension MastodonUserToken {
    public func verifyCredentials() -> Promise<MastodonAccount> {
        return self.get("accounts/verify_credentials").then { res -> MastodonAccount in
            return try MastodonAccount.decode(json: res)
        }
    }
    public func getAccount(id: MastodonID) -> Promise<MastodonAccount> {
        return self.get("accounts/"+id.string).then { res -> MastodonAccount in
            return try MastodonAccount.decode(json: res)
        }
    }
}

extension MastodonEndpoint {
    public struct GetFollows: MastodonEndpointProtocol {
        public typealias Response = MastodonEndpointResponseWithPaging<[MastodonAccount]>
        
        public var endpoint: String {
            return "/api/v1/accounts/\(target.string)/\(type.rawValue)"
        }
        public let method = "GET"
        public var query: [URLQueryItem] {
            var q = [URLQueryItem]()
            paging?.addToQuery(&q)
            return q
        }
        public let body: Data? = nil
        
        public var target: MastodonID
        public var type: MastodonFollowFetchType
        public var paging: MastodonPagingOption?
        
        public init(target: MastodonID, type: MastodonFollowFetchType, paging: MastodonPagingOption? = nil) {
            self.target = target
            self.type = type
            self.paging = paging
        }
    }
    
    public enum FollowRequests {
        public struct List: MastodonEndpointProtocol {
            public typealias Response = MastodonEndpointResponseWithPaging<[MastodonAccount]>
            
            public let endpoint = "/api/v1/follow_requests"
            public let method = "GET"
            public var query: [URLQueryItem] {
                var q = [URLQueryItem]()
                paging?.addToQuery(&q)
                return q
            }
            
            public var paging: MastodonPagingOption?
            
            public init(paging: MastodonPagingOption? = nil) {
                self.paging = paging
            }
        }
        
        public struct Judge: MastodonEndpointProtocol {
            public typealias Response = MastodonAccountRelationship
            
            public enum JudgeType: String {
                case authorize
                case reject
            }
            
            public var endpoint: String { "/api/v1/follow_requests/\(target.id.string)/\(judge.rawValue)" }
            public let method = "POST"
            
            public var target: MastodonAccount
            public var judge: JudgeType
            
            public init(target: MastodonAccount, judge: JudgeType) {
                self.target = target
                self.judge = judge
            }
        }
    }
}
