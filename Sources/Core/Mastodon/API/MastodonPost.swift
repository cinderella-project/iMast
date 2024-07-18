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

struct MastodonPostHashtag: Codable {
    let name: String
    let url: String
}

public struct MastodonPost: Codable, EmojifyProtocol, Hashable, MastodonIDAvailable, MastodonEndpointResponse, MastodonPostContentProtocol, Sendable {
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
    public let editedAt: Date?
    public let repostCount: Int
    public let favouritesCount: Int

    @ReadonlyDefault<False> public var reposted: Bool
    @ReadonlyDefault<False> public var favourited: Bool
    @ReadonlyDefault<False> public var bookmarked: Bool
    @ReadonlyDefault<False> public var muted: Bool
    @ReadonlyDefault<False> public var sensitive: Bool
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
    public let visibility: MastodonPostVisibility
    public private(set) var mentions: [MastodonPostMention] = []
    let tags: [MastodonPostHashtag]?
    public var poll: MastodonPoll?
    public let language: String?

    public enum CodingKeys: String, CodingKey {
        case id
        case url
        case account
        case inReplyToId = "in_reply_to_id"
        case inReplyToAccountId = "in_reply_to_account_id"
        case repost = "reblog"
        case status = "content"
        case createdAt = "created_at"
        case editedAt = "edited_at"
        case repostCount = "reblogs_count"
        case favouritesCount = "favourites_count"
        case reposted = "reblogged"
        case favourited = "favourited"
        case muted = "muted"
        case bookmarked = "bookmarked"
        case sensitive = "sensitive"
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

}

public enum MastodonReactionType {
    case boost
    case favorite
}

public struct MastodonCustomEmoji: Codable, Sendable {
    public let shortcode: String
    public let url: String
    enum CodingKeys: String, CodingKey {
        case shortcode
        case url
    }

}

public struct MastodonPostContext: Codable, MastodonEndpointResponse, Sendable {
    public let ancestors: [MastodonPost]
    public let descendants: [MastodonPost]
}

public struct MastodonPostMention: Codable, Sendable {
    public let url: String
    let username: String
    public let acct: String
    public let id: MastodonID

}

public struct MastodonPoll: Codable, MastodonEndpointResponse, Sendable {
    let id: MastodonID
    public let expires_at: Date?
    public let expired: Bool
    public let multiple: Bool
    public let votes_count: Int
    @ReadonlyDefault<False> public var voted: Bool
    public let options: [MastodonPollOption]
}

public struct MastodonPollOption: Codable {
    public let title: String
    public let votes_count: Int
}

extension MastodonUserToken {
    public func canBoost(post: MastodonPost) -> Bool {
        switch post.visibility {
        case .direct:
            return false
        case .private:
            return post.account.acct == self.screenName
        default:
            return true
        }
    }
}

public class MastodonTimelineType: Equatable {
    public static func == (lhs: MastodonTimelineType, rhs: MastodonTimelineType) -> Bool {
        return
            lhs.endpoint == rhs.endpoint &&
            lhs.params == rhs.params &&
            lhs.wsParams == rhs.wsParams
    }
    
    let endpoint: String
    let params: [URLQueryItem]
    public let wsParams: [String: String]?
    
    static public let home = MastodonTimelineType(endpoint: "timelines/home", wsParams: ["stream": "user"])
    static public let federated = MastodonTimelineType(endpoint: "timelines/public", wsParams: ["stream": "public"])
    static public let local = MastodonTimelineType(endpoint: "timelines/public", params: [.init(name: "local", value: "true")], wsParams: ["stream": "public:local"])
    static public func user(_ account: MastodonAccount, pinned: Bool = false) -> MastodonTimelineType {
        var params: [URLQueryItem] = []
        if pinned {
            params.append(.init(name: "pinned", value: "1"))
        }
        return MastodonTimelineType(endpoint: "accounts/\(account.id.string)/statuses", params: params)
    }
    static public func list(_ list: MastodonList) -> MastodonTimelineType {
        return MastodonTimelineType(endpoint: "timelines/list/\(list.id.string)", wsParams: ["stream": "list", "list": list.id.string])
    }
    
    static public func hashtag(_ tag: String) -> MastodonTimelineType {
        var charset = CharacterSet.urlPathAllowed
        return MastodonTimelineType(endpoint: "timelines/tag/\(tag.addingPercentEncoding(withAllowedCharacters: charset)!)", wsParams: ["stream": "hashtag", "tag": tag])
    }
    
