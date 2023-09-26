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
import iMastiOSCore

class MastodonPostDetailContentViewController: UIViewController, Instantiatable, Injectable, Interactable {
    typealias Input = MastodonPostContentProtocol
    typealias Environment = MastodonUserToken
    typealias Output = Void
    let environment: Environment
    var input: Input
    var handler: ((Output) -> Void)?
    
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
        v.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        v.backgroundColor = .clear
        v.clipsToBounds = true
    }
    
    let userButton = UIButton()
    
    let cwWarningStackView: UIStackView
    let cwWarningLabel = UILabel() ※ { v in
        v.font = UIFont.preferredFont(forTextStyle: .body)
        v.numberOfLines = 0
    }
    let cwToggleButton = UIButton() ※ { v in
        v.layer.cornerRadius = 4
        v.backgroundColor = .systemGray5
        v.setTitleColor(.label, for: .normal)
    }
    
    let attachedMediaListViewController: AttachedMediaListViewController
    
    var showCWContent = false
    var restrictTextViewHeight: NSLayoutConstraint!

    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        attachedMediaListViewController = .instantiate(input, environment: ())
        cwWarningStackView = UIStackView(arrangedSubviews: [
            UIView(/* スペース取り用ダミー*/) ※ { $0.heightAnchor.constraint(equalToConstant: 0).isActive = true },
            cwWarningLabel,
            cwToggleButton,
        ]) ※ { v in
            v.axis = .vertical
            v.spacing = 8
            v.setContentCompressionResistancePriority(.required, for: .vertical)
        }
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
        
        updateCWToggleButton()
        cwToggleButton.addTarget(self, action: #selector(self.tapCWToggle), for: .touchUpInside)
        textView.delegate = self
        restrictTextViewHeight = textView.heightAnchor.constraint(equalToConstant: 8)
        
        let stackView = ContainerView(arrangedSubviews: [
            userButton,
            cwWarningStackView,
            textView,
            UIView() ※ { $0.setContentHuggingPriority(.required, for: .vertical)}, // CWの開閉時のアニメーションをマシにするため
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
        cwWarningLabel.text = input.spoilerText
        updateCWHiddenFlag()
        
        var attrs: [NSAttributedString.Key : Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label,
        ]
        if let post = input as? MastodonPost {
            userIconView.loadImage(from: URL(string: post.account.avatarUrl))
            userNameLabel.text = post.account.name
            let userAcctString = NSMutableAttributedString(string: "@\(post.account.acct)", attributes: [
                .foregroundColor: UIColor.systemGray,
            ])
            if !post.account.acct.contains("@") { // acctにhostがない場合は追加する
                userAcctString.append(NSAttributedString(string: "@\(environment.app.instance.hostName)", attributes: [
                    .foregroundColor: UIColor.systemGray2,
                ]))
            }
            userAcctLabel.attributedText = userAcctString
            if Defaults.usePostLanguageInfo, let lang = post.language {
                attrs[kCTLanguageAttributeName as NSAttributedString.Key] = lang
            }
            userButton.isHidden = false
        } else {
            userButton.isHidden = true
        }
        textView.attributedText = input.status.parseText2HTMLNew(attributes: attrs)?.emojify(asyncLoadProgressHandler: { [weak textView] in
            textView?.setNeedsDisplay()
        }, emojifyProtocol: input)
        
        attachedMediaListViewController.input(input)
    }
    
    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
    
    @objc func tapCWToggle() {
        showCWContent.toggle()
        updateCWHiddenFlag()
        updateCWToggleButton()
        print("hoge", showCWContent)
    }
    
    func updateCWHiddenFlag() {
        if input.spoilerText != "" {
            cwWarningStackView.isHidden = false
            restrictTextViewHeight.isActive = !showCWContent
        } else {
            cwWarningStackView.isHidden = true
            restrictTextViewHeight.isActive = false
        }
        handler?(())
    }
    
    func updateCWToggleButton() {
        if showCWContent {
            cwToggleButton.setTitle("CWの内容を閉じる", for: .normal)
        } else {
            cwToggleButton.setTitle("CWの内容を開く", for: .normal)
        }
    }
    
    @objc func tapUser() {
        guard let post = input as? MastodonPost else {
            return
        }
        let vc = UserProfileTopViewController.instantiate(post.account, environment: environment)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// TODO: リンクを開く処理をMastodonPostCellViewController側と共通化する
extension MastodonPostDetailContentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            var urlString = url.absoluteString
            let visibleString = (textView.attributedText.string as NSString).substring(with: characterRange)
            if let post = input as? MastodonPost, let mention = post.mentions.first(where: { $0.url == urlString }) {
                MastodonEndpoint.GetAccount(target: mention.id)
                    .request(with: environment)
                    .then { [weak self] user in
                        guard let strongSelf = self else { return }
                        let newVC = UserProfileTopViewController.instantiate(user, environment: strongSelf.environment)
                        strongSelf.navigationController?.pushViewController(newVC, animated: true)
                    }
                return false
            }
            if let media = input.attachments.first(where: { $0.textUrl == urlString }) {
                urlString = media.url
            }
            if visibleString.starts(with: "#") {
                let tag = String(visibleString[visibleString.index(after: visibleString.startIndex)...])
                let newVC = HashtagTimelineViewController(hashtag: tag, environment: environment)
                self.navigationController?.pushViewController(newVC, animated: true)
                return false
            }
            self.open(url: URL(string: urlString)!)
            return false
        case .presentActions:
            return true // TODO: メニュー項目に追加できないか検討
        case .preview:
            return false // TODO: 独自プレビュー実装できないか検討
        @unknown default:
            return true
        }
    }
}
