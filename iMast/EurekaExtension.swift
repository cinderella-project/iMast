//
//  EurekaExtension.swift
//  iMast
//
//  Created by user on 2017/10/29.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import Eureka

final class PushStringRow: _PushRow<PushSelectorCell<String>>, RowType {
    func userDefaultsConnect(_ key:DefaultsKey<String>, map: [String: String], userDefaults: UserDefaults = UserDefaultsAppGroup) {
        self.options = map.keys.map { (name) -> String in
            return map[name]!
        }
        let name = key._key
        let userDefaultsValue = userDefaults.string(forKey: name) ?? ""
        self.value = map[userDefaultsValue] ?? userDefaultsValue
        self.cellUpdate { (cell, row) in
            map.forEach({ (key, value) in
                if(value == row.value) {
                    print(key)
                    userDefaults.set(key, forKey: name)
                }
            })
        }
    }
}
extension TextRow {
    func userDefaultsConnect(_ key:DefaultsKey<String>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        let name = key._key
        self.value = userDefaults.string(forKey: name)
        var oldValue = self.value
        self.cellUpdate { cell, row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            userDefaults.set(row.value, forKey: name)
        }
    }
}

extension SwitchRow {
    func userDefaultsConnect(_ key:DefaultsKey<Bool>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        let name = key._key
        self.value = userDefaults.bool(forKey: name)
        var oldValue = self.value
        self.onChange { row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            userDefaults.set(row.value, forKey: name)
        }
    }
}

extension SliderRow {
    func userDefaultsConnect(_ key:DefaultsKey<Double>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        let name = key._key
        self.value = userDefaults.float(forKey: name)
        var oldValue = self.value
        self.cellUpdate { cell, row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            userDefaults.set(row.value, forKey: name)
        }
    }
}
extension TextAreaRow {
    func userDefaultsConnect(_ key:DefaultsKey<String>, userDefaults: UserDefaults = UserDefaultsAppGroup) {
        let name = key._key
        self.value = userDefaults.string(forKey: name)
        var oldValue = self.value
        self.cellUpdate { cell, row in
            if oldValue == row.value {
                return
            }
            oldValue = row.value
            userDefaults.set(row.value, forKey: name)
        }
    }
}
