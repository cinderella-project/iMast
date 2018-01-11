//
//  MastodonID.swift
//  iMast
//
//  Created by user on 2018/01/12.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

class MastodonID: Codable {
    var int: Int64
    var string: String
    var raw: Any
    
    var description: String {
        get{
            print("WARNING: get description")
            return self.string
        }
    }
    
    required init(from decoder: Decoder) throws {
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
            self.int = int
            self.string = self.int.description
        } else if raw is String {
            guard let string = raw as? String else {
                throw MastodonIDError.convertFailed
            }
            self.string = string
            guard let int = Int64(self.string) else {
                throw MastodonIDError.failedConvertToInt
            }
            self.int = int
        } else {
            throw MastodonIDError.notIntAndStringWhat
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.string)
    }
}

extension MastodonID: Equatable {
    static func ==(lhs: MastodonID, rhs: MastodonID) -> Bool {
        return lhs.string == rhs.string
    }
    
    
}

enum MastodonIDError: Error {
    case failedConvertToInt
    case notIntAndStringWhat
    case convertFailed
}
