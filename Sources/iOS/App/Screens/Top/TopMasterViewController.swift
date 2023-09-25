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
import GRDB

class TopMasterViewController: UITableViewController {
    private var userTokens = MastodonUserToken.getAllUserTokens()
    private var pinnedScreens: [MastodonUserToken.PinnedScreen] = (try? dbQueue.inDatabase(MastodonUserToken.getPinnedScreens)) ?? []
    private var observer: TransactionObserver?
    private var firstUpdated = true

    enum Section {
        case pinned
        case accounts
        case others
    }
    
    enum Item: Hashable {
        case shortcut(id: Int, accountId: String, descriptor: CodableViewDescriptor)
        case account(accountId: String)
        case addAccount
        case settings
        case helpAndFeedback
        case aboutThisApp
    }
    
    class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            switch itemIdentifier(for: indexPath) {
            case .shortcut(id: _, accountId: _, descriptor: _):
                return true
            default:
                return false
            }
        }
        
        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            if let delegate = tableView.delegate as? UITableViewDataSource {
                delegate.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
            }
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            switch editingStyle {
            case .none:
                break
            case .delete:
                switch itemIdentifier(for: indexPath) {
                case .shortcut(id: let id, accountId: _, descriptor: _):
                    do {
                        try MastodonUserToken.removePinnedScreen(id: id)
                    } catch {
                        tableView.viewController?.errorReport(error: error)
                    }
                default:
                    break
                }
            case .insert:
                break
            @unknown default:
                break
            }
        }
    }
    
    lazy var dataSource = DataSource(tableView: self.tableView) { [weak self] (tableView: UITableView, indexPath: IndexPath, item: Item) in
        return self?.cellProvider(tableView, indexPath: indexPath, item: item)
    }

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
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func refresh(animated: Bool) {
        var snapshot = dataSource.plainSnapshot()
        if pinnedScreens.count > 0 {
            snapshot.appendSections([.pinned])
            snapshot.appendItems(pinnedScreens.map { .shortcut(id: $0.id, accountId: $0.userTokenId, descriptor: $0.descriptor) }, toSection: .pinned)
        }
        snapshot.appendSections([.accounts, .others])
        snapshot.appendItems(userTokens.map { .account(accountId: $0.id!) }, toSection: .accounts)
        snapshot.appendItems([.addAccount], toSection: .accounts)
        snapshot.appendItems([
            .settings,
            .helpAndFeedback,
            .aboutThisApp,
        ], toSection: .others)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard observer == nil else {
            // already observing
            return
        }
        
        let observation = ValueObservation.tracking { db in
            print("tracking...")
            return (
                try MastodonUserToken.getAllUserTokens(in: db),
                try MastodonUserToken.getPinnedScreens(in: db)
            )
        }
        
        do {
            observer = try observation.start(in: dbQueue, onChange: { [weak self] (arg0) in
                let (userTokens, pinnedScreens) = arg0
                guard let strongSelf = self else { return }
                strongSelf.userTokens = userTokens
                strongSelf.pinnedScreens = pinnedScreens
                DispatchQueue.mainSafeSync {
                    strongSelf.refresh(animated: !strongSelf.firstUpdated)
                    strongSelf.firstUpdated = false
                }
            })
        } catch {
            errorReport(error: error)
            // rescue
            refresh(animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        observer = nil // stop observe
    }
    
    func cellProvider(_ tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? {
        let cell: UITableViewCell
        switch item {
        case .shortcut(id: let shortcutId, accountId: let accountId, descriptor: let descriptor):
            guard let userToken = userTokens.first(where: { $0.id == accountId }) else {
                return nil
            }
            let position = pinnedScreens.first(where: {  $0.id == shortcutId })?.position
            cell = .init(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = descriptor.localizedShortTitle
            cell.detailTextLabel?.text = "@\(userToken.acct) (via \(userToken.app.name))"
            cell.imageView?.image = descriptor.systemImage
            cell.accessoryType = .disclosureIndicator
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
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        guard case .account(let accountId) = item, let userToken = userTokens.first(where: { $0.id == accountId }) else {
            return nil
        }
        
        return .init() { (elements) -> UIMenu? in
            return .init(children: [
                UIAction(title: "Move To The Top", image: .init(systemName: "arrow.up.to.line.compact")) { _ in
                    // TODO: find a better way to avoid conflicting animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                        userToken.use()
                    }
                },
            ])
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .shortcut(id: _, accountId: _, descriptor: _):
            return .delete
        default:
            return .none
        }
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        } else {
            return sourceIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .shortcut(id: _, accountId: _, descriptor: _):
            return true
//            case .account(accountId: _):
//                return true
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }
        print(sourceIndexPath.row, destinationIndexPath.row)
        let source = dataSource.itemIdentifier(for: sourceIndexPath)
        let dest = dataSource.itemIdentifier(for: destinationIndexPath)
        if
            let source = source, let dest = dest,
            case let .shortcut(id: sourceId, accountId: _, descriptor: _) = source, case let .shortcut(id: destId, accountId: _, descriptor: _) = dest,
            let sourceObj = pinnedScreens.first(where: { $0.id == sourceId }), let destObj = pinnedScreens.first(where: { $0.id == destId })
        {
            do {
                try dbQueue.inDatabase { db in
                    var shouldDefrag = false
                    if destinationIndexPath.row == (pinnedScreens.count - 1) {
                        print("branch: append to bottom")
                        try MastodonUserToken.setPinnedScreenPosition(in: db, id: sourceId, position: destObj.position + 65535.0)
                    } else if destinationIndexPath.row == sourceIndexPath.row - 1 || destinationIndexPath.row == sourceIndexPath.row + 1 {
                        print("branch: swap")
                        try MastodonUserToken.setPinnedScreenPosition(in: db, id: sourceId, position: 0.1)
                        try MastodonUserToken.setPinnedScreenPosition(in: db, id: destId, position: sourceObj.position)
                        try MastodonUserToken.setPinnedScreenPosition(in: db, id: sourceId, position: destObj.position)
                    } else if destinationIndexPath.row == 0 {
                        print("branch: move to first")
                        if destObj.position < 2 {
                            shouldDefrag = true
                        }
                        try MastodonUserToken.setPinnedScreenPosition(in: db, id: sourceId, position: destObj.position / 2)
                    } else if
                        destinationIndexPath.row < sourceIndexPath.row,
                        let previousDest = dataSource.itemIdentifier(for: .init(row: destinationIndexPath.row - 1, section: destinationIndexPath.section)),
                        case let .shortcut(id: previousDestId, accountId: _, descriptor: _) = previousDest,
                        let previousDestObj = pinnedScreens.first(where: { $0.id == previousDestId })
                    {
                        print("branch: calc (move to up)")
                        let diff = (destObj.position - previousDestObj.position)
                        if abs(diff) < 2 {
                            shouldDefrag = true
                        }
                        try MastodonUserToken.setPinnedScreenPosition(in: db, id: sourceId, position: previousDestObj.position + (diff / 2))
                    } else if
                        let nextDest = dataSource.itemIdentifier(for: .init(row: destinationIndexPath.row + 1, section: destinationIndexPath.section)),
                        case let .shortcut(id: nextDestId, accountId: _, descriptor: _) = nextDest,
                        let nextDestObj = pinnedScreens.first(where: { $0.id == nextDestId })
                    {
                        print("branch: calc (move to down)")
                        let diff = (nextDestObj.position - destObj.position)
                        if abs(diff) < 2 {
                            shouldDefrag = true
                        }
                        try MastodonUserToken.setPinnedScreenPosition(in: db, id: sourceId, position: destObj.position + (diff / 2))
                    } else {
                        print("branch: unknown")
                        // TODO: report unknown branch
                    }
                    if shouldDefrag {
                        print("!!DEFRAG!!")
                        try MastodonUserToken.defragPinnedScreens(in: db)
                    }
                }
                pinnedScreens = try dbQueue.inDatabase(MastodonUserToken.getPinnedScreens)
                refresh(animated: true)
            } catch {
                errorReport(error: error)
            }
        }
        print("todo")
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
            self.changeRootVC(AddAccountIndexViewController())
        case .settings:
            showDetailViewController(UINavigationController(rootViewController: NewSettingsViewController()), sender: self)
        case .helpAndFeedback:
            showDetailViewController(UINavigationController(rootViewController: HelpAndFeedbackTableViewController()), sender: self)
        case .aboutThisApp:
            showDetailViewController(UINavigationController(rootViewController: AboutThisAppViewController()), sender: self)
        case .shortcut(id: _, accountId: let accountId, descriptor: let descriptor):
            let userToken = userTokens.first(where: { $0.id == accountId })!
            showDetailViewController(UINavigationController(rootViewController: descriptor.createViewController(with: userToken)), sender: self)
        }
    }
}
