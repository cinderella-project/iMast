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

final class PushStringRow: _PushRow<PushSelectorCell<String>>, RowType {
    func userDefaultsConnect<T: Equatable>(_ key: DefaultsKey<T>, map: [(key: T, value: String)], userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.options = map.map { $0.value }
        let userDefaultsValue = Defaults[key]
        self.value = map.filter { arg -> Bool in
            let (key, _) = arg
            return key == userDefaultsValue
        }.first?.value ?? "\(userDefaultsValue)"
        self.cellUpdate { (cell, row) in
            map.forEach({ (key_, value) in
                if value == row.value {
                    Defaults[key] = key_
                }
            })
        }
    }
}

extension PushRow where T: WithDefaultValue & RawRepresentable {
    func userDefaultsConnect(_ key: DefaultsKey<T>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.value = Defaults[key]
        self.cellUpdate { (cell, row) in
            guard let value = row.value else {
                return
            }
            Defaults[key] = value
        }
    }
}

extension TextRow {
    func userDefaultsConnect(_ key: DefaultsKey<String>, userDefaults: UserDefaults = UserDefaultsAppGroup, ifEmptyUseDefaultValue: Bool = false) {
        self.value = Defaults[key]
        var oldValue = self.value
        self.cellUpdate { cell, row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            let newValue = row.value ?? ""
            Defaults[key] = newValue == "" ? (key._default ?? "") : newValue
        }
    }
}

extension SwitchRow {
    func userDefaultsConnect(_ key: DefaultsKey<Bool>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.value = Defaults[key]
        var oldValue = self.value
        self.onChange { row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            Defaults[key] = row.value ?? false
        }
    }
}

extension TwolineSliderRow {
    func userDefaultsConnect(_ key: DefaultsKey<Double>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.value = Float(Defaults[key])
        var oldValue = self.value
        self.cellUpdate { cell, row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            Defaults[key] = Double(row.value ?? 0.0)
        }
    }
}
extension TextAreaRow {
    func userDefaultsConnect(_ key: DefaultsKey<String>, userDefaults: UserDefaults = UserDefaultsAppGroup, ifEmptyUseDefaultValue: Bool = false) {
        self.value = Defaults[key]
        var oldValue = self.value
        self.cellUpdate { cell, row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            let newValue = row.value ?? ""
            Defaults[key] = newValue == "" ? (key._default ?? "") : newValue
        }
    }
}
