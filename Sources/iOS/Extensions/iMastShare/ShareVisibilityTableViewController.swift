//
//  ShareVisibilityTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/08/03.
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
import iMastiOSCore

class ShareVisibilityTableViewController: UITableViewController {
    var parentVC: ShareViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "公開範囲"
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MastodonPostVisibility.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        // Configure the cell...
        
        let visibility = MastodonPostVisibility.allCases[indexPath.row]
        cell.textLabel?.text = visibility.localizedName
        cell.detailTextLabel?.text = visibility.localizedDescription
        cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        if visibility == parentVC.visibility {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentVC.visibility = MastodonPostVisibility.allCases[indexPath.row]
        tableView.reloadData()
    }
}
