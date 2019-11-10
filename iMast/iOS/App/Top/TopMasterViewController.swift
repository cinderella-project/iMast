//
//  TopMasterViewController.swift
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
import iMastiOSCore

class TopMasterViewController: UITableViewController {
    private var userTokens = MastodonUserToken.getAllUserTokens()

    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "iMast"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return userTokens.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let userToken = userTokens[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = userToken.name ?? ""
            cell.detailTextLabel?.text = "@\(userToken.acct) (via \(userToken.app.name))"
            cell.accessoryType = .disclosureIndicator
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = R.string.localizable.settings()
                cell.accessoryType = .disclosureIndicator
                return cell
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let userToken = userTokens[indexPath.row]
            navigationController?.pushViewController(
                TopAccountMasterViewController.instantiate(environment: userToken),
                animated: true
            )
        case 1:
            switch indexPath.row {
            case 0:
                showDetailViewController(UINavigationController(rootViewController: SettingsViewController()), sender: self)
            default:
                break
            }
        default:
            break
        }
    }
}
