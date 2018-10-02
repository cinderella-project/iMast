//
//  HomeTimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Hydra

class HomeTimeLineTableViewController: TimeLineTableViewController {
    override func viewDidLoad() {
        self.timelineType = .home
        self.navigationItem.title = "ホームタイムライン"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "投稿", style: .plain) { (_) in
            self.navigationController?.pushViewController(R.storyboard.newPost.instantiateInitialViewController()!, animated: true)
        }
        super.viewDidLoad()
    }
    
    override func websocketEndpoint() -> String? {
        return "user"
    }
}
