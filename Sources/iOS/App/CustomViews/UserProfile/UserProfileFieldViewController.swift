//
//  UserProfileFieldViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by shibafu on 2021/08/15.
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
import iMastiOSCore
import Ikemen
import Mew

private class ZeroHeightView<WrappedView: UIView>: UIView {
    let wrappedView: WrappedView
    
    init(wrapped wrappedView: WrappedView) {
        self.wrappedView = wrappedView
        super.init(frame: .zero)
        addSubview(wrappedView)
        wrappedView.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserProfileFieldViewController: UIViewController, Instantiatable, Injectable, UITextViewDelegate {
    typealias Input = (account: MastodonAccount, field: MastodonAccountField)
    typealias Environment = MastodonUserToken
    var input: Input
    var environment: Environment

    let nameLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .footnote) // foot :thinking_face:
        v.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    let valueTextView = UITextView() ※ { v in
        v.font = .preferredFont(forTextStyle: .body)
        v.backgroundColor = .clear
        v.isScrollEnabled = false
        v.isEditable = false
        v.textContainerInset = .zero
        v.textContainer.lineFragmentPadding = 0
    }
    let verifiedAtLabel = UILabel() ※ { v in
        // foot :thinking_face:
        v.font = .preferredFont(forTextStyle: .footnote, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        v.textColor = .systemGreen
    }
    private let verifiedIcon = ZeroHeightView(wrapped: UIImageView(image: UIImage(
        systemName: "checkmark.circle.fill"
    ))) ※ { v in
        v.wrappedView.tintColor = .systemGreen
    }

    required init(with input: Input, environment: MastodonUserToken) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()
        let verifiedStackView = UIStackView(arrangedSubviews: [
            verifiedAtLabel,
            verifiedIcon,
        ]) ※ {
            $0.axis = .horizontal
            $0.spacing = 4
        }
        let nameStackView = UIStackView(arrangedSubviews: [
            nameLabel,
            verifiedStackView,
        ]) ※ {
            $0.axis = .horizontal
            $0.spacing = 4
        }
        let mainStackView = UIStackView(arrangedSubviews: [
            nameStackView,
            valueTextView,
        ]) ※ {
            $0.axis = .vertical
            $0.spacing = 2
        }
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.top.bottom.equalToSuperview().inset(8)
        }
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        valueTextView.delegate = self
        input(input)
    }

    func input(_ input: Input) {
        self.input = input
        if let name = input.field.name.parseText2HTMLNew(attributes: [
            .font: self.nameLabel.font,
            .foregroundColor: UIColor.label,
        ])?.emojify(asyncLoadProgressHandler: {
            self.nameLabel.setNeedsDisplay()
        }, emojifyProtocol: input.account) {
            self.nameLabel.attributedText = name
        } else {
            self.nameLabel.text = input.field.name.toPlainText()
        }

        if let value = input.field.value.parseText2HTMLNew(attributes: [
            .font: self.valueTextView.font,
            .foregroundColor: UIColor.label,
        ])?.emojify(asyncLoadProgressHandler: {
            self.valueTextView.setNeedsDisplay()
        }, emojifyProtocol: input.account) {
            self.valueTextView.attributedText = value
        } else {
            self.valueTextView.text = input.field.value.toPlainText()
        }

        if let verifiedAt = input.field.verifiedAt {
            self.verifiedIcon.isHidden = false
            self.verifiedAtLabel.isHidden = false
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            self.verifiedAtLabel.text = formatter.string(from: verifiedAt)
        } else {
            self.verifiedIcon.isHidden = true
            self.verifiedAtLabel.isHidden = true
        }
    }

    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            let string = (textView.attributedText.string as NSString).substring(with: characterRange)
            if string.hasPrefix("@") {
                resolveUserProfile(userToken: environment, url: url)
                return false
            }
            open(url: url)
            return false
        case .presentActions:
            return true
        case .preview:
            return false
        }
    }
}
