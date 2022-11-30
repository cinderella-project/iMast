//
//  IndirectBox.swift
//  iMast
//
//  Created by rinsuki on 2019/07/07.
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
//

import Foundation

public enum IndirectBox<T> {
    public var value: T {
        switch self {
        case .value(let value):
            return value
        }
    }
    indirect case value(T)
}

extension IndirectBox: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self = .value(try T.init(from: decoder))
    }
}

extension IndirectBox: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        return try value.encode(to: encoder)
    }
}

extension IndirectBox: Sendable where T: Sendable {
}
