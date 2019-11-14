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
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.input(input)
        title = environment.acct
    }
    
    func input(_ input: Input) {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.imageView?.image = UIImage(systemName: "house")
            cell.textLabel?.text = R.string.localizable.homeTimelineShort()
        case (0, 1):
            cell.imageView?.image = UIImage(systemName: "bell")
            cell.textLabel?.text = R.string.localizable.notifications()
        case (0, 2):
            cell.imageView?.image = UIImage(systemName: "person.and.person")
            cell.textLabel?.text = R.string.localizable.localTimelineShort()
        case (1, 0):
            cell.imageView?.image = UIImage(systemName: "bookmark")
            cell.textLabel?.text = "Bookmarks"
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: UIViewController
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            vc = HomeTimeLineTableViewController.instantiate(.plain, environment: environment)
        case (0, 1):
            vc = NotificationTableViewController.instantiate(environment: environment)
        case (0, 2):
            vc = LocalTimeLineTableViewController.instantiate(.plain, environment: environment)
        case (1, 0):
            vc = BookmarksTimeLineTableViewController.instantiate(.plain, environment: environment)
        default:
            return
        }
        showDetailViewController(UINavigationController(rootViewController:
            vc
        ), sender: self)
    }
}
