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
        case home
        case notifications
        case local
        case homeAndLocal
        case bookmarks
        case list(MastodonList)
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
    var version: Int = 0
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
            async let version = environment.getIntVersion().wait()
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
        snapshot.appendItems([.home, .notifications, .local])
        if version >= MastodonVersionStringToInt("3.3.0") {
            snapshot.appendItems([.homeAndLocal])
        }
        snapshot.appendSections([.dependedByMastodonVersion])
        if version >= MastodonVersionStringToInt("3.1.0") {
            snapshot.appendItems([.bookmarks])
        }
        if lists.count > 0 {
            snapshot.appendSections([.lists])
            snapshot.appendItems(lists.map { .list($0) })
        }
        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: !isFirstUpdate)
        isFirstUpdate = false
    }
    
    func input(_ input: Input) {
    }
    
    @objc func openNewPost() {
        let vc = StoryboardScene.NewPost.initialScene.instantiate()
        vc.userToken = environment
        present(ModalNavigationViewController(rootViewController: vc), animated: true)
    }
    
    func cellProvider(_ tableView: UITableView, indexPath: IndexPath, itemIdentifier: Item) -> UITableViewCell? {
        let cell: UITableViewCell
        switch itemIdentifier {
        case .profile:
            cell = .init(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = environment.name ?? environment.screenName ?? ""
            cell.detailTextLabel?.text = "@" + environment.acct
            cell.imageView?.sd_setImage(with: URL(string: environment.avatarUrl ?? "")) { _, _, _, _ in
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        case .followRequests:
            cell = .init(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.UserProfile.Actions.followRequestsList
        case .home:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.Localizable.HomeTimeline.short
            cell.imageView?.image = UIImage(systemName: "house")
        case .notifications:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.imageView?.image = UIImage(systemName: "bell")
            cell.textLabel?.text = L10n.Localizable.notifications
        case .local:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.imageView?.image = UIImage(systemName: "person.and.person")
            cell.textLabel?.text = L10n.Localizable.LocalTimeline.short
        case .homeAndLocal:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.imageView?.image = UIImage(systemName: "display.2")
            cell.textLabel?.text = "Home + Local"
        case .bookmarks:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.imageView?.image = UIImage(systemName: "bookmark")
            cell.textLabel?.text = L10n.Localizable.bookmarks
        case .list(let list):
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.imageView?.image = UIImage(systemName: "list.bullet")
            cell.textLabel?.text = list.title
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
        case .home:
            let vc = HomeTimelineViewController.instantiate(.plain, environment: environment)
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        case .notifications:
            let vc = NotificationTableWrapperViewController.instantiate(environment: environment)
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        case .local:
            let vc = LocalTimelineViewController.instantiate(.plain, environment: environment)
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        case .homeAndLocal:
            let vc = HomeAndLocalTimelineViewController.instantiate(.plain, environment: environment)
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        case .bookmarks:
            let vc = BookmarksTableViewController.instantiate(.init(), environment: environment)
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        case .list(let list):
            let vc = ListTimelineViewController.instantiate(.plain, environment: environment)
            vc.list = list
            showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        switch item {
        case .list(let list):
            print(list)
            return .init(identifier: nil, previewProvider: nil) { (elements) -> UIMenu? in
                print(elements)
                return .init(children: [
                    UIAction(title: "リストを編集", image: UIImage(systemName: "pencil")) { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.present(
                            ModalNavigationViewController(rootViewController: EditListInfoViewController.instantiate(list, environment: strongSelf.environment)),
                            animated: true, completion: nil
                        )
                    }
                ])
            }
        default:
            return nil
        }
    }
}
