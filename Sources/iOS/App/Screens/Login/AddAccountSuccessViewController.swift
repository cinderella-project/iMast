//
//  AddAccountSuccessViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/25.
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
import SwiftyJSON
import SDWebImage
import iMastiOSCore

class AddAccountSuccessViewController: UIViewController {

    @IBOutlet weak var myIconImageView: UIImageView!
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    @IBOutlet weak var toTimelineButton: UIButton!
    
    var userToken: MastodonUserToken!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        welcomeMessageLabel.text = L10n.Login.Welcome.message("@"+userToken.acct)
        toTimelineButton.setTitle(L10n.Login.Welcome.toTimeline, for: .normal)
        if let avatarUrl = self.userToken.avatarUrl {
            myIconImageView.sd_setImage(with: URL(string: avatarUrl))
        }
        myIconImageView.ignoreSmartInvert()
    }
    
    @IBAction func goTimelineTapped(_ sender: Any) {
        changeRootVC(MainTabBarController(with: (), environment: self.userToken), animated: true)
    }
}
