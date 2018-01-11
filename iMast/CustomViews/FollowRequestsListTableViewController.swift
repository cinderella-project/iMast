//
//  FollowRequestsListTableViewController.swift
//  iMast
//
//  Created by user on 2017/12/30.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON

class FollowRequestsListTableViewController: UITableViewController {

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        MastodonUserToken.getLatestUsed()?.followRequests().then { res in
            self.followRequests = res
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
        getImage(url: request.avatarUrl).then { image in
            cell.imageView?.image = image
            cell.setNeedsLayout()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let user = self.followRequests[indexPath.row]
        let authorizeAction = UITableViewRowAction(style: .normal, title: "許可") { _, _ in
            MastodonUserToken.getLatestUsed()?.followRequestAuthorize(target: user).then { res in
                self.refresh()
            }
        }
        authorizeAction.backgroundColor = UIColor.init(red: 0.3, green: 0.95, blue: 0.3, alpha: 1)
        let rejectAction = UITableViewRowAction(style: .destructive, title: "拒否") { _, _ in
            MastodonUserToken.getLatestUsed()?.followRequestReject(target: user).then { res in
                self.refresh()
            }
        }
        return [
            rejectAction,
            authorizeAction
        ]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newVC = openUserProfile(user: self.followRequests[indexPath.row])
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
