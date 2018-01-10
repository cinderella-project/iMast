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
    let id: String
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
    let moved: String?
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
    }
}

extension MastodonUserToken {
    func verifyCredentials() -> Promise<MastodonAccount> {
        return self.get("accounts/verify_credentials").then { res -> MastodonAccount in
            return try MastodonAccount.decode(json: res)
        }
    }
    func getAccount(id: String) -> Promise<MastodonAccount> {
        return self.get("accounts/"+id).then { res -> MastodonAccount in
            return try MastodonAccount.decode(json: res)
        }
    }
}