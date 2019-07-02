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
    override func viewDidLoad() {
        self.timelineType = .user(self.user)
        super.viewDidLoad()
    }
    
    var user: MastodonAccount!
    
    override func loadTimeline() -> Promise<Void> {
        self.readmoreCell.state = .loading
        return MastodonUserToken.getLatestUsed()!.getIntVersion().then { version -> Promise<[[MastodonPost]]> in
            let pinnedPostPromise = version >= MastodonVersionStringToInt("1.6.0rc1")
                ? MastodonUserToken.getLatestUsed()!.timeline(.user(self.user, pinned: true))
                : Promise.init(resolved: [] as [MastodonPost])
            return all([
                pinnedPostPromise,
                MastodonUserToken.getLatestUsed()!.timeline(.user(self.user)),
            ])
        }.then { res -> Void in
            self.readmoreCell.state = .moreLoadable
            let snapshot = self.diffableDataSource.snapshot()
            snapshot.appendItems(res[0].map { .post(content: $0, pinned: true) }, toSection: .pinned)
            self.diffableDataSource.apply(snapshot, animatingDifferences: false)
            self._addNewPosts(posts: res[1])
            return Void()
        }.catch { e in
            self.readmoreCell.state = .withError
            self.readmoreCell.lastError = e
        }
    }
}