    init(endpoint: String, params: [URLQueryItem] = [], wsParams: [String: String]? = nil) {
        self.endpoint = endpoint
        self.params = params
        self.wsParams = wsParams
    }
}

extension MastodonEndpoint {
    public struct GetTimeline: MastodonEndpointWithPagingProtocol {
        public typealias Response = [MastodonPost]
        
        public var endpoint: String {
            return "/api/v1/\(timelineType.endpoint)"
        }
        public let method: String = "GET"
        
        public var query: [URLQueryItem] {
            var q = timelineType.params
            if let limit = limit { q.append(.init(name: "limit", value: limit.description)) }
            paging?.addToQuery(&q)
            return q
        }
        
        public var timelineType: MastodonTimelineType
        public var limit: Int?
        public var paging: MastodonPagingOption?
        
        public init(_ timelineType: MastodonTimelineType, limit: Int? = nil, paging: MastodonPagingOption? = nil) {
            self.timelineType = timelineType
            self.limit = limit
            self.paging = paging
        }
    }
    
    public struct GetBookmarks: MastodonEndpointWithPagingProtocol {
        public typealias Response = MastodonEndpointResponseWithPaging<[MastodonPost]>

        public let endpoint = "/api/v1/bookmarks"
        public let method = "GET"

        public var query: [URLQueryItem] {
            var q = [URLQueryItem]()
            if let limit = limit { q.append(.init(name: "limit", value: limit.description)) }
            paging?.addToQuery(&q)
            return q
        }
        
        public var limit: Int?
        public var paging: MastodonPagingOption?
        
        public init(limit: Int? = nil, paging: MastodonPagingOption? = nil) {
            self.limit = limit
            self.paging = paging
        }
    }
    
    public struct GetFavourites: MastodonEndpointWithPagingProtocol {
        public typealias Response = MastodonEndpointResponseWithPaging<[MastodonPost]>
        
        public let endpoint = "/api/v1/favourites"
        public let method = "GET"
        
        public var query: [URLQueryItem] {
            var q = [URLQueryItem]()
            paging?.addToQuery(&q)
            return q
        }
        
        public var limit: Int?
        public var paging: MastodonPagingOption?
        
        public init(limit: Int? = nil, paging: MastodonPagingOption? = nil) {
            self.limit = limit
            self.paging = paging
        }
    }
    
    public struct CreateRepost: MastodonEndpointProtocol {
        public typealias Response = MastodonPost
        
        public var endpoint: String { "/api/v1/statuses/\(postID.string)/reblog" }
        public let method = "POST"
        
        public let postID: MastodonID
        
        public init(post: MastodonPost) {
            self.postID = post.id
        }
    }
    
    public struct DeleteRepost: MastodonEndpointProtocol {
        public typealias Response = MastodonPost
        
        public var endpoint: String { "/api/v1/statuses/\(postID.string)/unreblog" }
        public let method = "POST"
        
        public let postID: MastodonID
        
        public init(post: MastodonPost) {
            self.postID = post.id
        }
    }
    
    public struct CreateFavourite: MastodonEndpointProtocol {
        public typealias Response = MastodonPost
        
        public var endpoint: String { "/api/v1/statuses/\(postID.string)/favourite" }
        public let method = "POST"
        
        public let postID: MastodonID
        
        public init(post: MastodonPost) {
            self.postID = post.id
        }
    }
    
    public struct DeleteFavourite: MastodonEndpointProtocol {
        public typealias Response = MastodonPost
        
        public var endpoint: String { "/api/v1/statuses/\(postID.string)/unfavourite" }
        public let method = "POST"
        
        public let postID: MastodonID
        
        public init(post: MastodonPost) {
            self.postID = post.id
        }
    }
    
    public struct CreateBookmark: MastodonEndpointProtocol {
        public typealias Response = MastodonPost
        
        public var endpoint: String { "/api/v1/statuses/\(postID.string)/bookmark" }
        public let method = "POST"
        
        public let postID: MastodonID
        
        public init(post: MastodonPost) {
            self.postID = post.id
        }
    }
    
    public struct DeleteBookmark: MastodonEndpointProtocol {
        public typealias Response = MastodonPost
        
        public var endpoint: String { "/api/v1/statuses/\(postID.string)/unbookmark" }
        public let method = "POST"
        
        public let postID: MastodonID
        
        public init(post: MastodonPost) {
            self.postID = post.id
        }
    }
    
    public struct DeletePost: MastodonEndpointProtocol {
        public typealias Response = MastodonPost
        
