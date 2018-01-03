//
//  NotificationTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/30.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationTableViewController: ThemeableTableViewController {

    var notifications:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        MastodonUserToken.getLatestUsed()?.get("notifications").then({ (notifications) in
            self.notifications = notifications.arrayValue
            self.tableView.reloadData()
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(self.refreshNotification), for: UIControlEvents.valueChanged)
        })
        
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
    
    func refreshNotification() {
        MastodonUserToken.getLatestUsed()?.get("notifications?since_id=%d".format(notifications[0]["id"].intValue)).then({ new_notifications in
            new_notifications.arrayValue.reversed().forEach({ (notify) in
                self.notifications.insert(notify, at: 0)
            })
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = self.notifications[indexPath[1]]

        // Configure the cell...
        
        switch notification["type"].stringValue {
        case "favourite":
            let cell = tableView.dequeueReusableCell(withIdentifier: "favourite", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = "@\(notification["account"]["acct"].stringValue)さんにふぁぼられました"
            (cell.viewWithTag(2) as! UILabel).text = notification["status"]["content"].stringValue.pregReplace(pattern: "<.+?>", with: "")
            return cell
        case "reblog":
            let cell = tableView.dequeueReusableCell(withIdentifier: "reblog", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = "@\(notification["account"]["acct"].stringValue)さんにブーストされました"
            (cell.viewWithTag(2) as! UILabel).text = notification["status"]["content"].stringValue.pregReplace(pattern: "<.+?>", with: "")
            return cell
        case "follow":
            let cell = tableView.dequeueReusableCell(withIdentifier: "follow", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = "@\(notification["account"]["acct"].stringValue)さんにフォローされました"
            (cell.viewWithTag(2) as! UILabel).text = (notification["account"]["display_name"].stringValue == "" ? notification["account"]["username"].stringValue : notification["account"]["display_name"].stringValue).emojify()
            return cell
        case "mention":
            let cell = tableView.dequeueReusableCell(withIdentifier: "mention", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = "@\(notification["account"]["acct"].stringValue)さんからのリプライ"
            (cell.viewWithTag(2) as! UILabel).text = notification["status"]["content"].stringValue.pregReplace(pattern: "<.+?>", with: "")
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unknown", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = notification["type"].string
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = self.notifications[indexPath[1]]
        if !notification["status"].isEmpty { // 投稿つき
            if notification["type"].stringValue == "mention" {
                let storyboard = UIStoryboard(name: "MastodonPostDetail", bundle: nil)
                let newVC = storyboard.instantiateInitialViewController() as! MastodonPostDetailTableViewController
                newVC.load(post: notification["status"])
                self.navigationController?.pushViewController(newVC, animated: true)
                return
            }
            let newVC = PostAndUserViewController(style: .grouped)
            newVC.posts = [notification["status"]]
            newVC.users = [notification["account"]]
            newVC.title = [
                "favourite": "ふぁぼられ",
                "reblog": "ブースト"
            ][notification["type"].stringValue]
            self.navigationController?.pushViewController(newVC, animated: true)

        } else if !notification["account"].isEmpty { // ユーザーつき
            let newVC = openUserProfile(user: notification["account"])
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
