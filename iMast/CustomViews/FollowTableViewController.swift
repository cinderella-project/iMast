//
//  FollowTableViewController.swift
//  iMast
//
//  Created by user on 2018/07/28.
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
import ActionClosurable

class FollowTableViewController: UITableViewController {

    let type: MastodonFollowFetchType
    let userId: MastodonID
    let readmoreCell = ReadmoreTableViewCell()
    
    var users: [MastodonAccount] = []
    var maxId: MastodonID?
    
    init(type: MastodonFollowFetchType, userId: MastodonID) {
        self.type = type
        self.userId = userId
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = type == .following ? "フォロー一覧" : "フォロワー一覧"
        self.load()
    }
    
    func load() {
        self.readmoreCell.state = .loading
        MastodonUserToken.getLatestUsed()?.getFollows(target: self.userId, type: self.type, maxId: self.maxId).then { res in
            self.users.append(contentsOf: res.result)
            self.maxId = res.max
            self.readmoreCell.state = res.max == nil ? .allLoaded : .moreLoadable
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? self.users.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if indexPath.section == 0 {
            let user = self.users[indexPath.row]
            let cell = MastodonUserCell.getInstance()
            cell.load(user: user)
            return cell
        } else {
            return self.readmoreCell
        }
        
        // Configure the cell...

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let newVC = openUserProfile(user: self.users[indexPath.row])
            self.navigationController?.pushViewController(newVC, animated: true)
        } else if self.readmoreCell.state == .moreLoadable {
            self.load()
        }
        print(indexPath)
    }
}
