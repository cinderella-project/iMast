//
//  ListAdderTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2019/04/05.
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

class ListAdderTableViewController: UITableViewController, Instantiatable {
    typealias Input = MastodonAccount
    typealias Environment = MastodonUserToken
    
    var input: Input
    var environment: Environment

    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var lists: [(list: MastodonList, isJoined: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "リストに追加/削除"
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loading), for: .valueChanged)
        refreshControl?.beginRefreshing()
        self.loading()
    }
    
    @objc func loading() {
        // TODO: ON/OFFの処理をしてるときはそれが終わるまで待ちたい
        Task { @MainActor in
            async let allLists = MastodonEndpoint.MyLists().request(with: environment)
            async let joinedLists = MastodonEndpoint.JoinedLists(account: input).request(with: environment)
            let joinedListIds = try await joinedLists.map { $0.id.string }
            let listsInfo = try await allLists.map { (list: $0, isJoined: joinedListIds.contains($0.id.string)) }
            self.lists = listsInfo
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let switchView = UISwitch()
        switchView.tag = indexPath.row
        switchView.isOn = lists[indexPath.row].isJoined
        switchView.addTarget(self, action: #selector(self.tappedSwitchView(target:)), for: .valueChanged)
        cell.accessoryView = switchView
        cell.textLabel?.text = self.lists[indexPath.row].list.title
        return cell
    }
    
    @objc func tappedSwitchView(target: UISwitch) {
        let list = lists[target.tag].list
        let isOn = target.isOn
        target.isEnabled = false
        Task { @MainActor in
            defer {
                DispatchQueue.main.async {
                    target.isEnabled = true
                }
            }
            if isOn {
                _ = try await MastodonEndpoint.AddAccountsToList(list: list, accounts: [self.input]).request(with: self.environment)
            } else {
                _ = try await MastodonEndpoint.DeleteAccountsFromList(list: list, accounts: [self.input]).request(with: self.environment)
            }
            self.lists[target.tag].isJoined = isOn
        }
    }
}
