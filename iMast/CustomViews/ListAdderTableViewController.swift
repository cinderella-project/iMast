//
//  ListAdderTableViewController.swift
//  iMast
//
//  Created by user on 2019/04/05.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import Hydra

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
        Promise<Void>.zip(environment.lists(), environment.lists(joinedUser: input)).then { allLists, joinedLists in
            print(allLists, joinedLists)
            let joinedListIds = joinedLists.map { $0.id.string }
            self.lists = allLists.map { (list: $0, isJoined: joinedListIds.contains($0.id.string)) }
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
        var promise: Promise<Void>
        if isOn { // ONになった
            promise = environment.list(list: list, addUserIds: [input.id])
        } else { // OFFになった
            promise = environment.list(list: list, removeUserIds: [input.id])
        }
        target.isEnabled = false
        promise.then {
            self.lists[target.tag].isJoined = isOn
        }.always(in: .main) {
            target.isEnabled = true
        }
    }
}
