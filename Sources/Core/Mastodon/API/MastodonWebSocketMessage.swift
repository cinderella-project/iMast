//
//  MastodonWebSocketMessage.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/03.
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

public enum MastodonWebSocketMessage: Decodable {
    case update(MastodonPost)
    case delete(MastodonID)
    case unknown(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let event = try container.decode(String.self, forKey: .event)
        switch event {
        case "update":
            let payloadString = try container.decode(String.self, forKey: .payload)
            self = .update(try JSONDecoder.forMastodonAPI.decode(MastodonPost.self, from: payloadString.data(using: .utf8)!))
        case "delete":
            self = .delete(try container.decode(MastodonID.self, forKey: .payload))
        default:
            self = .unknown(event)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case event
        case payload
    }
}
