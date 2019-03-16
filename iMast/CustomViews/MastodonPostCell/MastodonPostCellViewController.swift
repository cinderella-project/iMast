//
//  MastodonPostCellViewController.swift
//  iMast
//
//  Created by user on 2019/03/11.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew

class MastodonPostCellViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonPost
    
    typealias Environment = MastodonUserToken

    var environment: MastodonUserToken

    @IBOutlet weak var iconContainerView: ContainerView!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    let iconView: UserIconViewController
    var input: Input

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    required init(with input: Input, environment: Environment) {
        self.environment = environment
        self.iconView = UserIconViewController(with: input.account, environment: environment)
        self.input = input
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.iconContainerView.addArrangedViewController(self.iconView, parentViewController: self)
        self.input(input)
        
        self.textView.textContainerInset = .zero
    }

    func input(_ originalInput: MastodonPost) {
        let input = originalInput.repost ?? originalInput
        
        // アイコン
        self.iconView.input(input.account)
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
    }
}
