//
//  MastodonAccountRelationship.swift
//  iMast
//
//  Created by rinsuki on 2018/01/12.
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

public struct MastodonAccountRelationship: Codable, MastodonEndpointResponse {
    let id: MastodonID
    public let following: Bool
    public var showing_reblogs: Bool {
        return self.showing_reblogs_ ?? self.following
    }
    private let showing_reblogs_: Bool?
    public let followed_by: Bool
    public let blocking: Bool
    public let muting: Bool
    public var muting_notifications: Bool {
        return self.muting_notifications_ ?? self.muting
    }
    private let muting_notifications_: Bool?
    public let requested: Bool
    public let domain_blocking: Bool = false
    enum CodingKeys: String, CodingKey {
        case id
        case following
        case showing_reblogs_ = "showing_reblogs"
        case followed_by
        case blocking
        case muting
        case muting_notifications_ = "muting_notifications"
        case requested
        case domain_blocking
    }
}

extension MastodonUserToken {
    public func getRelationship(_ accounts: [MastodonAccount]) -> Promise<[MastodonAccountRelationship]> {
        return self.getRelationship(ids: accounts.map({$0.id}))
    }
    public func getRelationship(ids: [MastodonID]) -> Promise<[MastodonAccountRelationship]> {
        return self.get("accounts/relationships", params: ["id": ids.map({$0.raw})]).then { res in
            return try res.arrayValue.map {
                try MastodonAccountRelationship.decode(json: $0)
            }
        }
    }
    
    public func follow(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/follow").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    public func unfollow(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/unfollow").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    
    public func mute(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/mute").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    public func unmute(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/unmute").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    
    public func block(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/block").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    public func unblock(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/unblock").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
}
