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
    
    var users: [MastodonAccount] = []
    
    override func viewDidLoad() {
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
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return posts.count
        } else if section == 2 {
            return users.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath[0] != 2 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            return cell
        }
        let user = users[indexPath[1]]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "user_"+user.acct)
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = "@" + user.acct
        cell.imageView?.sd_setImage(with: URL(string: user.avatarUrl), completed: { (image, error, cacheType, url) in
            cell.setNeedsLayout()
        })
        cell.imageView?.ignoreSmartInvert()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath[0] == 1 { // post
            let post = self.posts[indexPath[1]]
            // let newVC = storyboard.instantiateViewController(withIdentifier: "topVC") as! UserProfileTopViewController
            let newVC = R.storyboard.mastodonPostDetail.instantiateInitialViewController()!
            newVC.load(post: post.repost ?? post)
            self.navigationController?.pushViewController(newVC, animated: true)
        } else if indexPath[0] == 2 { // user
            let user = self.users[indexPath[1]]
            let newVC = openUserProfile(user: user)
            self.navigationController?.pushViewController(newVC, animated: true)
            
        }
    }
}
