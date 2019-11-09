//
//  UserDefaultsDict.swift
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

// var Defaults = UserDefaultsAppGroup

extension UserDefaults {
    func nullable<T: WithDefaultValue>(_ key: DefaultsKey<T>) -> T? {
        return (object(forKey: key._key) as? T) ?? key._default
    }
    func nullable<T: WithDefaultValue & RawRepresentable>(_ key: DefaultsKey<T>) -> T? {
        if let rawValue = object(forKey: key._key) as? T.RawValue {
            return T(rawValue: rawValue) ?? key._default
        } else {
            return key._default
        }
    }

    subscript<T: WithDefaultValue>(key: DefaultsKey<T>) -> T {
        get { return self.nullable(key) ?? T._defaultValue }
        set { set(newValue, forKey: key._key)}
    }
    subscript<T: WithDefaultValue & RawRepresentable>(key: DefaultsKey<T>) -> T {
        get { return self.nullable(key) ?? T._defaultValue }
        set { set(newValue.rawValue, forKey: key._key) }
    }
}
// UserDefaults.standard.forKey

protocol WithDefaultValue {
    static var _defaultValue: Self { get }
}

extension Int: WithDefaultValue {
    static let _defaultValue = 0
}

extension Double: WithDefaultValue {
    static let _defaultValue = Double(0)
}

extension String: WithDefaultValue {
    static let _defaultValue = ""
}

extension Bool: WithDefaultValue {
    static let _defaultValue = false
}

class DefaultsKeys {}

class DefaultsKey<ValueType: WithDefaultValue>: DefaultsKeys {
    let _key: String
    let _default: ValueType?
    
    init(_ key: String) {
        self._key = key
        self._default = nil
    }

    init(_ key: String, default defaultValue: ValueType) {
        self._key = key
        self._default = defaultValue
    }
}
