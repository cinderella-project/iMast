//
//  ThirdpartyTrendTags.swift
//  iMast
//
//  Created by rinsuki on 2018/10/28.
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

public struct ThirdpartyTrendsTags: Codable, MastodonEndpointResponse {
    public let updatedAt: Date
    public let score: [String: Float]
    
    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case score
    }
}

extension MastodonEndpoint {
    public struct GetTrendTagsThirdparty: MastodonEndpointProtocol {
        public typealias Response = ThirdpartyTrendsTags
        public let endpoint = "/api/v1/trend_tags"
        public let method = "GET"
        
        public init() {
        }
    }
}
