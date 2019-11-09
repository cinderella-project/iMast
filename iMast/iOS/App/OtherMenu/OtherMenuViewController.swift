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
import EurekaFormBuilder
import SafariServices
import SwiftUI
import Mew

class OtherMenuViewController: FormViewController, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken

    internal let environment: Environment
    
    private lazy var searchResultViewController = SearchViewController.instantiate(environment: self.environment)
    private lazy var searchController = UISearchController(searchResultsController: self.searchResultViewController)
    
    private lazy var switchActiveAccountRow = ButtonRow { row in
        row.title = R.string.localizable.switchActiveAccount()
        row.cellStyle = .subtitle
        row.presentationMode = .show(controllerProvider: .callback(builder: { ChangeActiveAccountViewController() }), onDismiss: nil)
        row.cellUpdate { (cell, row) in
            cell.detailTextLabel?.text = R.string.localizable.currentAccount(self.environment.acct)
        }
    }
    
    private lazy var myProfileRow = ButtonRow { row in
        row.title = R.string.localizable.myProfile()
        row.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }
        row.onCellSelection { cell, row in
            self.environment.verifyCredentials().then { account in
                let newVC = UserProfileTopViewController.instantiate(account, environment: self.environment)
                self.navigationController?.pushViewController(newVC, animated: true)
            }.catch { error in
                print(error)
            }
        }
    }
    
    private lazy var listsRow = ButtonRow { row in
        row.title = R.string.localizable.lists()
        row.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }
        row.onCellSelection { cell, row in
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
    }
    
    private lazy var settingsRow = ButtonRow { row in
        row.title = R.string.localizable.settings()
        row.presentationMode = .show(controllerProvider: .callback(builder: { SettingsViewController() }), onDismiss: nil)
    }
    
    private lazy var siriShortcutsRow = ButtonRow { row in
        row.title = "Siri Shortcuts"
        row.presentationMode = .show(controllerProvider: .callback(builder: { CreateSiriShortcutsViewController() }), onDismiss: nil)
    }
    
    private lazy var helpAndFeedbackRow = ButtonRow { row in
        row.title = R.string.localizable.helpAndFeedback()
        row.presentationMode = .show(controllerProvider: .callback(builder: { UIHostingController(rootView: OtherMenuHelpAndFeedbackView()) }), onDismiss: nil)
    }
    
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

        form.append {
            Section {
                switchActiveAccountRow
                myProfileRow
                listsRow
                settingsRow
                siriShortcutsRow
                helpAndFeedbackRow
            }
        }
        
        navigationItem.searchController = searchController
        searchResultViewController.searchBar = searchController.searchBar
        searchResultViewController.presentor = self
        searchController.delegate = searchResultViewController
    }
    
    @objc func openSearch() {
        self.navigationController?.pushViewController(SearchViewController.instantiate(environment: self.environment), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
