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

class PostView: NSTableRowView {
    let iconView = LayeredImageView()
    let userNameField = NSTextField(labelWithString: "") ※ {
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
    }
    let userAcctField = NSTextField(labelWithString: "") ※ {
        $0.textColor = .secondaryLabelColor
        $0.setContentCompressionResistancePriority(.init(251), for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.init(249), for: .horizontal)
    }
    let timeField = NSTextField(labelWithString: "") ※ {
        $0.setContentHuggingPriority(.required, for: .vertical)
    }
    let textView = AutolayoutTextView() ※ {
        $0.isEditable = false
        $0.backgroundColor = .clear
        $0.textContainer?.lineFragmentPadding = 0
    }
    let boostedPostIndicator = NSView() ※ {
        $0.wantsLayer = true
        $0.layer?.backgroundColor = NSColor(resource: .barBoost).cgColor
    }
    let attachedMediaStackView = NSStackView(views: []) ※ {
        $0.orientation = .vertical
        $0.spacing = 8
        $0.setHuggingPriority(.required, for: .vertical)
    }
    let contentView = NSView()
    let guardTextField = NSTextField(labelWithString: "\(L10n.Menu.post) → \(L10n.Menu.hidePrivatePosts)")
    
    init(post: MastodonPost) {
        super.init(frame: .zero)
        load(post: post)
        let stackView = NSStackView(views: [
            NSStackView(views: [
                userNameField,
                userAcctField,
                timeField,
            ]) ※ {
                $0.setHuggingPriority(.required, for: .vertical)
            },
            textView,
            attachedMediaStackView,
        ]) ※ {
            $0.spacing = 4
            $0.alignment = .leading
            $0.orientation = .vertical
            $0.setHuggingPriority(.required, for: .vertical)
        }
        subviews = [contentView]
        contentView.subviews = [
            boostedPostIndicator,
            iconView,
            stackView,
        ]
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        boostedPostIndicator.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
            make.leading.equalToSuperview().inset(8)
            make.size.equalTo(48)
        }
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(iconView.snp.trailing).offset(8)
        }
        if post.originalPost.visibility != .public, post.originalPost.visibility != .unlisted {
            contentView.bind(.hidden, to: NSUserDefaultsController.appGroup, withKeyPath: "values.hide_private_posts", options: nil)
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
        boostedPostIndicator.isHidden = post.repost == nil
        let original = post.originalPost
        iconView.loadImage(url: URL(string: original.account.avatarUrl))
        userNameField.stringValue = original.account.name
        userAcctField.stringValue = "@" + original.account.acct
        timeField.stringValue = (original.visibility.emoji ?? "") + getCurrentTimeString(date: original.createdAt)
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: NSMutableParagraphStyle() ※ {
                // TODO: もっとマシにする
                $0.minimumLineHeight = NSFont.systemFontSize + 2
                $0.maximumLineHeight = $0.minimumLineHeight
            },
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .foregroundColor: NSColor.controlTextColor,
        ]
        if let attributedString = original.status.parseText2HTML(attributes: attributes) {
            textView.textStorage?.setAttributedString(attributedString)
        } else {
            textView.textStorage?.setAttributedString(NSAttributedString(string: original.status, attributes: attributes))
        }
        if original.attachments.count > 0 {
            for media in original.attachments {
                let imageView = AttachmentView(attachment: media)
                imageView.snp.makeConstraints { make in
                    make.height.equalTo(40)
                }
                attachedMediaStackView.addArrangedSubview(imageView)
            }
            attachedMediaStackView.isHidden = false
        } else {
            attachedMediaStackView.isHidden = true
        }
    }
    
    override var isSelected: Bool {
        didSet {
            // NSTextView がうまく backgroundStyle で色を変えてくれない問題対策
            switch interiorBackgroundStyle {
            case .emphasized:
                textView.linkTextAttributes = [
                    .cursor: NSCursor.pointingHand,
                ]
                textView.textColor = .alternateSelectedControlTextColor
            case .normal:
                textView.linkTextAttributes = [
                    .foregroundColor: NSColor.linkColor,
                    .cursor: NSCursor.pointingHand,
                ]
                textView.textColor = .controlTextColor
            case .raised, .lowered:
                print("unknown style", interiorBackgroundStyle)
            @unknown default:
                print("unknown style", interiorBackgroundStyle)
            }
        }
    }
}

class AttachmentView: LayeredImageView {
    lazy var clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(open))
    let attachment: MastodonAttachment
    
    init(attachment: MastodonAttachment) {
        self.attachment = attachment
        super.init()
        clipsToBounds = true
        layer?.contentsGravity = .resizeAspectFill
        loadImage(url: URL(string: attachment.previewUrl ?? ""))
        addGestureRecognizer(clickRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func open() {
        if let url = URL(string: attachment.url) {
            NSWorkspace.shared.open(url)
        }
    }
}
