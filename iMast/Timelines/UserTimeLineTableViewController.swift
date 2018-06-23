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
    
    override func loadTimeline() -> Promise<Void>{
        return MastodonUserToken.getLatestUsed()!.getIntVersion().then { version in
            return all([
                version >= MastodonVersionStringToInt("1.6.0rc1")
                    ? MastodonUserToken.getLatestUsed()!.timeline(.user(self.user, pinned: true))
                    : Promise.init(resolved: [] as [MastodonPost])
                , MastodonUserToken.getLatestUsed()!.timeline(.user(self.user))
                ]
            )
        }.then { res -> Void in
            self.pinnedPosts = res[0]
            self._addNewPosts(posts: res[1])
            return Void()
        }
    }
}
