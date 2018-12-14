//
//  OtherMenuHelpAndFeedbackTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/10/05.
//  Copyright © 2017年 rinsuki. All rights reserved.
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
