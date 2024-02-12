//
//  HashtagTimelineViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/10/27.
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
import Mew
import iMastiOSCore

class HashtagTimelineViewController: TimelineViewController {
    let hashtag: String
    
    init(hashtag: String, environment: MastodonUserToken) {
        self.hashtag = hashtag
        super.init(with: .plain, environment: environment)
        self.timelineType = .hashtag(hashtag)
        self.title = "#" + hashtag
        self.isNewPostAvailable = true
    }
    
    override func processNewPostVC(userActivity: NSUserActivity) {
        userActivity.newPostSuffix = " #\(hashtag)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(with input: Input = .plain, environment: Environment) {
        fatalError("init(with:environment:) has not been implemented")
    }
    
    var originalBack: UIBarButtonItem?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let vcs = self.navigationController?.viewControllers, let beforeVC = vcs.safe(vcs.count - 2) {
            originalBack = beforeVC.navigationItem.backBarButtonItem
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            beforeVC.navigationItem.backBarButtonItem = backButton
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let vcs = self.navigationController?.viewControllers, let beforeVC = vcs.last {
            beforeVC.navigationItem.backBarButtonItem = originalBack
        }
    }

    override func websocketEndpoint() -> String? {
        var charset = CharacterSet.urlPathAllowed
        charset.insert("/")
        let tagEncoded = self.hashtag.addingPercentEncoding(withAllowedCharacters: charset)!
        return "hashtag&tag=\(tagEncoded)"
    }
}
