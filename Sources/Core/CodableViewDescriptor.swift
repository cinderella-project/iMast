//
//  CodableViewDescriptor.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/07/29.
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

public enum CodableViewDescriptor: Hashable {
    case home
    case notifications
    case local
    case federated
    case homeAndLocal
    case list(id: String, title: String)
    
    enum CodingKeys: String, CodingKey {
        case type
        case id
        case title
    }
    
    enum Types: String, Codable {
        case home
        case notifications
        case local
        case federated
        case homeAndLocal
        case list
    }
}

// TODO: replace with plugins

extension CodableViewDescriptor: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .home:
            try container.encode(Types.home, forKey: .type)
        case .notifications:
            try container.encode(Types.notifications, forKey: .type)
        case .local:
            try container.encode(Types.local, forKey: .type)
        case .federated:
            try container.encode(Types.federated, forKey: .type)
        case .homeAndLocal:
            try container.encode(Types.homeAndLocal, forKey: .type)
        case .list(id: let id, title: let title):
            try container.encode(Types.list, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(title, forKey: .title)
        }
    }
}

extension CodableViewDescriptor: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Types.self, forKey: .type) {
        case .home:
            self = .home
        case .notifications:
            self = .notifications
        case .local:
            self = .local
        case .federated:
            self = .federated
        case .homeAndLocal:
            self = .homeAndLocal
        case .list:
            self = .list(id: try container.decode(String.self, forKey: .id), title: try container.decode(String.self, forKey: .title))
        }
    }
}
