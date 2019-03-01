//
//  LocalTimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Hydra

class LocalTimeLineTableViewController: TimeLineTableViewController {
    override func viewDidLoad() {
        self.timelineType = .local
        self.navigationItem.title = R.string.localizable.localTimeline()
        self.isNewPostAvailable = true
        super.viewDidLoad()
    }
    
    override func websocketEndpoint() -> String? {
        return "public:local"
    }
}
