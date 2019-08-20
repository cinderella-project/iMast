//
//  MastodonPostCellViewController.swift
//  iMast
//
//  Created by rinsuki on 2019/03/11.
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
import Mew
import SnapKit
import Ikemen

class MastodonPostCellViewController: UIViewController, Instantiatable, Injectable {
    struct Input {
        var post: MastodonPost
        var pinned: Bool = false
    }
    
    typealias Environment = MastodonUserToken

    var environment: MastodonUserToken
    var input: Input
    
    var iconWidthConstraint: NSLayoutConstraint!
    let iconView = UIImageView() ※ { v in
        v.snp.makeConstraints { make in
            make.width.equalTo(v.snp.height)
        }
        v.ignoreSmartInvert()
        v.isUserInteractionEnabled = true
    }
    
    let userNameLabel = UILabel() ※ { v in
        v.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        v.setContentCompressionResistancePriority(UILayoutPriority(248), for: .horizontal)
    }
    let acctNameLabel = UILabel() ※ { v in
        v.setContentHuggingPriority(UILayoutPriority(248), for: .horizontal)
        v.setContentCompressionResistancePriority(UILayoutPriority(249), for: .horizontal)
        v.alpha = 0.5
    }
    
    let createdAtLabel = UILabel()
    let pinnedLabel = UILabel() ※ { v in
        v.text = "📌"
    }
    let isReplyTreeLabel = UILabel() ※ { v in
        v.text = "💬"
    }
    let visibilityLabel = UILabel()
    
    let textView = NotSelectableTextView() ※ { v in
        v.backgroundColor = nil
        v.isScrollEnabled = false
        v.isEditable = false
        v.textContainerInset = .zero
        v.textContainer.lineFragmentPadding = 0
    }
    let tootInfoView = UIView() ※ { v in
        v.backgroundColor = ColorSet.boostedBar
        v.ignoreSmartInvert()
        v.snp.makeConstraints { make in
            make.width.equalTo(3)
        }
    }
    let boostedIconView = UIImageView()
    let attachedMediaListViewContrller: AttachedMediaListViewController
    
    let isBoostedView = UIView() ※ { v in
        v.backgroundColor = ColorSet.boostedBar
        v.ignoreSmartInvert()
    }
    let isFavouritedView = UIView() ※ { v in
        v.backgroundColor = ColorSet.favouriteBar
        v.ignoreSmartInvert()
    }
    
