//
//  OtherMenuListsTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/11/22.
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

class ListsTableViewController: UITableViewController, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken
    
    internal var environment: Environment

    var lists: [MastodonList] = []
    
    required init(with input: Input, environment: Environment) {
        self.environment = environment
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L10n.Localizable.lists

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addList)),
        ]
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.refreshList), for: .valueChanged)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func addList() {
        let alert = UIAlertController(
            title: L10n.OtherMenu.Lists.Create.title,
            message: L10n.OtherMenu.Lists.Create.message,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = L10n.OtherMenu.Lists.Create.TextField.Name.placeholder
        }
        alert.addAction(UIAlertAction(title: L10n.OtherMenu.Lists.Create.Actions.primary, style: .default, handler: { _ in
            MastodonEndpoint.CreateList(title: alert.textFields![0].text ?? "").request(with: self.environment).then { list in
                let vc = ListTimelineViewController.instantiate(.plain, environment: self.environment)
                vc.list = list
                vc.title = list.title
                self.navigationController?.pushViewController(vc, animated: true)
                self.refreshList()
            }
        }))
        alert.addAction(UIAlertAction(title: L10n.Localizable.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func refreshList() {
        MastodonEndpoint.MyLists().request(with: environment).then { lists in
            self.lists = lists
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
        let cell = UITableViewCell()

        // Configure the cell...
        let list = self.lists[indexPath.row]
        cell.textLabel?.text = list.title
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = self.lists[indexPath.row]
        let vc = ListTimelineViewController(environment: self.environment)
        vc.list = list
        vc.title = list.title
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
