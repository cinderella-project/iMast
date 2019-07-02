//
//  BunmyakuTableViewController.swift
//  iMast
//
//  Created by user on 2019/07/03.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Hydra

class BunmyakuTableViewController: TimeLineTableViewController {
    var basePost: MastodonPost!
    
    override func viewDidLoad() {
        self.isReadmoreEnabled = false
        self.isRefreshEnabled = false
        super.viewDidLoad()
        self.title = "文脈"
    }
    
    override func loadTimeline() -> Promise<()> {
        self.readmoreCell.state = .loading
        return MastodonUserToken.getLatestUsed()!.context(post: self.basePost).then { res in
            self.readmoreCell.state = .moreLoadable
            self._addNewPosts(posts: res.ancestors + [self.basePost] + res.descendants)
        }.catch { e in
            self.readmoreCell.state = .withError
            self.readmoreCell.lastError = e
        }
    }
}
