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
    
    var user: MastodonAccount!
    
    override func loadTimeline() -> Promise<Void>{
        return Promise<Void>() { resolve, reject, _ in
            MastodonUserToken.getLatestUsed()?.getIntVersion().then { version -> Promise<[MastodonPost]> in
                if version >= MastodonVersionStringToInt("1.6.0rc1") { // pinned対応インスタンス
                    return MastodonUserToken.getLatestUsed()!.timeline(.user(self.user, pinned: true))
                } else {
                    return Promise.init(resolved: [])
                }
            }.then { pinned_posts -> Promise<[MastodonPost]> in
                return MastodonUserToken.getLatestUsed()!.timeline(.user(self.user)).then { posts -> [MastodonPost] in
                    self._addNewPosts(posts: posts)
                    return pinned_posts
                }
            }.then({ res in
                self._addNewPosts(posts: res.map({ (post) -> MastodonPost in
                    post.pinned = true
                    return post
                }))
                resolve(Void())
            })
        }
    }
    
    override func refreshTimeline() {
        let latestPost = self.posts.sorted(by: { (a, b) -> Bool in
            return a.createdAt > b.createdAt
        })
        MastodonUserToken.getLatestUsed()?.timeline(.user(user), limit: 40, since: latestPost.count >= 1 ? latestPost[0] : nil).then { res in
            self.addNewPosts(posts: res)
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func readMoreTimeline() {
        MastodonUserToken.getLatestUsed()?.timeline(.user(user), limit: 40, max: self.posts[self.posts.count-1]).then { res in
            self.appendNewPosts(posts: res)
            self.isReadmoreLoading = false
        }
    }
}
