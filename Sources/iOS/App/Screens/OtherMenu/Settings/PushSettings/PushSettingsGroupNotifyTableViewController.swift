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
import Eureka
import iMastiOSCore

class PushSettingsGroupNotifyTableViewController: FormViewController {

    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = L10n.Preferences.Push.Shared.GroupRules.title
        
        self.form.append {
            Section {
                SwitchRow { row in
                    row.title = L10n.Preferences.Push.Shared.GroupRules.byAccount
                    row.userDefaultsConnect(Defaults.$groupNotifyAccounts)
                }
            }
            Section(
                header: L10n.Preferences.Push.Shared.GroupRules.ByType.title,
                footer: L10n.Preferences.Push.Shared.GroupRules.ByType.description
            ) {
                SwitchRow { row in
                    row.title = "ブースト"
                    row.userDefaultsConnect(Defaults.$groupNotifyTypeBoost)
                }
                SwitchRow { row in
                    row.title = "お気に入り"
                    row.userDefaultsConnect(Defaults.$groupNotifyTypeFavourite)
                }
                SwitchRow { row in
                    row.title = "メンション"
                    row.userDefaultsConnect(Defaults.$groupNotifyTypeMention)
                }
                SwitchRow { row in
                    row.title = "フォロー"
                    row.userDefaultsConnect(Defaults.$groupNotifyTypeFollow)
                }
                SwitchRow { row in
                    row.title = "その他"
                    row.userDefaultsConnect(Defaults.$groupNotifyTypeUnknown)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
