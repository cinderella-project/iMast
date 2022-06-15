//
//  TopMasterViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/09.
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

import UIKit
import iMastiOSCore
import SwiftUI

class TopMasterViewController: UITableViewController {
    private var userTokens = MastodonUserToken.getAllUserTokens()

    enum Section {
        case pinned
        case accounts
        case others
    }
    
    enum Item: Hashable {
        case account(accountId: String)
        case addAccount
        case settings
        case settings2
        case helpAndFeedback
        case aboutThisApp
    }
    
    lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: self.tableView, cellProvider: self.cellProvider)

    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "iMast"
        navigationItem.largeTitleDisplayMode = .always
        
        var snapshot = dataSource.plainSnapshot()
        snapshot.appendSections([.accounts, .others])
        snapshot.appendItems(userTokens.map { .account(accountId: $0.id!) }, toSection: .accounts)
        snapshot.appendItems([.addAccount], toSection: .accounts)
        snapshot.appendItems([
            .settings,
            .settings2,
            .helpAndFeedback,
            .aboutThisApp,
        ], toSection: .others)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func cellProvider(_ tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? {
        let cell: UITableViewCell
        switch item {
        case .account(let accountId):
            guard let userToken = userTokens.first(where: { $0.id == accountId }) else {
                return nil
            }
            cell = .init(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = userToken.name ?? ""
            cell.detailTextLabel?.text = "@\(userToken.acct) (via \(userToken.app.name))"
            cell.accessoryType = .disclosureIndicator
        case .addAccount:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "アカウントを追加"
            cell.textLabel?.textColor = view.tintColor
        case .settings:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.Localizable.settings
            cell.accessoryType = .disclosureIndicator
        case .settings2:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.Localizable.settings + " (SwiftUI)"
            cell.accessoryType = .disclosureIndicator
        case .helpAndFeedback:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.Localizable.helpAndFeedback
            cell.accessoryType = .disclosureIndicator
        case .aboutThisApp:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.Localizable.AboutThisApp.title
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .account(let accountId):
            let userToken = userTokens.first(where: { $0.id == accountId })!
            navigationController?.pushViewController(
                TopAccountMasterViewController.instantiate(environment: userToken),
                animated: true
            )
        case .addAccount:
            let vc = AddAccountIndexViewController()
            self.changeRootVC(UINavigationController(rootViewController: vc))
        case .settings:
            showDetailViewController(UINavigationController(rootViewController: SettingsViewController()), sender: self)
        case .settings2:
            showDetailViewController(UINavigationController(rootViewController: NewSettingsViewController()), sender: self)
        case .helpAndFeedback:
            showDetailViewController(UINavigationController(rootViewController: HelpAndFeedbackTableViewController()), sender: self)
        case .aboutThisApp:
            showDetailViewController(UINavigationController(rootViewController: AboutThisAppViewController()), sender: self)
        }
    }
}
