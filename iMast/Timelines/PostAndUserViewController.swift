//
//  PostAndUserViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/08/20.
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
