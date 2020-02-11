//
//  BookmarksTimeLineTableViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/14.
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
import Mew
import Ikemen

class BookmarksTimeLineTableViewController: UITableViewController, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken
    var environment: MastodonUserToken

    enum Section {
        case onlyOne
    }
    
    enum Item: Hashable {
        case post(id: MastodonID)
        case readMore
    }
    
    private var paging = MastodonPaging()
    private var postIds = [MastodonID]()
    private lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { tableView, indexPath, item -> UITableViewCell? in
        switch item {
        case .post(let id):
            return TableViewCell<MastodonPostWrapperViewController<MastodonPostCellViewController>>.dequeued(
                from: tableView,
                for: indexPath,
                input: (id: id, pinned: false),
                parentViewController: self
            )
        case .readMore:
            return self.readmoreCell
        }
    } ※ { d in
        d.defaultRowAnimation = .top
    }
    
    private var readmoreCell = ReadmoreTableViewCell()
    
    required init(with input: Void, environment: MastodonUserToken) {
        self.environment = environment
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Localizable.bookmarks
//        refreshControl = UIRefreshControl() ※ { c in
//            c.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        }
        
        TableViewCell<MastodonPostWrapperViewController<MastodonPostCellViewController>>.register(to: tableView)
        
        tableView.dataSource = dataSource
        update()
        readmoreCell.state = .loading
        refresh()
    }
    
    @objc func refresh() {
        refreshControl?.beginRefreshing()
        environment.requestWithPagingInfo(ep: MastodonEndpoint.GetBookmarks(paging: paging.prev)).then { (res, paging) in
            res.forEach { self.environment.memoryStore.post.change(obj: $0) }
            if self.postIds.count == 0 {
                self.paging.next = paging.next
            }
            self.postIds.insert(contentsOf: res.map { $0.id }, at: 0)
            self.paging.override(with: paging.prev)
            self.refreshControl?.endRefreshing()
            self.update()
        }
    }
    
    func readmore() {
        guard let next = paging.next else { return }
        readmoreCell.state = .loading
        environment.requestWithPagingInfo(ep: MastodonEndpoint.GetBookmarks(paging: next)).then { (res, paging) in
            res.forEach { self.environment.memoryStore.post.change(obj: $0) }
            self.postIds.append(contentsOf: res.map { $0.id })
            self.paging.next = paging.next
            self.update()
        }
    }
    
    func update() {
        var snapshot = dataSource.plainSnapshot()
        snapshot.appendSections([.onlyOne])
        snapshot.appendItems(postIds.map { .post(id: $0) })
        snapshot.appendItems([.readMore])
        self.readmoreCell.state = self.paging.next == nil ? .allLoaded : .moreLoadable
        dataSource.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .post(let id):
            guard let post = environment.memoryStore.post.container[id] else { return }
            let postDetailVC = MastodonPostDetailViewController.instantiate(post, environment: self.environment)
            self.navigationController?.pushViewController(postDetailVC, animated: true)
        case .readMore:
            readmoreCell.readMoreTapped(viewController: self) {
                readmore()
            }
        }
    }
}
