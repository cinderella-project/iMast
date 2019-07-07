//
//  MastodonAccountRelationship.swift
//  iMast
//
//  Created by user on 2018/01/12.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Hydra

struct MastodonAccountRelationship: Codable {
    let id: MastodonID
    let following: Bool
    var showing_reblogs: Bool {
        return self.showing_reblogs_ ?? self.following
    }
    let showing_reblogs_: Bool?
    let followed_by: Bool
    let blocking: Bool
    let muting: Bool
    var muting_notifications: Bool {
        return self.muting_notifications_ ?? self.muting
    }
    let muting_notifications_: Bool?
    let requested: Bool
    let domain_blocking: Bool = false
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
    func getRelationship(_ accounts: [MastodonAccount]) -> Promise<[MastodonAccountRelationship]> {
        return self.getRelationship(ids: accounts.map({$0.id}))
    }
    func getRelationship(ids: [MastodonID]) -> Promise<[MastodonAccountRelationship]> {
        return self.get("accounts/relationships", params: ["id": ids.map({$0.raw})]).then { res in
            return try res.arrayValue.map {
                try MastodonAccountRelationship.decode(json: $0)
            }
        }
    }
    
    func follow(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/follow").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    func unfollow(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/unfollow").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    
    func mute(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/mute").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    func unmute(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/unmute").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    
    func block(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/block").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
    func unblock(account: MastodonAccount) -> Promise<MastodonAccountRelationship> {
        return self.post("accounts/\(account.id.string)/unblock").then { res -> MastodonAccountRelationship in
            return try MastodonAccountRelationship.decode(json: res)
        }
    }
}
