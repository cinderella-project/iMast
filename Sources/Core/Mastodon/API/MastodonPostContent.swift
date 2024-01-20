//
//  MastodonPostContent.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/03/31.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

import Foundation

public struct MastodonPostContent: Codable, EmojifyProtocol, MastodonPostContentProtocol, MastodonEndpointResponse {
    public let status: String
    public let sensitive: Bool
    public let spoilerText: String
    public let createdAt: Date
    public let attachments: [MastodonAttachment]
    public let emojis: [MastodonCustomEmoji]?
    public let profileEmojis: [MastodonCustomEmoji]?
    
    enum CodingKeys: String, CodingKey {
        case status = "content"
        case sensitive
        case spoilerText = "spoiler_text"
        case createdAt = "created_at"
        case attachments = "media_attachments"
        case emojis
        case profileEmojis = "profile_emojis"
    }
}

public protocol MastodonPostContentProtocol: EmojifyProtocol {
    var status: String { get }
    var sensitive: Bool { get }
    var spoilerText: String { get }
    var attachments: [MastodonAttachment] { get }
}

extension MastodonEndpoint {
    public struct GetPostEditHistory: MastodonEndpointProtocol {
        public typealias Response = [MastodonPostContent]
        
        public var endpoint: String { "/api/v1/statuses/\(id.string)/history" }
        public let method: String = "GET"
        
        public let id: MastodonID
        
        public init(_ id: MastodonID) {
            self.id = id
        }
    }
}
