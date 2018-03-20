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
        super.viewDidLoad()
    }
    
    override func websocketEndpoint() -> String? {
        return "user"
    }
}