    required init(with input: Input, environment: Environment) {
        self.environment = environment
        self.input = input
        self.attachedMediaListViewContrller = AttachedMediaListViewController(with: input.post, environment: Void())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // layout
        self.view.addSubview(iconView)
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.iconTapped)))
        iconWidthConstraint = iconView.widthAnchor.constraint(equalToConstant: 64) ※ {
            $0.isActive = true
        }
        iconView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        iconView.addSubview(boostedIconView)
        boostedIconView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.5)
        }

        let userStackView = UIStackView(arrangedSubviews: [
            userNameLabel,
            acctNameLabel,
            UIStackView(arrangedSubviews: [
                isReplyTreeLabel,
                visibilityLabel,
                pinnedLabel,
                createdAtLabel,
            ]) ※ {
                $0.axis = .horizontal
            }
        ]) ※ {
            $0.spacing = 6
            $0.axis = .horizontal
        }
        
        let topStackView = ContainerView(arrangedSubviews: [
            userStackView,
            textView,
        ]) ※ {
            $0.addArrangedViewController(attachedMediaListViewContrller, parentViewController: self)
            $0.axis = .vertical
            $0.spacing = 2
        }
        self.view.addSubview(topStackView)
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.trailing.equalToSuperview().offset(-8)
            make.leading.equalTo(iconView.snp.trailing).offset(8)
        }
        
        self.view.addSubview(tootInfoView)
        tootInfoView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        let actionStatusStackView = UIStackView(arrangedSubviews: [
            isBoostedView,
            isFavouritedView,
        ])  ※ {
            $0.axis = .vertical
            $0.distribution = .fillEqually
        }
        self.view.addSubview(actionStatusStackView)
        actionStatusStackView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        
        self.input(input)
        
        // delegate
        self.textView.delegate = self
    }

    func input(_ input: Input) {
        let originalPost = input.post
        self.input = input
        let post = originalPost.originalPost
        // ブースト時の処理
        if originalPost.repost != nil {
            tootInfoView.isHidden = false
            boostedIconView.isHidden = false
            boostedIconView.image = nil
            boostedIconView.sd_setImage(with: URL(string: originalPost.account.avatarUrl), completed: nil)
        } else {
            tootInfoView.isHidden = true
            boostedIconView.isHidden = true
        }
        
        // アイコン
        self.iconView.sd_setImage(with: URL(string: post.account.avatarUrl, relativeTo: environment.app.instance.url), completed: {_, _, _, _ in
        })
        self.iconWidthConstraint.constant = CGFloat(Defaults[.timelineIconSize])

        // ユーザー名
        let userNameFont = UIFont.systemFont(ofSize: CGFloat(Defaults[.timelineUsernameFontsize]))
        self.userNameLabel.attributedText = NSAttributedString(string: post.account.name.emptyAsNil ?? post.account.screenName, attributes: [
            .font: userNameFont,
        ]).emojify(asyncLoadProgressHandler: {
            self.userNameLabel.setNeedsDisplay()
        }, emojifyProtocol: post.account)
        self.userNameLabel.font = userNameFont
        
        // acct
        var acct = post.account.acct
        if Defaults[.acctAbbr] {
            var acctSplitted = acct.split(separator: "@").map { String($0) }
            if acctSplitted.count == 2 {
                var acctHost = acctSplitted[1]
                let regex = try! NSRegularExpression(pattern: "[a-zA-Z]{4,}")
                var replaceTarget: Set<String> = []
                for r in regex.matches(in: acctHost, options: [], range: NSRange(location: 0, length: acctHost.count)) {
                    replaceTarget.insert((acctHost as NSString).substring(with: r.range))
                }
                for r in replaceTarget {
                    acctHost = acctHost.replacingOccurrences(of: r, with: "\(r.first!)\(r.count-2)\(r.last!)")
                }
                acctSplitted[1] = acctHost
            }
            acct = acctSplitted.joined(separator: "@")
        }
        let acctNsString = acct as NSString
        let acctAttrText = NSMutableAttributedString(string: "@" + (acctNsString as String), attributes: [
            .font: userNameFont,
        ])
        if let splitterPoint = acctNsString.rangeOfCharacter(from: CharacterSet(charactersIn: "@")).optional {
            acctAttrText.setAttributes(
                [
                    .font: userNameFont.withSize(userNameFont.pointSize * 0.75)
                ],
                range: NSRange(
                    location: splitterPoint.location + 1,
                    length: acctNsString.length - splitterPoint.location
                )
            )
        }
        
        self.acctNameLabel.attributedText = acctAttrText

        // 右上のいろいろ
        self.isReplyTreeLabel.isHidden = !(Defaults[.inReplyToEmoji] && post.inReplyToId != nil)
        self.isReplyTreeLabel.font = userNameFont
        self.visibilityLabel.isHidden = post.visibility == "public" || Defaults[.visibilityEmoji] == false
        if Defaults[.visibilityEmoji] {
            if post.visibility == "public" {
                self.visibilityLabel.isHidden = true
            } else {
                self.visibilityLabel.isHidden = false
                self.visibilityLabel.alpha = post.visibility == "unlisted" ? 0.5 : 1.0
                self.visibilityLabel.text = [
                    "unlisted": "🔓",
                    "private": "🔒",
                    "direct": "✉️",
                ][post.visibility]
                self.visibilityLabel.font = userNameFont
            }
        } else {
            self.visibilityLabel.isHidden = true
        }
        self.pinnedLabel.isHidden = !input.pinned
        self.pinnedLabel.font = userNameFont
        
        // ブースト/ふぁぼったかどうか
        
        self.isBoostedView.isHidden = !post.reposted
        self.isFavouritedView.isHidden = !post.favourited
        
        // 投稿日時の表示
        let calendar = Calendar(identifier: .gregorian)
        var timeFormat = "yyyy/MM/dd HH:mm:ss"
        if calendar.component(.year, from: Date()) == calendar.component(.year, from: post.createdAt) {
            timeFormat = "MM/dd HH:mm:ss"
        }
        if calendar.isDateInToday(post.createdAt) {
            timeFormat = "HH:mm:ss"
        }
        self.createdAtLabel.text = DateUtils.stringFromDate(post.createdAt, format: timeFormat)
        self.createdAtLabel.font = userNameFont

        // 投稿本文の処理
        let html = post.status.replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "")
        var font = UIFont.systemFont(ofSize: CGFloat(Defaults[.timelineTextFontsize]))
        if Defaults[.timelineTextBold] {
            font = UIFont.boldSystemFont(ofSize: font.pointSize)
        }
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.label,
        ]
        if post.spoilerText != "" {
            textView.attributedText = NSAttributedString(string: post.spoilerText.emojify() + "\n(CWの内容は詳細画面で\(post.attachments.count != 0 ? ", \(post.attachments.count)個の添付メディア" : ""))", attributes: [
                .foregroundColor: UIColor.secondaryLabel,
            ]).emojify(asyncLoadProgressHandler: {
                self.textView.setNeedsDisplay()
            }, emojifyProtocol: post)
        } else if let attrStr = html.parseText2HTML(attributes: attrs, asyncLoadProgressHandler: {
            self.textView.setNeedsDisplay()
        })?.emojify(asyncLoadProgressHandler: {
            self.textView.setNeedsDisplay()
        }, emojifyProtocol: post) {
            textView.attributedText = attrStr
        } else {
            textView.text = post.status.toPlainText()
        }
        textView.font = font
        
        // 添付ファイルの処理
        if post.attachments.count == 0 {
            attachedMediaListViewContrller.view.isHidden = true
        } else {
            attachedMediaListViewContrller.view.isHidden = false
            attachedMediaListViewContrller.input(post)
        }
    }
    
    @objc func iconTapped() {
        let vc = UserProfileTopViewController.instantiate(input.post.originalPost.account, environment: self.environment)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MastodonPostCellViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        var urlString = url.absoluteString
        let visibleString = (textView.attributedText.string as NSString).substring(with: characterRange)
        if let mention = input.post.mentions.first(where: { $0.url == urlString }) {
            self.environment.getAccount(id: mention.id).then({ user in
                let newVC = UserProfileTopViewController.instantiate(user, environment: self.environment)
                self.navigationController?.pushViewController(newVC, animated: true)
            })
            return false
        }
        if let media = input.post.attachments.first(where: { $0.textUrl == urlString }) {
            urlString = media.url
        }
        if visibleString.starts(with: "#") {
            let tag = String(visibleString[visibleString.index(after: visibleString.startIndex)...])
            let newVC = HashtagTimeLineTableViewController.init(hashtag: tag, environment: environment)
            self.navigationController?.pushViewController(newVC, animated: true)
            return false
        }
        self.open(url: URL(string: urlString)!)
        return false
    }
}
