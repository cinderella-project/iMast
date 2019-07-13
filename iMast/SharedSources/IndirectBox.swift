//
//  IndirectBox.swift
//  iMast
//
//  Created by user on 2019/07/07.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

enum IndirectBox<T> {
    var value: T {
        switch self {
        case .value(let value):
            return value
        }
    }
    indirect case value(T)
}

extension IndirectBox: Decodable where T: Decodable {
    init(from decoder: Decoder) throws {
        self = .value(try T.init(from: decoder))
    }
}

extension IndirectBox: Encodable where T: Encodable {
    func encode(to encoder: Encoder) throws {
        return try value.encode(to: encoder)
    }
}
