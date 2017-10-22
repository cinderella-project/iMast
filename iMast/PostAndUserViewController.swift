//
//  PostAndUserViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/08/20.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON

class PostAndUserViewController: TimeLineTableViewController {
    
    var users: [JSON] = []
    
    override func viewDidLoad() {
        pleaseNotSettingPostViewHeight = true
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return posts.count
        } else if section == 1 {
            return users.count
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath[0] == 0 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            return cell
        }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "user_"+users[indexPath[1]]["acct"].stringValue)
        cell.textLabel?.text = users[indexPath[1]]["display_name"].string
        cell.detailTextLabel?.text = "@" + users[indexPath[1]]["acct"].stringValue
        getImage(url: users[indexPath[1]]["avatar_static"].stringValue).then(in: .main) { (image) in
            cell.imageView?.image = image
            cell.setNeedsLayout()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath[0] == 0 { // post
            let post = self.posts[indexPath[1]]
            let storyboard = UIStoryboard(name: "MastodonPostDetail", bundle: nil)
            // let newVC = storyboard.instantiateViewController(withIdentifier: "topVC") as! UserProfileTopViewController
            let newVC = storyboard.instantiateInitialViewController() as! MastodonPostDetailTableViewController
            if !post["reblog"].isEmpty {
                newVC.load(post: post["reblog"])
            } else {
                newVC.load(post: post)
            }
            self.navigationController?.pushViewController(newVC, animated: true)
        } else if indexPath[0] == 1 { // user
            let user = self.users[indexPath[1]]
            let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
            // let newVC = storyboard.instantiateViewController(withIdentifier: "topVC") as! UserProfileTopViewController
            let newVC = storyboard.instantiateInitialViewController() as! UserProfileTopViewController
            newVC.load(user: user)
            self.navigationController?.pushViewController(newVC, animated: true)
            
        }
    }
}
