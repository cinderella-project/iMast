//
//  HomeAndLocalTimelineViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/10/28.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

import UIKit
import iMastiOSCore

class HomeAndLocalTimelineViewController: TimelineViewController {
    override func viewDidLoad() {
        self.navigationItem.title = "Home + Local"
        self.isNewPostAvailable = true
        self.isReadmoreEnabled = true
        self.isRefreshEnabled = false
        super.viewDidLoad()
    }
    
    override func loadTimeline() async throws {
        readmoreView.state = .loading
        async let homePosts =  MastodonEndpoint.GetTimeline(.home).request(with: environment)
        async let localPosts = MastodonEndpoint.GetTimeline(.local).request(with: environment)
        let sources = try await [homePosts, localPosts]
        var lastID: MastodonID?
        for source in sources {
            guard let last = source.last else {
                continue
            }
            guard let lastID_ = lastID else {
                lastID = last.id
                continue
            }
            if lastID_.compare(last.id) == .orderedAscending {
                lastID = last.id
            }
        }
        guard let lastID = lastID else {
            // each array is empty :P
            readmoreView.state = .allLoaded
            return
        }
        let merged = sources.flatMap { $0.filter { $0.id.compare(lastID) == .orderedDescending } }
        var ids: Set<MastodonID> = .init()
        let unique = merged.filter {
            if ids.contains($0.id) {
                return false
            } else {
                ids.update(with: $0.id)
                return true
            }
        }
        self.addNewPosts(posts: unique)
        self.readmoreView.state = .allLoaded
    }
    
    override func websocketEndpoint() -> String? {
        return "user public:local"
    }
}
