//
//  TopAccountMasterViewController.swift
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
import Mew
import iMastiOSCore

class TopAccountMasterViewController: UITableViewController, Instantiatable, Injectable {
    typealias Input = Void
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    
    enum Section {
        case profile
        case timelines
        case dependedByMastodonVersion
        case lists
    }
    
    enum Item: Hashable {
        case profile
        case followRequests
        case viewDescriptor(CodableViewDescriptor)
        case bookmarks
    }
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(
        tableView: self.tableView, cellProvider: self.cellProvider
    )
    var version: MastodonVersionInt?
    var lists = [MastodonList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.input(input)
        title = environment.acct
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = .init(
            title: L10n.Localizable.post,
            style: .plain,
            target: self, action: #selector(openNewPost)
        )
        
        update()
        Task {
            async let version = environment.getIntVersion()
            async let lists = MastodonEndpoint.MyLists().request(with: environment)
            if let version = try? await version {
                self.version = version
                update()
            }
            if let lists = try? await lists {
                self.lists = lists
                update()
            }
        }
    }
    
    var isFirstUpdate = true
    
    func update() {
        var snapshot = dataSource.plainSnapshot()
        snapshot.appendSections([.profile])
        snapshot.appendItems([.profile, .followRequests])
        snapshot.appendSections([.timelines])
        snapshot.appendItems([.viewDescriptor(.home), .viewDescriptor(.notifications), .viewDescriptor(.local), .viewDescriptor(.federated)])
        if version?.supportingFeature(.multipleStreamOnWebSocket) ?? false {
            snapshot.appendItems([.viewDescriptor(.homeAndLocal)])
        }
        snapshot.appendSections([.dependedByMastodonVersion])
        if version?.supportingFeature(.bookmark) ?? false {
            snapshot.appendItems([.bookmarks])
        }
        if lists.count > 0 {
            snapshot.appendSections([.lists])
            snapshot.appendItems(lists.map { .viewDescriptor(.list(id: $0.id.string, title: $0.title)) })
        }
        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: !isFirstUpdate)
        isFirstUpdate = false
    }
    
    func input(_ input: Input) {
    }
    
    @objc func openNewPost() {
        showAsWindow(userActivity: .init(newPostWithMastodonUserToken: environment), fallback: .modal)
    }
    
    func cellProvider(_ tableView: UITableView, indexPath: IndexPath, itemIdentifier: Item) -> UITableViewCell? {
        let cell: UITableViewCell
        switch itemIdentifier {
        case .profile:
            cell = .init(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = environment.name ?? environment.screenName ?? ""
            cell.detailTextLabel?.text = "@" + environment.acct
            cell.imageView?.loadImage(from: URL(string: environment.avatarUrl ?? "")) {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        case .followRequests:
            cell = .init(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.UserProfile.Actions.followRequestsList
        case .viewDescriptor(let descriptor):
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = descriptor.localizedShortTitle
            cell.imageView?.image = descriptor.systemImage
        case .bookmarks:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.imageView?.image = UIImage(systemName: "bookmark")
            cell.textLabel?.text = L10n.Localizable.bookmarks
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch itemIdentifier {
        case .profile:
            MastodonEndpoint.GetMyProfile().request(with: environment).then { account in
                let newVC = UserProfileTopViewController.instantiate(account, environment: self.environment)
                self.showDetailViewController(UINavigationController(rootViewController: newVC), sender: self)
            }
        case .followRequests:
            let vc = FollowRequestsListTableViewController.instantiate(environment: environment)
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        case .bookmarks:
            let vc = BookmarksTableViewController.instantiate(.init(), environment: environment)
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        case .viewDescriptor(let descriptor):
            let vc = descriptor.createViewController(with: environment)
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        var ourElements: [UIMenuElement] = []
        switch item {
        case .viewDescriptor(let descriptor):
            ourElements.append(UIAction(title: "トップ画面に追加", image: UIImage(systemName: "star")) { [weak self] _ in
                guard let strongSelf = self else { return }
                do {
                    try strongSelf.environment.addPinnedScreen(descriptor: descriptor)
                } catch {
                    strongSelf.errorReport(error: error)
                }
            })
            switch descriptor {
            case .list(id: let id, title: _):
                ourElements.append(UIAction(title: "リストを編集", image: UIImage(systemName: "pencil")) { [weak self] _ in
                    Task {
                        guard let strongSelf = self else { return }
                        do {
                            let list = try await MastodonEndpoint.GetListFromId(id: .string(id)).request(with: strongSelf.environment)
                            await MainActor.run {
                                strongSelf.present(
                                    EditListInfoViewController.instantiate(list, environment: strongSelf.environment),
                                    animated: true, completion: nil
                                )
                            }
                        } catch {
                            await MainActor.run {
                                strongSelf.errorReport(error: error)
                            }
                        }
                    }
                })
            default:
                break
            }
        default:
            break
        }
        if ourElements.count > 0 {
            return .init(identifier: nil, previewProvider: nil) { (elements) -> UIMenu? in
                print(elements)
                return .init(children: ourElements.reversed())
            }
        } else {
            return nil
        }
    }
}
