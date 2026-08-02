//
//  MastodonAnnouncement.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2026/08/01.
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

public struct MastodonAnnouncement: Codable, JSONAPIEndpointResponse, EmojifyProtocol {
    public struct SearchableLink: Codable {
        public let id: MastodonID
        public let url: URL
    }
    
    public let id: String
    public let content: String
    public let publishedAt: Date
    public let updatedAt: Date
    public var read: Bool = false
    public let mentions: [SearchableLink]
    public let tags: [MastodonPostHashtag]
    public let emojis: [MastodonCustomEmoji]?
    public let statuses: [SearchableLink]
    public var profileEmojis: [MastodonCustomEmoji]? { nil }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
        case read
        case mentions
        case tags
        case emojis
        case statuses
    }
}

extension MastodonEndpoint {
    public struct ListAnnouncements: MastodonEndpointProtocol {
        public typealias Response = [MastodonAnnouncement]
        public let endpoint = "/api/v1/announcements"
        public let method = "GET"
        
        public init() {}
    }
    
    public struct AnnouncementDismiss: MastodonEndpointProtocol {
        public typealias Response = DecodableVoid
        public var endpoint: String { "/api/v1/announcements/\(id)/dismiss" }
        public let method = "POST"
        
        public let id: String
        
        public init(id: String) {
            self.id = id
        }
    }
}
