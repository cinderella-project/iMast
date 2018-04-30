//
//  MastodonAccount.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Hydra

class MastodonAccount: Codable {
    let id: MastodonID
    let name: String
    let screenName: String
    let isLocked: Bool
    let createdAt: Date
    let followersCount: Int
    let followingCount: Int
    let postsCount: Int
    let bio: String
    let url: String
    let avatarUrl: String
    let headerUrl: String

    let acct: String
    let moved: MastodonAccount?
    
    let niconicoUrl: URL?
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
        case avatarUrl = "avatar"
        case headerUrl = "header"

        case acct
        case moved
        
        case niconicoUrl = "nico_url"
    }
}

extension MastodonUserToken {
    func verifyCredentials() -> Promise<MastodonAccount> {
        return self.get("accounts/verify_credentials").then { res -> MastodonAccount in
            return try MastodonAccount.decode(json: res)
        }
    }
    func getAccount(id: MastodonID) -> Promise<MastodonAccount> {
        return self.get("accounts/"+id.string).then { res -> MastodonAccount in
            return try MastodonAccount.decode(json: res)
        }
    }
    func followRequests() -> Promise<[MastodonAccount]> {
        return self.get("follow_requests").then { res -> [MastodonAccount] in
            return try res.arrayValue.map({try MastodonAccount.decode(json: $0)})
        }
    }
    
    func followRequestAuthorize(target: MastodonAccount) -> Promise<Void> {
        return self.post("follow_requests/\(target.id.string)/authorize").then { res -> Void in
            return Void()
        }
    }
    func followRequestReject(target: MastodonAccount) -> Promise<Void> {
        return self.post("follow_requests/\(target.id.string)/reject").then { res -> Void in
            return Void()
        }
    }
}
