//
//  MastodonPostDetailContentViewController.swift
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

class MastodonPostDetailContentViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonPost
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    
    let userIconView = UIImageView() ※ { v in
        v.snp.makeConstraints { make in
            make.width.height.equalTo(UIFont.systemFontSize * 4)
        }
    }
    let userNameLabel = UILabel() ※ { v in
        v.text = String(repeating: "User Name", count: 30)
    }
    let userAcctLabel = UILabel() ※ { v in
        v.text = "@veryl\(String(repeating: "o", count: 30))ng@mastodon.example"
    }
    
    let textView = UITextView() ※ { v in
        v.isScrollEnabled = false
        v.isEditable = false
        v.textContainer.lineFragmentPadding = 0
    }
    
    let userButton = UIButton()
    
    let attachedMediaListViewController: AttachedMediaListViewController

    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        attachedMediaListViewController = .instantiate(input, environment: ())
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let userStackView = UIStackView(arrangedSubviews: [
            userIconView,
            UIStackView(arrangedSubviews: [
                userNameLabel,
                userAcctLabel,
            ]) ※ { v in
                v.axis = .vertical
                v.spacing = 2
            },
        ]) ※ { v in
            v.alignment = .center
            v.spacing = 8
            v.axis = .horizontal
            v.isUserInteractionEnabled = false
        }
        
        userButton.addTarget(self, action: #selector(self.tapUser), for: .touchUpInside)
        userButton.addSubview(userStackView)
        userStackView.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
        }
        
        let stackView = ContainerView(arrangedSubviews: [
            userButton,
            textView,
        ]) ※ { v in
            v.axis = .vertical
            v.addArrangedViewController(attachedMediaListViewController, parentViewController: self)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.readableContentGuide)
            make.top.bottom.equalToSuperview().inset(8)
        }
        self.input(input)
    }
    
    func input(_ input: Input) {
        self.input = input
        let post = input.originalPost
        
        userIconView.sd_setImage(with: URL(string: post.account.avatarUrl), completed: nil)
        userNameLabel.text = post.account.name
        let userAcctString = NSMutableAttributedString(string: "@\(post.account.acct)", attributes: [
            .foregroundColor: UIColor.gray,
        ])
        if !post.account.acct.contains("@") { // acctにhostがない場合は追加する
            userAcctString.append(NSAttributedString(string: "@\(environment.app.instance.hostName)", attributes: [
                .foregroundColor: UIColor.lightGray,
            ]))
        }
        userAcctLabel.attributedText = userAcctString
        
        textView.attributedText = post.status.parseText2HTMLNew(attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
        ])?.emojify(asyncLoadProgressHandler: { [weak textView] in
            textView?.setNeedsDisplay()
        }, emojifyProtocol: input)
        
        attachedMediaListViewController.input(post)
    }
    
    @objc func tapUser() {
        let vc = openUserProfile(user: input.originalPost.account)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
