//
//  PostView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/01.
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

import Cocoa
import Ikemen
import iMastMacCore

private func getCurrentTimeString(date: Date) -> String {
    let calendar = Calendar(identifier: .gregorian)
    var timeFormat = "yyyy/MM/dd HH:mm:ss"
    if calendar.component(.year, from: Date()) == calendar.component(.year, from: date) {
        timeFormat = "MM/dd HH:mm:ss"
    }
    if calendar.isDateInToday(date) {
        timeFormat = "HH:mm:ss"
    }
    let formatter = DateFormatter()
    formatter.dateFormat = timeFormat
    formatter.locale = .init(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}

class PostView: NSView {
    let imageView = NSImageView()
    let userNameField = NSTextField(labelWithString: "") ※ {
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    let userAcctField = NSTextField(labelWithString: "") ※ {
        $0.textColor = .secondaryLabelColor
        $0.setContentCompressionResistancePriority(.init(251), for: .horizontal)
        $0.setContentHuggingPriority(.init(249), for: .horizontal)
    }
    let timeField = NSTextField(labelWithString: "")
    let textField = AutolayoutTextView() ※ {
        $0.isEditable = false
        $0.drawsBackground = false
        $0.textContainer?.lineFragmentPadding = 0
    }
    let guardTextField = NSTextField(labelWithString: "\(L10n.Menu.post) → \(L10n.Menu.hidePrivatePosts)")
    
    init(post: MastodonPost) {
        super.init(frame: .zero)
        load(post: post)
        addSubview(imageView)
        let stackView = NSStackView(views: [
            NSStackView(views: [
                userNameField,
                userAcctField,
                timeField,
            ]) ※ {
                $0.setHuggingPriority(.required, for: .vertical)
            },
            textField,
        ]) ※ {
            $0.spacing = 4
            $0.alignment = .leading
            $0.orientation = .vertical
            $0.setHuggingPriority(.required, for: .vertical)
        }
        addSubview(stackView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
//            make.bottom.lessThanOrEqualToSuperview().inset(8)
            make.leading.equalToSuperview().inset(4)
            make.size.equalTo(48)
        }
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(8)
        }
        if post.originalPost.visibility != .public, post.originalPost.visibility != .unlisted {
            imageView.bind(.hidden, to: NSUserDefaultsController.appGroup, withKeyPath: "values.hide_private_posts", options: nil)
            stackView.bind(.hidden, to: NSUserDefaultsController.appGroup, withKeyPath: "values.hide_private_posts", options: nil)
            addSubview(guardTextField)
            guardTextField.snp.makeConstraints { make in
                make.size.lessThanOrEqualToSuperview()
                make.center.equalToSuperview()
            }
            guardTextField.bind(.hidden, to: NSUserDefaultsController.appGroup, withKeyPath: "values.hide_private_posts", options: [.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(post: MastodonPost) {
        let original = post.originalPost
        imageView.sd_setImage(with: URL(string: original.account.avatarUrl), completed: nil)
        userNameField.stringValue = original.account.name
        userAcctField.stringValue = "@" + original.account.acct
        timeField.stringValue = getCurrentTimeString(date: original.createdAt)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .foregroundColor: NSColor.controlTextColor,
        ]
        if let attributedString = original.status.parseText2HTML(attributes: attributes) {
            textField.textStorage?.setAttributedString(attributedString)
        } else {
            textField.textStorage?.setAttributedString(NSAttributedString(string: original.status, attributes: attributes))
        }
    }
}
