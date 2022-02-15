//
//  EurekaExtension.swift
//  iMast
//
//  Created by rinsuki on 2017/10/29.
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

import Eureka
import EurekaTwolineSliderRow
import iMastiOSCore

final class PushStringRow: _PushRow<PushSelectorCell<String>>, RowType {
    func userDefaultsConnect<T: Equatable>(_ key: DefaultsKey<T>, map: [(key: T, value: String)], userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.options = map.map { $0.value }
        let userDefaultsValue = key.wrappedValue
        self.value = map.filter { arg -> Bool in
            let (key, _) = arg
            return key == userDefaultsValue
        }.first?.value ?? "\(userDefaultsValue)"
        self.onChange { row in
            map.forEach({ (key_, value) in
                if value == row.value {
                    key.wrappedValue = key_
                }
            })
        }
    }
}

extension PushRow where T: RawRepresentable {
    func userDefaultsConnect(_ key: DefaultsKeyRawRepresentable<T>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.value = key.wrappedValue
        self.onChange { row in
            guard let value = row.value else {
                return
            }
            key.wrappedValue = value
        }
    }
}

extension TextRow {
    func userDefaultsConnect(_ key: DefaultsKey<String>, userDefaults: UserDefaults = UserDefaultsAppGroup, ifEmptyUseDefaultValue: Bool = false) {
        self.value = key.wrappedValue
        var oldValue = self.value
        self.onChange { row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            let newValue = row.value ?? ""
            key.wrappedValue = newValue == "" ? key.defaultValue : newValue
        }
    }
}

extension SwitchRow {
    func userDefaultsConnect(_ key: DefaultsKey<Bool>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.value = key.wrappedValue
        var oldValue = self.value
        self.onChange { row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            key.wrappedValue = row.value ?? false
        }
    }
}

extension TwolineSliderRow {
    func userDefaultsConnect(_ key: DefaultsKey<Double>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.value = Float(key.wrappedValue)
        var oldValue = self.value
        self.onChange { row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            key.wrappedValue = Double(row.value ?? 0.0)
        }
    }
}
extension TextAreaRow {
    func userDefaultsConnect(_ key: DefaultsKey<String>, userDefaults: UserDefaults = UserDefaultsAppGroup, ifEmptyUseDefaultValue: Bool = false) {
        self.value = key.wrappedValue
        var oldValue = self.value
        self.onChange { row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            let newValue = row.value ?? ""
            key.wrappedValue = newValue == "" ? key.defaultValue : newValue
        }
    }
}
