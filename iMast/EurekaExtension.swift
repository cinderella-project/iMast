//
//  EurekaExtension.swift
//  iMast
//
//  Created by user on 2017/10/29.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import Eureka

final class PushStringRow: _PushRow<PushSelectorCell<String>>, RowType {
    func userDefaultsConnect(name: String, map: [String: String], userDefaults: UserDefaults = UserDefaults.standard) {
        self.options = map.keys.map { (name) -> String in
            return map[name]!
        }
        if defaultValues[name] == nil {
            WARN("WARNING!!! \(name)はdefaultValuesに記載されていません")
        }
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
    func userDefaultsConnect(name: String, userDefaults: UserDefaults = UserDefaults.standard) {
        if defaultValues[name] == nil {
            WARN("WARNING!!! \(name)はdefaultValuesに記載されていません")
        }
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
    func userDefaultsConnect(name: String, userDefaults: UserDefaults = UserDefaults.standard) {
        if defaultValues[name] == nil {
            WARN("WARNING!!! \(name)はdefaultValuesに記載されていません")
        }
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
    func userDefaultsConnect(name: String, userDefaults: UserDefaults = UserDefaults.standard) {
        if defaultValues[name] == nil {
            WARN("WARNING!!! \(name)はdefaultValuesに記載されていません")
        }
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
    func userDefaultsConnect(name: String, userDefaults: UserDefaults = UserDefaults.standard) {
        if defaultValues[name] == nil {
            WARN("WARNING!!! \(name)はdefaultValuesに記載されていません")
        }
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
