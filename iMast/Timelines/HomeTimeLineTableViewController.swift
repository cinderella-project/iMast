//
//  HomeTimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Hydra

class HomeTimeLineTableViewController: TimeLineTableViewController {
    
    override func loadTimeline() -> Promise<Void>{
        return Promise<Void>() { resolve, reject, _ in
            MastodonUserToken.getLatestUsed()?.timeline(.home).then { res in
                self._addNewPosts(posts: res)
                resolve(Void())
            }
        }
    }
    override func refreshTimeline() {
        MastodonUserToken.getLatestUsed()?.timeline(.home, limit: 40, since: self.posts.count >= 1 ? self.posts[0] : nil).then { res in
            self.addNewPosts(posts: res)
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func readMoreTimeline() {
        MastodonUserToken.getLatestUsed()?.timeline(.home, limit: 40, max: self.posts[self.posts.count-1]).then { res in
            self.appendNewPosts(posts: res)
        }
    }
    
    override func websocketEndpoint() -> String? {
        return "user"
    }
}
