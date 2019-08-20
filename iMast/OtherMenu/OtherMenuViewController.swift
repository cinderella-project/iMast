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
import Mew

class OtherMenuViewController: FormViewController, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken

    internal let environment: Environment

    required init(with input: Input, environment: Environment) {
        self.environment = environment
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.title = R.string.localizable.other()
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let section = Section()
        section <<< ButtonRow { row in
            row.title = R.string.localizable.switchActiveAccount()
            row.cellStyle = .subtitle
            row.presentationMode = .show(controllerProvider: .callback(builder: { ChangeActiveAccountViewController() }), onDismiss: nil)
        }.cellSetup { cell, row in
            cell.height = { 44 }
        }.cellUpdate { (cell, row) in
            cell.detailTextLabel?.text = R.string.localizable.currentAccount(self.environment.acct)
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.myProfile()
        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }.onCellSelection { cell, row in
            self.environment.verifyCredentials().then { account in
                let newVC = UserProfileTopViewController.instantiate(account, environment: self.environment)
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
            self.environment.getIntVersion().then { version in
                if version < MastodonVersionStringToInt("2.1.0rc1") {
                    self.alert(title: R.string.localizable.errorTitle(), message: R.string.localizable.errorRequiredNewerMastodon("2.1.0rc1"))
                    return
                }
                self.environment.lists().then({ lists in
                    let vc = ListsTableViewController.instantiate(environment: self.environment)
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
            self.navigationController?.pushViewController(SearchViewController.instantiate(environment: self.environment), animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
