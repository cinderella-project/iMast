//
//  UserTimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/07.
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
            snapshot.appendItems(res[0].map {
                self.environment.memoryStore.post.change(obj: $0)
                return .post(id: $0.id, pinned: true)
            }, toSection: .pinned)
            self.diffableDataSource.apply(snapshot, animatingDifferences: false)
            self._addNewPosts(posts: res[1])
            return Void()
        }.catch { e in
            self.readmoreCell.state = .withError
            self.readmoreCell.lastError = e
        }
    }
}
