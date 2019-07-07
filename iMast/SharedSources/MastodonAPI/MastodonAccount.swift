//
//  MastodonAccount.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Hydra

struct MastodonAccount: Codable, EmojifyProtocol {
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
    let moved: IndirectBox<MastodonAccount>?
    
    let niconicoUrl: URL?
    
    // for pawoo
    let oauthAuthentications: [MastodonAccountOAuthAuthenticate]?
    
    let emojis: [MastodonCustomEmoji]?
    let profileEmojis: [MastodonCustomEmoji]?
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
        case oauthAuthentications = "oauth_authentications"
        
        case emojis
        case profileEmojis = "profile_emojis"
    }
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

struct MastodonAccountOAuthAuthenticate: Codable {
    let provider: String
    let uid: String
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

enum MastodonFollowFetchType: String {
    case following
    case followers
}

struct MastodonFollowList {
    var accounts: [MastodonAccount]
    var prev: MastodonID?
    var next: MastodonID?
    
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
    
    func getFollows(target: MastodonID, type: MastodonFollowFetchType, maxId: MastodonID?) -> Promise<MastodonCursorWrapper<[MastodonAccount]>> {
        var params: [String: Any] = [:]
        if let maxId = maxId {
            params["max_id"] = maxId.string
        }
        return self.getWithCursorWrapper("accounts/\(target.string)/\(type)", params: params).then { res -> MastodonCursorWrapper<[MastodonAccount]> in
            return MastodonCursorWrapper(result: try [MastodonAccount].decode(json: res.result), max: res.max, since: res.since)
        }
    }
}
