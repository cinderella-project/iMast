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
import Mew
import iMastiOSCore
import SwiftUI

class OtherMenuViewController: UIViewController, Instantiatable, UITableViewDelegate {
    typealias Input = Void
    typealias Environment = MastodonUserToken

    internal let environment: Environment
    
    enum Section {
        case one
    }
    
    enum Item {
        case switchActiveAccount
        case myProfile
        case lists
        case bookmarks
        case settings
        case helpAndFeeddback
        case aboutThisApp
    }
    
    private lazy var searchResultViewController = SearchViewController.instantiate(environment: self.environment)
    private lazy var searchController = UISearchController(searchResultsController: self.searchResultViewController)
    private let tableView = UITableView()
    private lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        guard let self else {
            return nil
        }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        switch itemIdentifier {
        case .switchActiveAccount:
            cell.textLabel?.text = L10n.Localizable.switchActiveAccount
            cell.detailTextLabel?.text = L10n.Localizable.currentAccount(environment.acct)
        case .myProfile:
            cell.textLabel?.text = L10n.Localizable.myProfile
        case .lists:
            cell.textLabel?.text = L10n.Localizable.lists
        case .bookmarks:
            cell.textLabel?.text = L10n.Localizable.bookmarks
        case .settings:
            cell.textLabel?.text = L10n.Localizable.settings
        case .helpAndFeeddback:
            cell.textLabel?.text = L10n.Localizable.helpAndFeedback
        case .aboutThisApp:
            cell.textLabel?.text = L10n.Localizable.AboutThisApp.title
        }
        
        return cell
    }
    
    required init(with input: Input, environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        self.title = L10n.Localizable.other
        super.viewDidLoad()
        
        var snapshot = dataSource.plainSnapshot()
        snapshot.appendSections([.one])
        snapshot.appendItems([
            .switchActiveAccount,
            .myProfile,
            .lists,
            .bookmarks,
            .settings,
            .helpAndFeeddback,
            .aboutThisApp,
        ])
        dataSource.apply(snapshot, animatingDifferences: false)
        tableView.delegate = self
        
        navigationItem.searchController = searchController
        searchResultViewController.searchBar = searchController.searchBar
        searchResultViewController.presentor = self
        searchController.delegate = searchResultViewController
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item {
        case .switchActiveAccount:
            navigationController?.pushViewController(ChangeActiveAccountViewController(), animated: true)
        case .myProfile:
            MastodonEndpoint.GetMyProfile()
                .request(with: self.environment)
                .then { account in
                    let newVC = UserProfileTopViewController.instantiate(account, environment: self.environment)
                    self.navigationController?.pushViewController(newVC, animated: true)
                }.catch { error in
                    print(error)
                }
        case .lists:
            mastodonVersionBarrier(.list) {
                MastodonEndpoint.MyLists().request(with: self.environment).then({ lists in
                    let vc = ListsTableViewController.instantiate(environment: self.environment)
                    vc.lists = lists
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        case .bookmarks:
            mastodonVersionBarrier(.bookmark) {
                self.navigationController?.pushViewController(BookmarksTableViewController.instantiate(.init(), environment: self.environment), animated: true)
            }
        case .settings:
            navigationController?.pushViewController(NewSettingsViewController(), animated: true)
        case .helpAndFeeddback:
            navigationController?.pushViewController(HelpAndFeedbackTableViewController(), animated: true)
        case .aboutThisApp:
            navigationController?.pushViewController(AboutThisAppViewController(), animated: true)
        }
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
