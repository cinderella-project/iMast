//
//  Defaults.swift
//  iMast
//
//  Created by rinsuki on 2017/12/23.
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
import SwiftUI

public class _BaseDefaultsKey<ValueType>: Defaults {
    let key: String
    let defaults = UserDefaultsAppGroup
    
    fileprivate var _raw_wrappedValue: ValueType? {
        get {
            return defaults.object(forKey: key) as? ValueType
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }
    
    fileprivate init(key: String) {
        self.key = key
    }
}

@propertyWrapper
public class DefaultsKey<ValueType: DefaultsKeySuitable>: _BaseDefaultsKey<ValueType> {
    public let defaultValue: ValueType
    public var projectedValue: DefaultsKey<ValueType> { return self }
    public var wrappedValue: ValueType {
        get {
            return _raw_wrappedValue ?? defaultValue
        }
        set {
            _raw_wrappedValue = newValue
        }
    }
    
    init(wrappedValue defaultValue: ValueType, _ key: String) {
        self.defaultValue = defaultValue
        super.init(key: key)
    }
}

public protocol DefaultsKeySuitable {
}

extension String: DefaultsKeySuitable {
}

extension Int: DefaultsKeySuitable {
}

extension Bool: DefaultsKeySuitable {
}

extension Double: DefaultsKeySuitable {
}

@propertyWrapper
public class DefaultsKeyRawRepresentable<ValueType: RawRepresentable>: _BaseDefaultsKey<ValueType.RawValue> {
    public var projectedValue: DefaultsKeyRawRepresentable<ValueType> { return self }
    public let defaultValue: ValueType
    
    public var wrappedValue: ValueType {
        get {
            guard let rawWrappedValue = _raw_wrappedValue else {
                return defaultValue
            }
            return .init(rawValue: rawWrappedValue) ?? defaultValue
        }
        set {
            _raw_wrappedValue = newValue.rawValue
        }
    }
    
    public init(wrappedValue defaultValue: ValueType, _ key: String) {
        self.defaultValue = defaultValue
        super.init(key: key)
    }
}

public extension AppStorage {
    init(defaults: DefaultsKey<Value>) where Value == Bool {
        self.init(wrappedValue: defaults.wrappedValue, defaults.key, store: defaults.defaults)
    }
    
    init(defaults: DefaultsKey<Value>) where Value == Double {
        self.init(wrappedValue: defaults.wrappedValue, defaults.key, store: defaults.defaults)
    }
    
    init(defaults: DefaultsKey<Value>) where Value == String {
        self.init(wrappedValue: defaults.wrappedValue, defaults.key, store: defaults.defaults)
    }
    
    init(defaults: DefaultsKey<Value>) where Value == Int {
        self.init(wrappedValue: defaults.wrappedValue, defaults.key, store: defaults.defaults)
    }
    
    init(defaults: DefaultsKeyRawRepresentable<Value>) where Value.RawValue == String {
        self.init(wrappedValue: defaults.wrappedValue, defaults.key, store: defaults.defaults)
    }
}
