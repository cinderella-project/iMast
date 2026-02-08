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
import iMastiOSCore

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
        v.isUserInteractionEnabled = true
    }
    
    let headerView = MastodonPostCellHeaderView()
    
    let textView = NotSelectableTextView(usingTextLayoutManager: !Defaults.workaroundOfiOS16_TextKit2_WontUpdatesLinkColor) ※ { v in
        v.backgroundColor = nil
        v.isScrollEnabled = false
        v.isEditable = false
        v.textContainerInset = .zero
        v.textContainer.lineFragmentPadding = 0
    }
    let tootInfoView = UIView() ※ { v in
        v.backgroundColor = .init(resource: .barBoost)
        v.accessibilityIgnoresInvertColors = true
        v.snp.makeConstraints { make in
            make.width.equalTo(3)
        }
    }
    let boostedIconView = UIImageView()
    let attachedMediaListViewContrller: AttachedMediaListViewController
    
    let isBoostedView = UIView() ※ { v in
        v.backgroundColor = .init(resource: .barBoost)
        v.accessibilityIgnoresInvertColors = true
    }
    let isFavouritedView = UIView() ※ { v in
        v.backgroundColor = .init(resource: .barFavourite)
        v.accessibilityIgnoresInvertColors = true
    }
    
    let pollViewController: MastodonCompactPollViewController
    
    let quoteViewController: MastodonQuotedPostViewController
    
    required init(with input: Input, environment: Environment) {
        self.environment = environment
        self.input = input
        self.attachedMediaListViewContrller = AttachedMediaListViewController(with: input.post, environment: Void())
        self.pollViewController = .instantiate(input.post, environment: environment)
        self.quoteViewController = .instantiate(input.post, environment: environment)
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
        
        let topStackView = ContainerView(arrangedSubviews: [
            headerView,
            textView,
        ]) ※ {
            $0.addArrangedViewController(quoteViewController, parentViewController: self)
            $0.addArrangedViewController(attachedMediaListViewContrller, parentViewController: self)
            $0.addArrangedViewController(pollViewController, parentViewController: self)
            $0.axis = .vertical
            $0.spacing = 4
            $0.setCustomSpacing(2, after: headerView)
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
            boostedIconView.loadImage(from: URL(string: originalPost.account.avatarUrl))
        } else {
            tootInfoView.isHidden = true
            boostedIconView.isHidden = true
        }
        
        // アイコン
        print("loading", Thread.isMainThread)
        self.iconView.loadImage(from: URL(string: post.account.avatarUrl, relativeTo: environment.app.instance.url))
        self.iconWidthConstraint.constant = CGFloat(Defaults.timelineIconSize)

        headerView.load((post: post, pinned: input.pinned))
        
        // ブースト/ふぁぼったかどうか
        
        self.isBoostedView.isHidden = !post.reposted
        self.isFavouritedView.isHidden = !post.favourited
        
        // 投稿本文の処理
        let html = post.status.replacingOccurrences(of: "</p><p>", with: "<br /><br />").replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: "")
        var font = UIFont.systemFont(ofSize: CGFloat(Defaults.timelineTextFontsize))
        if Defaults.timelineTextBold {
            font = UIFont.boldSystemFont(ofSize: font.pointSize)
        }
        var attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.label,
        ]
        if Defaults.usePostLanguageInfo, let lang = post.language {
            attrs[kCTLanguageAttributeName as NSAttributedString.Key] = lang
        }
        if post.spoilerText != "" {
            textView.attributedText = NSAttributedString(string: post.spoilerText + "\n(CWの内容は詳細画面で\(post.attachments.count != 0 ? ", \(post.attachments.count)個の添付メディア" : ""))", attributes: [
                .foregroundColor: UIColor.secondaryLabel,
            ]).emojify(asyncLoadProgressHandler: {
                self.textView.setNeedsDisplay()
            }, emojifyProtocol: post)
        } else if let attrStr = html.parseText2HTML(attributes: attrs)?.emojify(asyncLoadProgressHandler: {
            self.textView.setNeedsDisplay()
        }, emojifyProtocol: post) {
            textView.attributedText = attrStr
        } else {
            textView.text = post.status.toPlainText()
        }
        textView.font = font
        
        // 添付ファイルの処理
        attachedMediaListViewContrller.input(post)
        
        // 投票の処理
        pollViewController.input(post)
        
        // 引用投稿の処理
        quoteViewController.input(post)
    }
    
    @objc func iconTapped() {
        let vc = UserProfileTopViewController.instantiate(input.post.originalPost.account, environment: self.environment)
        showFromTimeline(vc)
    }
}

extension MastodonPostCellViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            var urlString = url.absoluteString
            let visibleString = (textView.attributedText.string as NSString).substring(with: characterRange)
            if let mention = input.post.mentions.first(where: { $0.url == urlString }) {
                MastodonEndpoint.GetAccount(target: mention.id)
                    .request(with: environment)
                    .then { user in
                        let newVC = UserProfileTopViewController.instantiate(user, environment: self.environment)
                        self.navigationController?.pushViewController(newVC, animated: true)
                    }
                return false
            }
            if let media = input.post.attachments.first(where: { $0.textUrl == urlString }) {
                urlString = media.url
            }
            if visibleString.starts(with: "#") {
                let tag = String(visibleString[visibleString.index(after: visibleString.startIndex)...])
                let newVC = HashtagTimelineViewController.init(hashtag: tag, environment: environment)
                self.navigationController?.pushViewController(newVC, animated: true)
                return false
            }
            self.open(url: URL(string: urlString)!, role: .links)
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
