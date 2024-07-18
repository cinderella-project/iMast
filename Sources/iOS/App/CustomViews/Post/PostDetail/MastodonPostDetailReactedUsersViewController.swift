//
//  MastodonPostDetailReactedUsersViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2024/07/18.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

class MastodonPostDetailReactedUsersViewController: UITableViewController, Instantiatable {
    typealias Input = (type: MastodonReactionType, post: MastodonPost)
    typealias Environment = MastodonUserToken
    
    private var input: Input
    internal let environment: Environment

    let readmoreView = ReadmoreView()
    
    var users: [MastodonAccount] = []
    var paging: MastodonPagingOption? {
        didSet {
            readmoreView.state = paging == nil ? .allLoaded : .moreLoadable
        }
    }
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = input.type == .boost ? L10n.Localizable.PostDetail.boost : L10n.Localizable.PostDetail.favorite
        readmoreView.target = self
        readmoreView.action = #selector(readMore)
        readmoreView.setTableView(tableView)
        tableView.tableFooterView = readmoreView
        Task {
            await load()
        }
    }
    
    @MainActor func load(paging: MastodonPagingOption? = nil) async {
        self.readmoreView.state = .loading
        do {
            let res = try await MastodonEndpoint.GetPostReactedUsers(
                post: input.post,
                type: input.type,
                paging: paging
            ).request(with: environment)
            users.append(contentsOf: res.content)
            self.paging = res.paging.next
            readmoreView.state = res.paging.next == nil ? .allLoaded : .moreLoadable
            tableView.reloadData()
        } catch {
            readmoreView.state = .withError
            readmoreView.lastError = error
        }
    }

    @objc func readMore() {
        guard readmoreView.state == .moreLoadable else {
            return
        }
        Task {
            await load(paging: paging)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.users[indexPath.row]
        let cell = MastodonUserCell.getInstance()
        cell.load(user: user)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let newVC = UserProfileTopViewController.instantiate(self.users[indexPath.row], environment: self.environment)
        navigationController?.pushViewController(newVC, animated: true)
    }
}
