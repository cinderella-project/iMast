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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.timelineToPostButtonTitle(), style: .bordered) { _ in
            let postVC = R.storyboard.newPost.instantiateInitialViewController()!
            postVC.appendBottomString = " #\(hashtag)"
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//

    override func websocketEndpoint() -> String? {
        var charset = CharacterSet.urlPathAllowed
        charset.insert("/")
        let tagEncoded = self.hashtag.addingPercentEncoding(withAllowedCharacters: charset)!
        return "hashtag&tag=\(tagEncoded)"
    }
}
