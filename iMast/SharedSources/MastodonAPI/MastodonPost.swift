//
//  MastodonPost.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Hydra

class MastodonPost: Codable {
    let id: String
    let url: String
    let account: MastodonAccount
    let inReplyToId: String
    let inReplyToAccountId: String
    let repost: MastodonPost
    let status: String
    let createdAt: Date
    let repostCount: Int
    let favouritesCount: Int
    let reposted: Bool
    let favourited: Bool
    let muted: Bool
    let sensitive: Bool
    let spoilerText: String
    let pinned: Bool?
    let attachments: [MastodonAttachment]
    let application: MastodonApplication
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case account
        case inReplyToId = "in_reply_to_id"
        case inReplyToAccountId = "in_reply_to_account_id"
        case repost = "reblog"
        case status = "content"
        case createdAt = "created_at"
        case repostCount = "reblogs_count"
        case favouritesCount = "favourites_count"
        case reposted = "reblogged"
        case favourited
        case muted
        case sensitive
        case spoilerText = "spoiler_text"
        case pinned
        case application
        case attachments = "media_attachments"
    }
}

extension MastodonUserToken {
    func newPost(status: String) -> Promise<MastodonPost> {
        return self.post("statuses", params: ["status": status]).then { res -> MastodonPost in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = jsISODate
            return try decoder.decode(MastodonPost.self, from: res.rawData())
        }
    }
}
