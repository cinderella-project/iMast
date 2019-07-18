//
//  OtherMenuHelpAndFeedbackTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/10/05.
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
import SafariServices
import Eureka
import Alamofire

class OtherMenuHelpAndFeedbackViewController: FormViewController {
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.title = R.string.localizable.helpAndFeedback()
        
        let section = Section()
        section <<< ButtonRow { row in
            row.title = "ヘルプ"
            row.presentationMode = .presentModally(controllerProvider: .callback(builder: { SFSafariViewController(url: URL(string: "https://cinderella-project.github.io/iMast/help/")!) }), onDismiss: nil)
        }
        
        section <<< ButtonRow { row in
            row.title = "Feedback"
            row.presentationMode = .show(controllerProvider: .callback(builder: { FeedbackViewController() }), onDismiss: nil)
        }
        
        section <<< ButtonRow { row in
            row.title = "GitHub Issues"
            row.presentationMode = .presentModally(controllerProvider: .callback(builder: { SFSafariViewController(url: URL(string: "https://github.com/cinderella-project/iMast/issues")!) }), onDismiss: nil)
        }
        
        self.form +++ section
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
