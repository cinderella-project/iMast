//
//  PushSettingsGroupNotifyTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/09/18.
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

import UIKit
import SwiftUI
import iMastiOSCore

struct PushSettingsGroupNotifyTableView: View {
    @AppStorage(defaults: .$groupNotifyAccounts) var groupNotifyAccounts
    @AppStorage(defaults: .$groupNotifyTypeBoost) var groupBoost
    @AppStorage(defaults: .$groupNotifyTypeFavourite) var groupFavourite
    @AppStorage(defaults: .$groupNotifyTypeMention) var groupMention
    @AppStorage(defaults: .$groupNotifyTypeFollow) var groupFollow
    @AppStorage(defaults: .$groupNotifyTypeUnknown) var groupUnknown
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $groupNotifyAccounts) {
                    Text(L10n.Preferences.Push.Shared.GroupRules.byAccount)
                }
            }
            Section {
                Toggle(isOn: $groupBoost) { Text("ブースト") }
                Toggle(isOn: $groupFavourite) { Text("お気に入り") }
                Toggle(isOn: $groupMention) { Text("メンション") }
                Toggle(isOn: $groupFollow) { Text("フォロー") }
                Toggle(isOn: $groupUnknown) { Text("その他") }
            } header: {
                Text(L10n.Preferences.Push.Shared.GroupRules.ByType.title)
            } footer: {
                Text(L10n.Preferences.Push.Shared.GroupRules.ByType.description)
            }
        }
        .navigationTitle(L10n.Preferences.Push.Shared.GroupRules.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
