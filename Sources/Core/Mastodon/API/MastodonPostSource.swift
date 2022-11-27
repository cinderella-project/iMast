//
//  MastodonPostSource.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/11/27.
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

public struct MastodonPostSource: Codable, MastodonEndpointResponse {
    public let id: MastodonID
    public let text: String
    public let spoilerText: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case spoilerText = "spoiler_text"
    }
}

extension MastodonEndpoint {
    public struct GetPostSource: MastodonEndpointProtocol {
        public typealias Response = MastodonPostSource
        
        public var endpoint: String { "/api/v1/statuses/\(id.string)/source"}
        public let method: String = "GET"
        
        public let id: MastodonID
        
        public init(_ id: MastodonID) {
            self.id = id
        }
    }
}
