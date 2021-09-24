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
import SafariServices
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
        v.font = .systemFont(ofSize: UIFont.systemFontSize)
        v.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    let valueTextView = UITextView() ※ { v in
        v.font = .systemFont(ofSize: UIFont.systemFontSize)
        v.backgroundColor = .clear
        v.isScrollEnabled = false
        v.isEditable = false
        v.textContainerInset = .zero
        v.textContainer.lineFragmentPadding = 0
    }
    let verifiedAtLabel = UILabel() ※ { v in
        v.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
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
            $0.spacing = 4
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
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: UIColor.label,
        ], asyncLoadProgressHandler: {
            self.nameLabel.setNeedsDisplay()
        })?.emojify(asyncLoadProgressHandler: {
            self.nameLabel.setNeedsDisplay()
        }, emojifyProtocol: input.account) {
            self.nameLabel.attributedText = name
        } else {
            self.nameLabel.text = input.field.name.toPlainText()
        }

        if let value = input.field.value.parseText2HTMLNew(attributes: [
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: UIColor.label,
        ], asyncLoadProgressHandler: {
            self.valueTextView.setNeedsDisplay()
        })?.emojify(asyncLoadProgressHandler: {
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

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let string = (textView.attributedText.string as NSString).substring(with: characterRange)
        if string.hasPrefix("@") {
            let alert = UIAlertController(title: "ユーザー検索中", message: "\(URL.absoluteString)\n\nしばらくお待ちください", preferredStyle: .alert)
            var canceled = false
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
                canceled = true
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "強制的にSafariで開く", style: .default, handler: { [weak self] _ in
                canceled = true
                alert.dismiss(animated: true, completion: nil)
                let safari = SFSafariViewController(url: URL)
                self?.present(safari, animated: true, completion: nil)
            }))
            environment.search(q: URL.absoluteString, resolve: true).then { [weak self] result in
                guard let strongSelf = self else { return }
                if canceled { return }
                alert.dismiss(animated: true) {
                    if let account = result.accounts.first {
                        let newVC = UserProfileTopViewController.instantiate(account, environment: strongSelf.environment)
                        strongSelf.navigationController?.pushViewController(newVC, animated: true)
                    } else {
                        let safari = SFSafariViewController(url: URL)
                        strongSelf.present(safari, animated: true, completion: nil)
                    }
                }
            }.catch { error in
                alert.dismiss(animated: true, completion: nil)
            }
            self.present(alert, animated: true, completion: nil)
            return false
        }
        let safari = SFSafariViewController(url: URL)
        self.present(safari, animated: true, completion: nil)
        return false
    }
}
