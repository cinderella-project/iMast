//
//  UserTimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/07.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import Hydra
import SwiftyJSON

class UserTimeLineTableViewController: TimeLineTableViewController {
    
    var userId: String = "1"
    
    override func loadTimeline() -> Promise<Void>{
        return Promise<Void>() { resolve, reject in
            MastodonUserToken.getLatestUsed()?.getIntVersion().then { version -> Promise<JSON> in
                if version >= MastodonVersionStringToInt("1.6.0rc1") { // pinned対応インスタンス
                    return MastodonUserToken.getLatestUsed()!.get("accounts/"+self.userId+"/statuses?pinned=1")
                } else {
                    return Promise.init(resolved: JSON.parse("[]"))
                }
            }.then { pinned_posts -> Promise<JSON> in
                return MastodonUserToken.getLatestUsed()!.get("accounts/"+self.userId+"/statuses").then{ (posts) -> JSON in
                    self._addNewPosts(posts: posts.arrayValue)
                    return pinned_posts
                }
            }.then({ (res: JSON) in
                if (res.array != nil) {
                    self._addNewPosts(posts: res.arrayValue.map({ (post_) -> JSON in
                        var post = post_
                        post["pinned"].bool = true
                        return post
                    }))
                }
                resolve()
            })
        }
    }
    
    override func refreshTimeline() {
        let latestPost = self.posts.sorted(by: { (a, b) -> Bool in
            return a["id"].stringValue.parseInt() > b["id"].stringValue.parseInt()
        })
        MastodonUserToken.getLatestUsed()?.get("accounts/"+self.userId+"/statuses?limit=40&since_id="+(latestPost.count >= 1 ? latestPost[0]["id"].stringValue : "")).then { (res: JSON) in
            self.addNewPosts(posts: res.arrayValue)
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func readMoreTimeline() {
        MastodonUserToken.getLatestUsed()?.get("accounts/"+self.userId+"/statuses?limit=40&max_id="+self.posts[self.posts.count-1]["id"].stringValue).then { (res: JSON) in
            if (res.array != nil) {
                print(res.array)
                self.appendNewPosts(posts: res.arrayValue)
                self.isReadmoreLoading = false
            }
        }
    }
}