        public var endpoint: String { "/api/v1/statuses/\(postID.string)" }
        public let method = "DELETE"
        
        public let postID: MastodonID
        
        public init(post: MastodonPost) {
            self.postID = post.id
        }
    }
    
    public struct CreatePost: MastodonEndpointProtocol, Encodable {
        public init(
            status: String,
            visibility: MastodonPostVisibility? = nil,
            mediaIds: [MastodonID] = [],
            spoiler: String = "", sensitive: Bool = false,
            inReplyToPostID: MastodonID? = nil
        ) {
            self.status = status
            self.visibility = visibility
            self.mediaIds = mediaIds
            self.spoiler = spoiler
            self.sensitive = sensitive
            self.inReplyToPostId = inReplyToPostID
        }
        
        public typealias Response = MastodonPost
        
        public let endpoint = "/api/v1/statuses"
        public let method = "POST"
        public func body() throws -> Data? {
            return try JSONEncoder().encode(self)
        }
        
        public var status: String
        public var visibility: MastodonPostVisibility?
        public var mediaIds: [MastodonID] = []
        public var spoiler: String = ""
        public var sensitive: Bool = false
        public var inReplyToPostId: MastodonID?
        
        enum CodingKeys: String, CodingKey {
            case status
            case visibility
            case mediaIds = "media_ids"
            case spoiler = "spoiler_text"
            case sensitive
            case inReplyToPostId = "in_reply_to_id"
        }
    }
    
    public struct EditPost: MastodonEndpointProtocol, Encodable {
        public init(
            postID: MastodonID,
            status: String?,
            mediaIds: [MastodonID]?,
            sensitive: Bool?,
            spoiler: String?
        ) {
            self.postID = postID
            self.status = status
            self.mediaIds = mediaIds
            self.sensitive = sensitive
            self.spoiler = spoiler
        }
        
        public typealias Response = MastodonPost
        public var endpoint: String {
            return "/api/v1/statuses/\(postID)"
        }
        public let method = "PUT"
        public func body() throws -> Data? {
            return try JSONEncoder().encode(self)
        }
        
        public var postID: MastodonID
        public var status: String?
        public var mediaIds: [MastodonID]?
        public var sensitive: Bool?
        public var spoiler: String?
        
        enum CodingKeys: String, CodingKey {
            case status
            case mediaIds = "media_ids"
            case sensitive
            case spoiler = "spoiler_text"
        }
    }
    
    public struct GetContextOfPost: MastodonEndpointProtocol {
        public typealias Response = MastodonPostContext
        
        public var endpoint: String { "/api/v1/statuses/\(postID.string)/context" }
        public let method = "GET"
        
        public let postID: MastodonID
        
        public init(post: MastodonPost) {
            self.postID = post.id
        }
    }
    
    public struct VoteToPoll: MastodonEndpointProtocol, Encodable {
        public typealias Response = MastodonPoll
        
        public var endpoint: String { "/api/v1/polls/\(pollId)/votes" }
        public let method = "POST"
        
        public var pollId: MastodonID
        public var choices: [Int]
        
        enum CodingKeys: String, CodingKey {
            case choices
        }
        
        public init(poll: MastodonPoll, choices: [Int]) {
            self.pollId = poll.id
            self.choices = choices
        }
    }
    
    public struct GetPost: MastodonEndpointProtocol {
        public typealias Response = MastodonPost
        
        public var endpoint: String { "/api/v1/statuses/\(postId.string)" }
        public let method = "GET"
        
        public var postId: MastodonID
        
        public init(post: MastodonPost) {
            self.postId = post.id
        }
    }
    
    public struct GetPostReactedUsers: MastodonEndpointWithPagingProtocol {
        public typealias Response = MastodonEndpointResponseWithPaging<[MastodonAccount]>
        
        public var endpoint: String { "/api/v1/statuses/\(postId.string)/\(type == .boost ? "reblogged" : "favourited")_by" }
        public let method = "GET"
        
        public var query: [URLQueryItem] {
            var q = [URLQueryItem]()
            paging?.addToQuery(&q)
            return q
        }
        
        public var type: MastodonReactionType
        public var postId: MastodonID
        public var limit: Int?
        public var paging: MastodonPagingOption?
        
        public init(post: MastodonPost, type: MastodonReactionType, limit: Int? = nil, paging: MastodonPagingOption? = nil) {
            self.limit = limit
            self.paging = paging
            self.postId = post.id
            self.type = type
        }
    }
}
