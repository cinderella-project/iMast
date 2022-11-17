//
//  MastodonID.swift
//  iMast
//
//  Created by rinsuki on 2018/01/12.
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

public enum MastodonID: Codable, CustomStringConvertible, Sendable {
    case int(Int64)
    case string(String)
    
    public var string: String {
        switch self {
        case .int(let value):
            return value.description
        case .string(let value):
            return value
        }
    }
    
    public var raw: Any {
        switch self {
        case .int(let value):
            return value
        case .string(let value):
            return value
        }
    }
    
    public var description: String {
        print("WARNING: get description")
        return self.string
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        do {
            self = .string(try value.decode(String.self))
        } catch {
            self = .int(try value.decode(Int64.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
    
    public func compare(_ otherId: MastodonID) -> ComparisonResult {
        if case .int(let myID) = self, case .int(let myID2) = otherId {
            if myID > myID2 {
                return .orderedDescending
            } else if myID < myID2 {
                return .orderedAscending
            }
            return .orderedSame
        }
        if self.string == otherId.string {
            return .orderedSame
        }
        if self.string.count != otherId.string.count {
            return self.string.count > otherId.string.count ? .orderedDescending : .orderedAscending
        }
        for i in 0..<self.string.count {
            let selfChar = self.string[self.string.index(self.string.startIndex, offsetBy: i)]
            let otherChar = otherId.string[otherId.string.index(otherId.string.startIndex, offsetBy: i)]
            if selfChar != otherChar {
                return selfChar > otherChar ? .orderedDescending : .orderedAscending
            }
        }
        fatalError("ここに届くのはおかしい")
    }
}

extension MastodonID: Equatable {
    public static func == (lhs: MastodonID, rhs: MastodonID) -> Bool {
        return lhs.string == rhs.string
    }
}

extension MastodonID: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.string)
    }
}
