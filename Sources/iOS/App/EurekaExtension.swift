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
import iMastiOSCore

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
