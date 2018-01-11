//
//  MastodonPost.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Hydra
import SwiftyJSON

class MastodonPost: Codable {
    let id: MastodonID
    let url: String?
    let account: MastodonAccount
    let inReplyToId: MastodonID?
    let inReplyToAccountId: MastodonID?
    let repost: MastodonPost?
    let status: String
    let createdAt: Date
    let repostCount: Int
    let favouritesCount: Int
    let reposted: Bool = false
    let favourited: Bool = false
    let muted: Bool = false
    let sensitive: Bool
    let spoilerText: String
    let attachments: [MastodonAttachment]
    let application: MastodonApplication?
    let pinned: Bool?
    let emojis: [MastodonCustomEmoji] = []
    let profileEmojis: [MastodonCustomEmoji] = []
    let visibility: String
    let mentions: [MastodonPostMention] = []

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
        case emojis
        case profileEmojis = "profile_emojis"
        case visibility
        case mentions
    }
}

class MastodonCustomEmoji: Codable {
    let shortcode: String
    let url: String
    enum CodingKeys: String, CodingKey {
        case shortcode
        case url
    }
}

class MastodonPostContext: Codable {
    let ancestors: [MastodonPost]
    let descendants: [MastodonPost]
}

class MastodonPostMention: Codable {
    let url: String
    let username: String
    let acct: String
    let id: MastodonID
}

extension MastodonUserToken {
    func newPost(status: String) -> Promise<MastodonPost> {
        return self.post("statuses", params: ["status": status]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    func repost(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/reblog", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    func favourite(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/favourite", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    func context(post: MastodonPost) -> Promise<MastodonPostContext> {
        return self.get("statuses/\(post.id.string)/context").then { res -> MastodonPostContext in
            return try MastodonPostContext.decode(json: res)
        }
    }
}
