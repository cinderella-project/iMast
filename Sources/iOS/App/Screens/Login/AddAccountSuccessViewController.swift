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
import iMastiOSCore
import Ikemen

class AddAccountSuccessViewController: UIViewController {

    let myIconImageView = UIImageView() ※ { v in
        v.ignoreSmartInvert()
        v.snp.makeConstraints { make in
            make.size.equalTo(120)
        }
    }
    let welcomeMessageLabel = UILabel() ※ { v in
        v.font = .systemFont(ofSize: 21)
        v.numberOfLines = 0
        v.textAlignment = .center
    }
    let toTimelineButton = UIButton(type: .system) ※ { v in
        v.configuration = .filled() ※ { c in
            c.title = L10n.Login.Welcome.toTimeline
            c.titleTextAttributesTransformer = .init { incoming in
                var outgoing = incoming
                outgoing.font = .boldSystemFont(ofSize: UIFont.buttonFontSize)
                return outgoing
            }
            c.cornerStyle = .large
            c.buttonSize = .large
        }
    }
    
    var userToken: MastodonUserToken!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        view.addSubview(myIconImageView)
        myIconImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.centerY.equalTo(view.safeAreaLayoutGuide).dividedBy(2)
        }
        
        view.addSubview(toTimelineButton)
        toTimelineButton.addTarget(self, action: #selector(goTimelineTapped), for: .touchUpInside)
        toTimelineButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.8)
        }
        
        view.addSubview(welcomeMessageLabel)
        welcomeMessageLabel.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        welcomeMessageLabel.text = L10n.Login.Welcome.message("@"+userToken.acct)
        if let avatarUrl = self.userToken.avatarUrl {
            myIconImageView.loadImage(from: URL(string: avatarUrl))
        }
    }
    
    @objc func goTimelineTapped() {
        changeRootVC(Defaults.newFirstScreen ? TopViewController() : MainTabBarController(with: (), environment: self.userToken))
    }
}
