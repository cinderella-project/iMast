//
//  PostAndUserViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/08/20.
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

class PostAndUserViewController: UITableViewController, Instantiatable {
    typealias Input = (posts: [MastodonPost], users: [MastodonAccount])
    typealias Environment = MastodonUserToken
    
    var environment: Environment
    var input: Input
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        TableViewCell<MastodonPostCellViewController>.register(to: self.tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? input.posts.count : input.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // post
            return TableViewCell<MastodonPostCellViewController>.dequeued(
                from: tableView,
                for: indexPath,
                input: .init(post: input.posts[indexPath.row], pinned: false),
                parentViewController: self
            )
        case 1: // user
            return MastodonUserCell.getInstance(user: input.users[indexPath.row])
        default:
            fatalError("unknown indexPath section")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let post = input.posts[indexPath.row]
            let newVC = MastodonPostDetailViewController.instantiate(post.originalPost, environment: self.environment)
            self.navigationController?.pushViewController(newVC, animated: true)
        case 1:
            let user = input.users[indexPath.row]
            let newVC = UserProfileTopViewController.instantiate(user, environment: self.environment)
            self.navigationController?.pushViewController(newVC, animated: true)
        default:
            fatalError("unknown indexPath section")
        }
    }
}
