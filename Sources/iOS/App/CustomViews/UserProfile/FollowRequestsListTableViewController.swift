//
//  FollowRequestsListTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/12/30.
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
import SDWebImage
import Mew
import iMastiOSCore

class FollowRequestsListTableViewController: UITableViewController, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken
    internal let environment: Environment
    
    required init(with input: Input, environment: Environment) {
        self.environment = environment
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var followRequests: [MastodonAccount] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "フォローリクエスト一覧"
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        self.refreshControl?.beginRefreshing()
        MastodonEndpoint.FollowRequests.List()
            .request(with: environment)
            .then { res in
                self.followRequests = res.content
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
        return followRequests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        let request = self.followRequests[indexPath.row]
        
        cell.textLabel?.text = request.name
        if (cell.textLabel?.text ?? "") == "" {
            cell.textLabel?.text = request.acct
        }
        cell.detailTextLabel?.text = "@\(request.acct)"
        cell.imageView?.loadImage(from: URL(string: request.avatarUrl)) {
            cell.setNeedsLayout()
        }
        cell.imageView?.ignoreSmartInvert()

        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = self.followRequests[indexPath.row]
        let authorizeAction = UIContextualAction(style: .normal, title: "許可") { _, _, completionHandler in
            Task { @MainActor in
                do {
                    try await MastodonEndpoint.FollowRequests.Judge(target: user, judge: .authorize).request(with: self.environment)
                    self.refresh()
                    completionHandler(true)
                } catch {
                    self.errorReport(error: error)
                    completionHandler(false)
                }
            }
        }
        authorizeAction.backgroundColor = .systemGreen
        let rejectAction = UIContextualAction(style: .destructive, title: "拒否") { _, _, completionHandler in
            Task { @MainActor in
                do {
                    try await MastodonEndpoint.FollowRequests.Judge(target: user, judge: .reject).request(with: self.environment)
                    self.refresh()
                    completionHandler(true)
                } catch {
                    self.errorReport(error: error)
                    completionHandler(false)
                }
            }
        }
        return .init(actions: [rejectAction, authorizeAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newVC = UserProfileTopViewController.instantiate(self.followRequests[indexPath.row], environment: self.environment)
        self.navigationController?.pushViewController(newVC, animated: true)
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
