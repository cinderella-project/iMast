//
//  LocalTimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Hydra

class LocalTimeLineTableViewController: TimeLineTableViewController {
    
    override func loadTimeline() -> Promise<Void>{
        return Promise<Void>() { resolve, reject in
            MastodonUserToken.getLatestUsed()?.get("timelines/public?local=true").then { (res: JSON) in
                if (res.array != nil) {
                    self._addNewPosts(posts: res.arrayValue)
                }
                resolve()
            }
        }
    }
    
    override func refreshTimeline() {
        MastodonUserToken.getLatestUsed()?.get("timelines/public?local=true&limit=40&since_id="+(self.posts.count >= 1 ? self.posts[0]["id"].stringValue : "")).then { (res: JSON) in
            self.addNewPosts(posts: res.arrayValue)
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func readMoreTimeline() {
        MastodonUserToken.getLatestUsed()?.get("timelines/public?local=true&limit=40&max_id="+self.posts[self.posts.count-1]["id"].stringValue).then { (res: JSON) in
            if (res.array != nil) {
                print(res.array)
                self.appendNewPosts(posts: res.arrayValue)
                self.isReadmoreLoading = false
            }
        }
    }
    
    override func websocketEndpoint() -> String? {
        return "public:local"
    }
}
