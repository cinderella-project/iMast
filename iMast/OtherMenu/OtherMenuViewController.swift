//
//  OtherMenuTopTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/18.
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
import SafariServices
import ActionClosurable
import SwiftUI

class OtherMenuViewController: FormViewController {

    var nowAccount: MastodonUserToken?

    init() {
        super.init(style: .plain)
        self.title = R.string.localizable.other()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        nowAccount = MastodonUserToken.getLatestUsed()
        
        let section = Section()
        section <<< ButtonRow { row in
            row.title = R.string.localizable.switchActiveAccount()
            row.cellStyle = .subtitle
            row.presentationMode = .show(controllerProvider: .callback(builder: { ChangeActiveAccountViewController() }), onDismiss: nil)
        }.cellSetup { cell, row in
            cell.height = { 44 }
        }.cellUpdate { (cell, row) in
            cell.detailTextLabel?.text = R.string.localizable.currentAccount(self.nowAccount?.acct ?? "")
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.myProfile()
        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }.onCellSelection { cell, row in
            MastodonUserToken.getLatestUsed()!.verifyCredentials().then { account in
                print(account)
                let newVC = openUserProfile(user: account)
                self.navigationController?.pushViewController(newVC, animated: true)
            }.catch { error in
                    print(error)
            }
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.lists()
        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }.onCellSelection { cell, row in
            // TODO: ここの下限バージョンの処理をあとで共通化する
            MastodonUserToken.getLatestUsed()!.getIntVersion().then { version in
                if version < MastodonVersionStringToInt("2.1.0rc1") {
                    self.alert(title: R.string.localizable.errorTitle(), message: R.string.localizable.errorRequiredNewerMastodon("2.1.0rc1"))
                    return
                }
                MastodonUserToken.getLatestUsed()!.lists().then({ lists in
                    let vc = ListsTableViewController()
                    vc.lists = lists
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.settings()
            row.presentationMode = .show(controllerProvider: .callback(builder: { SettingsViewController() }), onDismiss: nil)
        }
        
        section <<< ButtonRow { row in
            row.title = "Siri Shortcuts"
        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }.onCellSelection { (cell, row) in
            if #available(iOS 12.0, *) {
                let vc = CreateSiriShortcutsViewController()
                vc.title = cell.textLabel?.text
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                // Fallback on earlier versions
                self.alert(title: R.string.localizable.errorTitle(), message: R.string.localizable.errorRequiredNewerOS(12.0))
            }
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.helpAndFeedback()
            row.presentationMode = .show(controllerProvider: .callback(builder: { UIHostingController(rootView: OtherMenuHelpAndFeedbackView()) }), onDismiss: nil)
        }
        
        self.form +++ section
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search) { (item) in
            self.navigationController?.pushViewController(SearchViewController(with: (), environment: MastodonUserToken.getLatestUsed()!), animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
