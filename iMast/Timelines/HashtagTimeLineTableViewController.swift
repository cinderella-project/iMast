//
//  HashtagTimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/10/27.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit
import Hydra
import SwiftyJSON

class HashtagTimeLineTableViewController: TimeLineTableViewController {
    let hashtag: String
    
    init(hashtag: String) {
        self.hashtag = hashtag
        super.init(style: .plain)
        self.timelineType = .hashtag(hashtag)
        self.title = "#" + hashtag
        self.isNewPostAvailable = true
    }
    
    override func processNewPostVC(newPostVC: NewPostViewController) {
        newPostVC.appendBottomString = " #\(hashtag)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
