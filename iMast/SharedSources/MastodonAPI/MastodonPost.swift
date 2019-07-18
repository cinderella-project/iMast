//
//  MastodonPost.swift
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
import SwiftyJSON

struct MastodonPostHashtag: Codable {
    let name: String
    let url: String
}

class MastodonPost: Codable, EmojifyProtocol {
    let id: MastodonID
    let url: String?
    let account: MastodonAccount
    let inReplyToId: MastodonID?
    let inReplyToAccountId: MastodonID?
    var repost: MastodonPost?
    let status: String
    let createdAt: Date
    let repostCount: Int
    let favouritesCount: Int
    var reposted: Bool {
        return self._reposted ?? false
    }
    var _reposted: Bool?
    var favourited: Bool {
        return self._favourited ?? false
    }
    var _favourited: Bool?
    var muted: Bool {
        return self._muted ?? false
    }
    var _muted: Bool?
    let sensitive: Bool
    let spoilerText: String
    let attachments: [MastodonAttachment]
    let application: MastodonApplication?
    var pinned: Bool?
    var emojis: [MastodonCustomEmoji]?
    var profileEmojis: [MastodonCustomEmoji]?
    let visibility: String
    private(set) var mentions: [MastodonPostMention] = []
    var tags: [MastodonPostHashtag]?
    var poll: MastodonPoll?

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
        case _reposted = "reblogged"
        case _favourited = "favourited"
        case _muted = "muted"
        case sensitive
        case spoilerText = "spoiler_text"
        case pinned
        case application
        case attachments = "media_attachments"
        case emojis
        case profileEmojis = "profile_emojis"
        case visibility
        case mentions
        case tags
        case poll
    }
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

class MastodonCustomEmoji: Codable {
    let shortcode: String
    let url: String
    enum CodingKeys: String, CodingKey {
        case shortcode
        case url
    }
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
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
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

class MastodonPoll: Codable {
    let id: MastodonID
    let expires_at: Date?
    let expired: Bool
    let multiple: Bool
    let votes_count: Int
    let voted: Bool
    let options: [MastodonPollOption]
}

class MastodonPollOption: Codable {
    let title: String
    let votes_count: Int
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
    func unrepost(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/unreblog", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    
    func favourite(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/favourite", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    func unfavourite(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/favourite", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    
    func delete(post: MastodonPost) -> Promise<Void> {
        return self.delete("statuses/\(post.id.string)").then { res in
            return Void()
        }
    }
    
    func context(post: MastodonPost) -> Promise<MastodonPostContext> {
        return self.get("statuses/\(post.id.string)/context").then { res -> MastodonPostContext in
            return try MastodonPostContext.decode(json: res)
        }
    }
    
    func reports(account: MastodonAccount, comment: String = "", forward: Bool = false, posts: [MastodonPost]) -> Promise<Void> {
        return self.post("reports", params: [
            "account_id": account.id.raw,
            "comment": comment,
            "forward": forward,
            "status_ids": posts.map({$0.id.raw}),
        ]).then { res in
                return Void()
        }
    }
    
    func timeline(_ type: MastodonTimelineType, limit: Int? = nil, since: MastodonPost? = nil, max: MastodonPost? = nil) -> Promise<[MastodonPost]> {
        var params = type.params
        if let limit = limit {
            params["limit"] = limit
        }
        if let since = since {
            print(since, since.id, since.id.string)
            params["since_id"] = since.id.string
        }
        if let max = max {
            params["max_id"] = max.id.string
        }
        return self.get(type.endpoint, params: params).then { res in
            return try res.arrayValue.map({try MastodonPost.decode(json: $0)})
        }
    }
}

class MastodonTimelineType {
    let endpoint: String
    let params: [String: Any]
    
    static let home = MastodonTimelineType(endpoint: "timelines/home")
    static let local = MastodonTimelineType(endpoint: "timelines/public", params: ["local": "true"])
    static func user(_ account: MastodonAccount, pinned: Bool = false) -> MastodonTimelineType {
        var params: [String: Any] = [:]
        if pinned {
            params["pinned"] = 1
        }
        return MastodonTimelineType(endpoint: "accounts/\(account.id.string)/statuses", params: params)
    }
    static func list(_ list: MastodonList) -> MastodonTimelineType {
        return MastodonTimelineType(endpoint: "timelines/list/\(list.id.string)")
    }
    
    static func hashtag(_ tag: String) -> MastodonTimelineType {
        var charset = CharacterSet.urlPathAllowed
        charset.insert("/")
        return MastodonTimelineType(endpoint: "timelines/tag/\(tag.addingPercentEncoding(withAllowedCharacters: charset)!)")
    }
    
    init(endpoint: String, params: [String: Any] = [:]) {
        self.endpoint = endpoint
        self.params = params
    }
}
