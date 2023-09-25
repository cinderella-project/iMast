//
//  PostListTableViewController.swift
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

class PostListTableViewController<Input: MastodonEndpointWithPagingProtocol>: UITableViewController, Instantiatable
    where Input.Response == MastodonEndpointResponseWithPaging<[MastodonPost]>
{
    typealias Environment = MastodonUserToken
    var input: Input
    var environment: MastodonUserToken

    enum Section {
        case onlyOne
    }
    
    enum Item: Hashable {
        case post(id: MastodonID)
    }
    
    private var paging = MastodonPaging()
    private var postIds = [MastodonID]()
    private lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [weak self] tableView, indexPath, item -> UITableViewCell? in
        guard let self else { return nil }
        switch item {
        case .post(let id):
            return TableViewCell<MastodonPostWrapperViewController<MastodonPostCellViewController>>.dequeued(
                from: tableView,
                for: indexPath,
                input: (id: id, pinned: false),
                parentViewController: self
            )
        }
    } ※ { d in
        d.defaultRowAnimation = .top
    }
    
    private var readmoreView = ReadmoreView()
    
    required init(with input: Input, environment: MastodonUserToken) {
        self.input = input
        self.environment = environment
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        refreshControl = UIRefreshControl() ※ { c in
//            c.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        }
        
        TableViewCell<MastodonPostWrapperViewController<MastodonPostCellViewController>>.register(to: tableView)
        
        tableView.dataSource = dataSource
        tableView.separatorInset = .zero
        update()
        readmoreView.state = .loading
        readmoreView.target = self
        readmoreView.action = #selector(readmore)
        readmoreView.setTableView(tableView)
        refresh()
    }
    
    @objc func refresh() {
        refreshControl?.beginRefreshing()
        var request = input
        request.paging = paging.prev
        request
            .request(with: environment)
            .then { res in
                try res.content.forEach { try self.environment.memoryStore.post.change(obj: $0) }
                if self.postIds.count == 0 {
                    self.paging.next = res.paging.next
                }
                self.postIds.insert(contentsOf: res.content.map { $0.id }, at: 0)
                self.paging.override(with: res.paging.prev)
                self.update()
            }.catch { e in
                self.readmoreView.lastError = e
                self.readmoreView.state = .withError
            }.always(in: .main) {
                self.refreshControl?.endRefreshing()
            }
    }
    
    @objc func readmore() {
        guard let next = paging.next else { return }
        readmoreView.state = .loading
        var request = input
        request.paging = next
        request.request(with: environment).then { res in
            try res.content.forEach { try self.environment.memoryStore.post.change(obj: $0) }
            self.postIds.append(contentsOf: res.content.map { $0.id })
            self.paging.next = res.paging.next
            self.update()
        }.catch { e in
            self.readmoreView.lastError = e
            self.readmoreView.state = .withError
        }
    }
    
    func update() {
        var snapshot = dataSource.plainSnapshot()
        snapshot.appendSections([.onlyOne])
        snapshot.appendItems(postIds.map { .post(id: $0) })
        readmoreView.state = self.paging.next == nil ? .allLoaded : .moreLoadable
        dataSource.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .post(let id):
            guard let post = environment.memoryStore.post.container[id] else { return }
            let postDetailVC = MastodonPostDetailViewController.instantiate(post, environment: self.environment)
            self.navigationController?.pushViewController(postDetailVC, animated: true)
        }
    }
}
