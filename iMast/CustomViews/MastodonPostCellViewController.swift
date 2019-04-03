//
//  MastodonPostCellViewController.swift
//  iMast
//
//  Created by user on 2019/03/11.
//  Copyright © 2019 rinsuki. All rights reserved.
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
        v.setContentCompressionResistancePriority(UILayoutPriority(249), for: .horizontal)
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
            isReplyTreeLabel,
            visibilityLabel,
            pinnedLabel,
            createdAtLabel,
        ]) ※ {
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
    }

    func input(_ input: Input) {
        let originalPost = input.post
        self.input = input
        let post = originalPost.repost ?? originalPost
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
            print("loaded")
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
        let html = (post.status.replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "").emojify(emojifyProtocol: post))
        var font = UIFont.systemFont(ofSize: CGFloat(Defaults[.timelineTextFontsize]))
        if Defaults[.timelineTextBold] {
            font = UIFont.boldSystemFont(ofSize: font.pointSize)
        }
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
        ]
        if post.spoilerText != "" {
            textView.attributedText = nil
            textView.text = post.spoilerText.emojify() + "\n(CWの内容は詳細画面で\(post.attachments.count != 0 ? ", \(post.attachments.count)個の添付メディア" : ""))"
            textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        } else if let attrStr = html.parseText2HTML(attributes: attrs, asyncLoadProgressHandler: {
            self.textView.setNeedsDisplay()
        }) {
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
        let vc = openUserProfile(user: (input.post.repost ?? input.post).account)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
