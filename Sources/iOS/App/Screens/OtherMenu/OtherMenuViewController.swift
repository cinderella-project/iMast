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
import Mew
import iMastiOSCore
import SwiftUI

class OtherMenuViewController: FormViewController, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken

    internal let environment: Environment
    
    private lazy var searchResultViewController = SearchViewController.instantiate(environment: self.environment)
    private lazy var searchController = UISearchController(searchResultsController: self.searchResultViewController)
    
    required init(with input: Input, environment: Environment) {
        self.environment = environment
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.title = L10n.Localizable.other
        super.viewDidLoad()

        form.append {
            Section {
                ButtonRow { row in
                    row.title = L10n.Localizable.switchActiveAccount
                    row.cellStyle = .subtitle
                    row.presentationMode = .show(controllerProvider: .callback(builder: { ChangeActiveAccountViewController() }), onDismiss: nil)
                    row.cellUpdate { (cell, row) in
                        cell.detailTextLabel?.text = L10n.Localizable.currentAccount(self.environment.acct)
                    }
                }
                ButtonRow { row in
                    row.title = L10n.Localizable.myProfile
                    row.cellUpdate { cell, row in
                        cell.textLabel?.textAlignment = .left
                        cell.accessoryType = .disclosureIndicator
                        cell.textLabel?.textColor = nil
                    }
                    row.onCellSelection { cell, row in
                        MastodonEndpoint.GetMyProfile()
                            .request(with: self.environment)
                            .then { account in
                                let newVC = UserProfileTopViewController.instantiate(account, environment: self.environment)
                                self.navigationController?.pushViewController(newVC, animated: true)
                            }.catch { error in
                                print(error)
                            }
                    }
                }
                ButtonRow { row in
                    row.title = L10n.Localizable.lists
                    row.cellUpdate { cell, row in
                        cell.textLabel?.textAlignment = .left
                        cell.accessoryType = .disclosureIndicator
                        cell.textLabel?.textColor = nil
                    }
                    row.onCellSelection { [weak self] cell, row in
                        guard let self = self else {
                            return
                        }
                        self.mastodonVersionBarrier(.list) {
                            MastodonEndpoint.MyLists().request(with: self.environment).then({ lists in
                                let vc = ListsTableViewController.instantiate(environment: self.environment)
                                vc.lists = lists
                                self.navigationController?.pushViewController(vc, animated: true)
                            })
                        }
                    }
                }
                ButtonRow { row in
                    row.title = L10n.Localizable.bookmarks
                    row.cellUpdate { cell, row in
                        cell.textLabel?.textAlignment = .left
                        cell.accessoryType = .disclosureIndicator
                        cell.textLabel?.textColor = nil
                    }
                    row.onCellSelection { [weak self] cell, row in
                        guard let self = self else {
                            return
                        }
                        self.mastodonVersionBarrier(.bookmark) {
                            self.navigationController?.pushViewController(BookmarksTableViewController.instantiate(.init(), environment: self.environment), animated: true)
                        }
                    }
                }
                ButtonRow { row in
                    row.title = L10n.Localizable.settings
                    row.presentationMode = .show(controllerProvider: .callback(builder: { NewSettingsViewController() }), onDismiss: nil)
                }
                ButtonRow { row in
                    row.title = L10n.Localizable.helpAndFeedback
                    row.presentationMode = .show(controllerProvider: .callback(builder: { HelpAndFeedbackTableViewController() }), onDismiss: nil)
                }
                ButtonRow { row in
                    row.title = L10n.Localizable.AboutThisApp.title
                    row.presentationMode = .show(controllerProvider: .callback(builder: { AboutThisAppViewController() }), onDismiss: nil)
                }
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

    func mastodonVersionBarrier(_ feature: MastodonVersionFeature, callback: @escaping () -> Void) {
        Task {
            do {
                async let currentVersion = self.environment.getIntVersion()
                if !(try await currentVersion.supportingFeature(feature)) {
                    await MainActor.run {
                        self.alert(
                            title: L10n.Localizable.Error.title,
                            message: L10n.Localizable.Error.requiredNewerMastodon(feature.readableString)
                        )
                    }
                    return
                }
            } catch {
                await MainActor.run {
                    self.errorReport(error: error)
                }
            }
            await MainActor.run(body: callback)
        }
    }
}
