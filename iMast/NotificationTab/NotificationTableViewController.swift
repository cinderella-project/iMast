//
//  NotificationTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/30.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationTableViewController: UITableViewController {

    var notifications:[MastodonNotification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        MastodonUserToken.getLatestUsed()?.getNoficitaions().then { notifications in
            self.notifications = notifications
            self.tableView.reloadData()
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(self.refreshNotification), for: UIControlEvents.valueChanged)
        }
        
        tableView.rowHeight = 56
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
        return notifications.count
    }
    
    @objc func refreshNotification() {
        MastodonUserToken.getLatestUsed()?.getNoficitaions(sinceId: notifications.safe(0)?.id).then({ new_notifications in
            new_notifications.reversed().forEach({ (notify) in
                self.notifications.insert(notify, at: 0)
            })
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = self.notifications[indexPath[1]]

        // Configure the cell...
        
        switch notification.type {
        case "favourite":
            let cell = tableView.dequeueReusableCell(withIdentifier: "favourite", for: indexPath)
            guard let account = notification.account else { break }
            guard let status = notification.status else { break }
            (cell.viewWithTag(1) as! UILabel).text = "@\(account.acct)さんにふぁぼられました"
            (cell.viewWithTag(2) as! UILabel).text = status.status.pregReplace(pattern: "<.+?>", with: "")
            return cell
        case "reblog":
            guard let account = notification.account else { break }
            guard let status = notification.status else { break }
            let cell = tableView.dequeueReusableCell(withIdentifier: "reblog", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = "@\(account.acct)さんにブーストされました"
            (cell.viewWithTag(2) as! UILabel).text = status.status.pregReplace(pattern: "<.+?>", with: "")
            return cell
        case "follow":
            guard let account = notification.account else { break }
            let cell = tableView.dequeueReusableCell(withIdentifier: "follow", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = "@\(account.acct)さんにフォローされました"
            (cell.viewWithTag(2) as! UILabel).text = (account.name == "" ? account.name : account.screenName).emojify()
            return cell
        case "mention":
            guard let account = notification.account else { break }
            guard let status = notification.status else { break }
            let cell = tableView.dequeueReusableCell(withIdentifier: "mention", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = "@\(account.acct)さんからのリプライ"
            (cell.viewWithTag(2) as! UILabel).text = status.status.pregReplace(pattern: "<.+?>", with: "")
            return cell
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "unknown", for: indexPath)
        (cell.viewWithTag(1) as! UILabel).text = notification.type
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = self.notifications[indexPath[1]]
        guard let account = notification.account else {
            return
        }
        if let status = notification.status { // 投稿つき
            if notification.type == "mention" {
                let storyboard = UIStoryboard(name: "MastodonPostDetail", bundle: nil)
                let newVC = storyboard.instantiateInitialViewController() as! MastodonPostDetailTableViewController
                newVC.load(post: status)
                self.navigationController?.pushViewController(newVC, animated: true)
                return
            }
            let newVC = PostAndUserViewController(style: .grouped)
            newVC.posts = [status]
            newVC.users = [account]
            newVC.title = [
                "favourite": "ふぁぼられ",
                "reblog": "ブースト"
            ][notification.type]
            self.navigationController?.pushViewController(newVC, animated: true)

        } else { // ユーザーつき
            let newVC = openUserProfile(user: account)
            self.navigationController?.pushViewController(newVC, animated: true)
        }
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
