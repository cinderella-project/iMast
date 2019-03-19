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
    typealias Input = MastodonPost
    
    typealias Environment = MastodonUserToken

    var environment: MastodonUserToken

    var iconWidthConstraint: NSLayoutConstraint!
    let iconView = UIImageView() ※ { v in
        v.snp.makeConstraints { make in
            make.width.equalTo(v.snp.height)
        }
    }
    
    var input: Input

    let userNameLabel = UILabel() ※ { v in
        v.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
    }
    let createdAtLabel = UILabel()
    let textView = UITextView() ※ { v in
        v.isScrollEnabled = false
        v.isEditable = false
        v.textContainerInset = .zero
        v.textContainer.lineFragmentPadding = 0
    }
    let isBoostedView = UIView() ※ { v in
        v.backgroundColor = ColorSet.boostedBar
        v.snp.makeConstraints { make in
            make.width.equalTo(3)
        }
    }
    let attachedMediaListViewContrller: AttachedMediaListViewController
    
    required init(with input: Input, environment: Environment) {
        self.environment = environment
        self.input = input
        self.attachedMediaListViewContrller = AttachedMediaListViewController(with: input, environment: Void())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // layout
        self.view.addSubview(iconView)
        iconWidthConstraint = iconView.widthAnchor.constraint(equalToConstant: 64) ※ {
            $0.isActive = true
        }
        iconView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        let userStackView = UIStackView(arrangedSubviews: [
            userNameLabel,
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
        
        self.view.addSubview(isBoostedView)
        isBoostedView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        self.input(input)
    }

    func input(_ originalInput: MastodonPost) {
        let input = originalInput.repost ?? originalInput
        // ブースト時の処理
        if originalInput.repost != nil {
            isBoostedView.isHidden = false
        } else {
            isBoostedView.isHidden = true
        }
        
        // アイコン
        self.iconView.sd_setImage(with: URL(string: input.account.avatarUrl, relativeTo: environment.app.instance.url), completed: {_, _, _, _ in
            print("loaded")
        })
        self.iconWidthConstraint.constant = CGFloat(Defaults[.timelineIconSize])

        // ユーザー名
        let userNameFont = UIFont.systemFont(ofSize: CGFloat(Defaults[.timelineUsernameFontsize]))
        self.userNameLabel.text = input.account.name.emptyAsNil ?? input.account.screenName
        self.userNameLabel.font = userNameFont

        // 投稿日時の表示
        let calendar = Calendar(identifier: .gregorian)
        var timeFormat = "yyyy/MM/dd HH:mm:ss"
        if calendar.component(.year, from: Date()) == calendar.component(.year, from: input.createdAt) {
            timeFormat = "MM/dd HH:mm:ss"
        }
        if calendar.isDateInToday(input.createdAt) {
            timeFormat = "HH:mm:ss"
        }
        self.createdAtLabel.text = DateUtils.stringFromDate(input.createdAt, format: timeFormat)
        self.createdAtLabel.font = userNameFont

        // 投稿本文の処理
        let html = (input.status.replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "").emojify(custom_emoji: input.emojis, profile_emoji: input.profileEmojis))
        var font = UIFont.systemFont(ofSize: CGFloat(Defaults[.timelineTextFontsize]))
        if Defaults[.timelineTextBold] {
            font = UIFont.boldSystemFont(ofSize: font.pointSize)
        }
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
        ]
        if input.spoilerText != "" {
            textView.attributedText = nil
            textView.text = input.spoilerText.emojify() + "\n(CWの内容は詳細画面で\(input.attachments.count != 0 ? ", \(input.attachments.count)個の添付メディア" : ""))"
            textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        } else if let attrStr = html.parseText2HTML(attributes: attrs, asyncLoadProgressHandler: {
            self.textView.setNeedsDisplay()
        }) {
            textView.attributedText = attrStr
        } else {
            textView.text = input.status.toPlainText()
        }
        textView.font = font
        
        // 添付ファイルの処理
        if input.attachments.count == 0 {
            attachedMediaListViewContrller.view.isHidden = true
        } else {
            attachedMediaListViewContrller.view.isHidden = false
            attachedMediaListViewContrller.input(input)
        }
    }
    
    @IBAction func iconTapped(_ sender: Any) {
        let vc = openUserProfile(user: input.account)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
