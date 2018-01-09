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
        case moved
        case acct
    }
}


let jsISODate = JSONDecoder.DateDecodingStrategy.custom {
    let container = try $0.singleValueContainer()
    let str = try container.decode(String.self)
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = .current
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.AAA'Z'"
    return f.date(from: str)!
}

extension MastodonUserToken {
    func verifyCredentials() -> Promise<MastodonAccount> {
        return self.get("accounts/verify_credentials").then { res -> MastodonAccount in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = jsISODate
            return try decoder.decode(MastodonAccount.self, from: res.rawData())
        }
    }
}

