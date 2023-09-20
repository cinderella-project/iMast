//
//  DefaultCodable.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/09/09.
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

@propertyWrapper
public struct ReadonlyDefault<Provider: DefaultProvider>: Codable {
    public let wrappedValue: Provider.Value
    
    public init() {
        wrappedValue = Provider.defaultValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = Provider.defaultValue
        } else {
            wrappedValue = try container.decode(Provider.Value.self)
        }
    }
}

extension ReadonlyDefault: Sendable where Provider.Value: Sendable {
}

public protocol DefaultProvider {
    associatedtype Value: Codable
    
    static var defaultValue: Value { get }
}

public enum False: DefaultProvider {
    public static let defaultValue = false
}

@propertyWrapper
public struct ReadonlyDefaultEmptyArray<Inner: Codable>: Codable {
    public let wrappedValue: [Inner]
    
    public init() {
        wrappedValue = []
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = []
        } else {
            wrappedValue = try container.decode(Array<Inner>.self)
        }
    }
}

public extension KeyedDecodingContainer {
    func decode<T>(_: ReadonlyDefault<T>.Type, forKey key: Key) throws -> ReadonlyDefault<T> {
        return (try decodeIfPresent(ReadonlyDefault<T>.self, forKey: key)) ?? ReadonlyDefault<T>()
    }
    
    func decode<T>(_: ReadonlyDefaultEmptyArray<T>.Type, forKey key: Key) throws -> ReadonlyDefaultEmptyArray<T> {
        return (try decodeIfPresent(ReadonlyDefaultEmptyArray<T>.self, forKey: key)) ?? ReadonlyDefaultEmptyArray<T>()
    }
}
