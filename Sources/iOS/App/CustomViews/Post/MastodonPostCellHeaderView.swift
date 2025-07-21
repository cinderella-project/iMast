//
//  MastodonPostCellHeaderView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2025/07/22.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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
import Ikemen
import iMastiOSCore

class MastodonPostCellHeaderView: UIStackView {
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
    let editedLabel = UILabel() ※ { v in
        v.text = "✏️"
    }
    let visibilityLabel = UILabel()

    override init(frame: CGRect = .zero) {
        super.init(frame: .zero)
        addArrangedSubview(userNameLabel)
        addArrangedSubview(acctNameLabel)
        addArrangedSubview(UIStackView(arrangedSubviews: [
            isReplyTreeLabel,
            visibilityLabel,
            pinnedLabel,
            editedLabel,
            createdAtLabel,
        ]) ※ {
            $0.axis = .horizontal
        })
        
        spacing = 6
        axis = .horizontal
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(_ input: (MastodonPost, Bool)) {
        let (post, pinned) = input

        // ユーザー名
        let userNameFont = UIFont.systemFont(ofSize: CGFloat(Defaults.timelineUsernameFontsize))
        self.userNameLabel.attributedText = NSAttributedString(string: post.account.name.emptyAsNil ?? post.account.screenName, attributes: [
            .font: userNameFont,
        ]).emojify(asyncLoadProgressHandler: {
            self.userNameLabel.setNeedsDisplay()
        }, emojifyProtocol: post.account)
        self.userNameLabel.font = userNameFont
        
        // acct
        var acct = post.account.acct
        if Defaults.acctAbbr {
            var acctSplitted = acct.split(separator: "@").map { String($0) }
            if acctSplitted.count == 2 {
                acctSplitted[1] = acctSplitted[1].replacing(/[a-zA-Z]{4,}/, with: { match in
                    return "\(match.output.first!)\(match.output.count-2)\(match.output.last!)"
                })
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
                    .font: userNameFont.withSize(userNameFont.pointSize * 0.75),
                ],
                range: NSRange(location: splitterPoint.location + 1, length: acctNsString.length - splitterPoint.location)
            )
        }
        self.acctNameLabel.attributedText = acctAttrText

        // 右上のいろいろ
        self.isReplyTreeLabel.isHidden = !(Defaults.inReplyToEmoji && post.inReplyToId != nil)
        self.isReplyTreeLabel.font = userNameFont
        self.visibilityLabel.isHidden = post.visibility == .public || Defaults.visibilityEmoji == false
        if Defaults.visibilityEmoji, let emoji = post.visibility.emoji {
            self.visibilityLabel.isHidden = false
            self.visibilityLabel.alpha = post.visibility == .unlisted ? 0.5 : 1.0
            self.visibilityLabel.text = emoji
            self.visibilityLabel.font = userNameFont
        } else {
            self.visibilityLabel.isHidden = true
        }
        self.pinnedLabel.isHidden = !pinned
        self.pinnedLabel.font = userNameFont
        self.editedLabel.isHidden = post.editedAt == nil
        self.editedLabel.font = userNameFont

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
    }
}
