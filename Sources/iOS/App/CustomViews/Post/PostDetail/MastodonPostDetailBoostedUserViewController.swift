//
//  MastodonPostDetailBoostedUserViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by rinsuki on 2019/07/29.
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

import UIKit
import Mew
import Ikemen
import SnapKit
import iMastiOSCore

class MastodonPostDetailBoostedUserViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonAccount
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    
    let boostedLabel = UILabel() ※ { v in
        v.text = "Boosted by"
    }
    
    let iconView = UIImageView() ※ { v in
        v.snp.makeConstraints { make in
            make.size.equalTo(UIFont.systemFontSize * 3)
        }
    }
    
    let nameLabel = UILabel()
    let acctLabel = UILabel()
    var stackView: UIStackView!
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let userTextStackView = UIStackView(arrangedSubviews: [
            nameLabel,
            acctLabel,
        ]) ※ { v in
            v.axis = .vertical
            v.spacing = 2
        }
        
        let userStackView = UIStackView(arrangedSubviews: [
            iconView,
            userTextStackView,
        ]) ※ { v in
            v.axis = .horizontal
            v.alignment = .center
            v.spacing = 4
        }
        
        stackView = UIStackView(arrangedSubviews: [
            boostedLabel,
            userStackView,
        ]) ※ { v in
            v.axis = .vertical
            v.spacing = 4
        }
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.readableContentGuide).inset(8)
        }
        self.input(input)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stackView.snp.makeConstraints { make in
            make.trailing.leading.equalTo(view.superview!.readableContentGuide)
        }
    }
    
    func input(_ input: Input) {
        iconView.sd_setImage(with: URL(string: input.avatarUrl), completed: nil)
        nameLabel.text = input.name
        let userAcctString = NSMutableAttributedString(string: "@\(input.acct)", attributes: [
            .foregroundColor: UIColor.gray,
            ])
        if !input.acct.contains("@") { // acctにhostがない場合は追加する
            userAcctString.append(NSAttributedString(string: "@\(environment.app.instance.hostName)", attributes: [
                .foregroundColor: UIColor.lightGray,
            ]))
        }
        acctLabel.attributedText = userAcctString
    }
}
