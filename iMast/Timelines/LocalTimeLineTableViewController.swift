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
        return MastodonUserToken.getLatestUsed()!.timeline(.local).then { res in
            self._addNewPosts(posts: res)
        }
    }
    
    override func refreshTimeline() {
        MastodonUserToken.getLatestUsed()!.timeline(.local, limit: 40, since: self.posts.count >= 1 ? self.posts[0] : nil).then { res in
            self.addNewPosts(posts: res)
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func readMoreTimeline() {
        MastodonUserToken.getLatestUsed()!.timeline(.local, limit: 40, max: self.posts[self.posts.count-1]).then { res in
            self.appendNewPosts(posts: res)
            self.isReadmoreLoading = false
        }
    }
    
    override func websocketEndpoint() -> String? {
        return "public:local"
    }
}
