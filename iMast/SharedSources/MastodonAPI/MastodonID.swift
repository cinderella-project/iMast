//
//  MastodonID.swift
//  iMast
//
//  Created by user on 2018/01/12.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

struct MastodonID: Codable, CustomStringConvertible {
    @available(*, unavailable)
    var int: Int64 = -1
    var string: String
    var raw: Any
    
    var description: String {
        print("WARNING: get description")
        return self.string
    }
    
    init(string: String) {
        self.string = string
//        self.int = Int64(string)!
        self.raw = string
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        do {
            raw = try value.decode(String.self)
        } catch {
            raw = try value.decode(Int64.self)
        }
        if raw is Int64 {
            guard let int = raw as? Int64 else {
                throw MastodonIDError.convertFailed
            }
//            self.int = int
            self.string = int.description
        } else if raw is String {
            guard let string = raw as? String else {
                throw MastodonIDError.convertFailed
            }
            self.string = string
//            guard let int = Int64(self.string) else {
//                throw MastodonIDError.failedConvertToInt
//            }
//            self.int = int
        } else {
            throw MastodonIDError.notIntAndStringWhat
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let raw = self.raw
        if let raw = raw as? String {
            try container.encode(raw)
        } else if let raw = raw as? Int64 {
            try container.encode(raw)
        }
    }
    
    func compare(_ otherId: MastodonID) -> ComparisonResult {
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
    static func == (lhs: MastodonID, rhs: MastodonID) -> Bool {
        return lhs.string == rhs.string
    }
}

enum MastodonIDError: Error {
    case failedConvertToInt
    case notIntAndStringWhat
    case convertFailed
}
