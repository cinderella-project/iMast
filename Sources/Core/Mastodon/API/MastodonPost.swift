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

public struct MastodonPost: Codable, EmojifyProtocol, Hashable, MastodonIDAvailable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id.string)
        hasher.combine(self.url)
    }
    
    public static func == (lhs: MastodonPost, rhs: MastodonPost) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
    
    public let id: MastodonID
    let url: String?
    public var parsedUrl: URL? {
        guard let url = url else {
            return nil
        }
        return URL(string: url)
    }
    public let account: MastodonAccount
    public let inReplyToId: MastodonID?
    let inReplyToAccountId: MastodonID?
    public var repost: IndirectBox<MastodonPost>?
    public var originalPost: MastodonPost {
        return self.repost?.value ?? self
    }
    public let status: String
    public let createdAt: Date
    public let repostCount: Int
    public let favouritesCount: Int

    public var reposted: Bool {
        return self._reposted ?? false
    }
    let _reposted: Bool?

    public var favourited: Bool {
        return self._favourited ?? false
    }
    let _favourited: Bool?

    public var muted: Bool {
        return self._muted ?? false
    }
    let _muted: Bool?

    public let sensitive: Bool
    public let spoilerText: String
    public let attachments: [MastodonAttachment]
    public let application: MastodonApplication?
    let pinned: Bool?
    public let emojis: [MastodonCustomEmoji]?
    public let profileEmojis: [MastodonCustomEmoji]?
    public var hasCustomEmoji: Bool {
        if let emojis = emojis, emojis.count > 0 { return true }
        if let profileEmojis = profileEmojis, profileEmojis.count > 0 { return true }
        return false
    }
    public let visibility: String
    public private(set) var mentions: [MastodonPostMention] = []
    let tags: [MastodonPostHashtag]?
    public var poll: MastodonPoll?
    public let language: String?

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
        case language
    }
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

public struct MastodonCustomEmoji: Codable {
    public let shortcode: String
    public let url: String
    enum CodingKeys: String, CodingKey {
        case shortcode
        case url
    }
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

public struct MastodonPostContext: Codable {
    public let ancestors: [MastodonPost]
    public let descendants: [MastodonPost]
}

public struct MastodonPostMention: Codable {
    public let url: String
    let username: String
    public let acct: String
    public let id: MastodonID
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

public struct MastodonPoll: Codable {
    let id: MastodonID
    public let expires_at: Date?
    public let expired: Bool
    public let multiple: Bool
    public let votes_count: Int
    public let voted: Bool
    public let options: [MastodonPollOption]
}

public struct MastodonPollOption: Codable {
    public let title: String
    public let votes_count: Int
}

extension MastodonUserToken {
    public func canBoost(post: MastodonPost) -> Bool {
        switch post.visibility {
        case "direct":
            return false
        case "private":
            return post.account.acct == self.screenName
        default:
            return true
        }
    }
    
    public func newPost(status: String) -> Promise<MastodonPost> {
        return self.post("statuses", params: ["status": status]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }

    public func repost(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/reblog", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    public func unrepost(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/unreblog", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    
    public func favourite(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/favourite", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    public func unfavourite(post: MastodonPost) -> Promise<MastodonPost> {
        return self.post("statuses/\(post.id.string)/unfavourite", params: [:]).then { res -> MastodonPost in
            return try MastodonPost.decode(json: res)
        }
    }
    
    public func delete(post: MastodonPost) -> Promise<Void> {
        return self.delete("statuses/\(post.id.string)").then { res in
            return Void()
        }
    }
    
    public func context(post: MastodonPost) -> Promise<MastodonPostContext> {
        return self.get("statuses/\(post.id.string)/context").then { res -> MastodonPostContext in
            return try MastodonPostContext.decode(json: res)
        }
    }
    
    public func reports(
        account: MastodonAccount,
        comment: String = "",
        forward: Bool = false,
        posts: [MastodonPost]
    ) -> Promise<Void> {
        return self.post("reports", params: [
            "account_id": account.id.raw,
            "comment": comment,
            "forward": forward,
            "status_ids": posts.map({$0.id.raw}),
        ]).then { res in
                return Void()
        }
    }
    
    public func timeline(_ type: MastodonTimelineType, limit: Int? = nil, sinceId: MastodonID? = nil, maxId: MastodonID? = nil) -> Promise<[MastodonPost]> {
        var params = type.params
        if let limit = limit {
            params["limit"] = limit
        }
        if let sinceId = sinceId {
            params["since_id"] = sinceId.string
        }
        if let maxId = maxId {
            params["max_id"] = maxId.string
        }
        return self.get(type.endpoint, params: params).then { res in
            return try res.arrayValue.map({try MastodonPost.decode(json: $0)})
        }
    }
    
    public func vote(poll: MastodonPoll, choices: [Int]) -> Promise<MastodonPoll> {
        return self.post("polls/\(poll.id.string)/votes", params: [
            "choices": choices,
        ]).then { res in
            return try MastodonPoll.decode(json: res)
        }
    }
    
    public func refresh(post: MastodonPost) -> Promise<MastodonPost> {
        return self.get("statuses/\(post.id.string)").then { try MastodonPost.decode(json: $0) }
    }
}

public class MastodonTimelineType {
    let endpoint: String
    let params: [String: Any]
    
    static public let home = MastodonTimelineType(endpoint: "timelines/home")
    static public let local = MastodonTimelineType(endpoint: "timelines/public", params: ["local": "true"])
    static public let bookmark = MastodonTimelineType(endpoint: "bookmarks")
    static public func user(_ account: MastodonAccount, pinned: Bool = false) -> MastodonTimelineType {
        var params: [String: Any] = [:]
        if pinned {
            params["pinned"] = 1
        }
        return MastodonTimelineType(endpoint: "accounts/\(account.id.string)/statuses", params: params)
    }
    static public func list(_ list: MastodonList) -> MastodonTimelineType {
        return MastodonTimelineType(endpoint: "timelines/list/\(list.id.string)")
    }
    
    static public func hashtag(_ tag: String) -> MastodonTimelineType {
        var charset = CharacterSet.urlPathAllowed
        charset.insert("/")
        return MastodonTimelineType(endpoint: "timelines/tag/\(tag.addingPercentEncoding(withAllowedCharacters: charset)!)")
    }
    
    init(endpoint: String, params: [String: Any] = [:]) {
        self.endpoint = endpoint
        self.params = params
    }
}
