//
//  UserTimelineViewController.swift
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
import iMastiOSCore

class UserTimelineViewController: TimelineViewController {
    override func viewDidLoad() {
        self.timelineType = .user(self.user)
        super.viewDidLoad()
    }
    
    var user: MastodonAccount!
    
    override func loadTimeline() async throws {
        self.readmoreView.state = .loading
        let version = try await environment.getIntVersion()
        async let pinnedPosts = version.supportingFeature(.pinnedPosts)
            ? MastodonEndpoint.GetTimeline(.user(user, pinned: true)).request(with: environment)
            : []
        async let posts = MastodonEndpoint.GetTimeline(.user(user)).request(with: environment)
        var snapshot = self.diffableDataSource.snapshot()
        snapshot.appendItems(try await pinnedPosts.map {
            try environment.memoryStore.post.change(obj: $0)
            return .post(id: $0.id, pinned: true)
        }, toSection: .pinned)
        diffableDataSource.apply(snapshot, animatingDifferences: false, completion: nil)
        self.addNewPosts(posts: try await posts)
        self.readmoreView.state = .moreLoadable
    }
}
