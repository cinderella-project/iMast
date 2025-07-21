//
//  MastodonQuotedPostViewController.swift
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
import Mew
import Ikemen
import SnapKit
import iMastiOSCore

class MastodonQuotedPostViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonPostContentProtocol
    typealias Environment = MastodonUserToken
    
    let environment: Environment
    var input: Input
    
    let quoteButton = UIButton(frame: .zero) ※ { v in
        v.layer.cornerRadius = 8
#if os(visionOS)
        v.layer.borderWidth = 1
#else
        v.layer.borderWidth = 1 / UIScreen.main.scale
#endif
        v.layer.borderColor = UIColor.gray.cgColor
    }
    
    let headerView = MastodonPostCellHeaderView() ※ { v in
        v.setContentHuggingPriority(.required, for: .vertical)
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    let textLabel = UILabel() ※ { v in
        v.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    }
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let stackView = UIStackView(arrangedSubviews: [
            UIImageView(image: UIImage(systemName: "quote.opening")) ※ {
                $0.tintColor = .label
                $0.setContentHuggingPriority(.required, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
                $0.setContentCompressionResistancePriority(.required, for: .horizontal)
                $0.setContentCompressionResistancePriority(.required, for: .vertical)
            },
            quoteButton,
        ]) ※ { v in
            v.alignment = .top
            v.spacing = 4
        }
        
        quoteButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        let contentStackView = UIStackView(arrangedSubviews: [
            headerView,
            textLabel,
        ]) ※ { v in
            v.alignment = .fill
            v.axis = .vertical
            v.spacing = 4
            v.isUserInteractionEnabled = false
        }
        
        quoteButton.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        self.view = stackView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func input(_ input: Input) {
        self.input = input
        guard let quote = input.quote else {
            view.isHidden = true
            return
        }
        view.isHidden = false
        
        var font = UIFont.systemFont(ofSize: CGFloat(Defaults.timelineTextFontsize))
        if Defaults.timelineTextBold {
            font = UIFont.boldSystemFont(ofSize: font.pointSize)
        }
        textLabel.font = font

        switch quote {
        case .notAvailable(let reason):
            headerView.isHidden = true
            quoteButton.isEnabled = false
            textLabel.numberOfLines = 0
            textLabel.textColor = .secondaryLabel

            switch reason {
            case .deleted:
                textLabel.text = L10n.Localizable.Quote.State.deleted
            case .pending:
                textLabel.text = L10n.Localizable.Quote.State.pending
            case .unauthorized:
                textLabel.text = L10n.Localizable.Quote.State.unauthorized
            case .rejected, .revoked:
                textLabel.text = L10n.Localizable.Quote.State.rejectedOrRevoked
            }
        case .accepted(let postOrID):
            quoteButton.isEnabled = true
            
            switch postOrID {
            case .post(let post):
                headerView.isHidden = false
                headerView.load((post, false))
                textLabel.numberOfLines = 1
                textLabel.textColor = .label
                textLabel.text = post.status.toPlainText().replacingOccurrences(of: "\n", with: " ")
            case .id(let id):
                headerView.isHidden = true
                textLabel.numberOfLines = 0
                textLabel.textColor = .secondaryLabel
                textLabel.text = L10n.Localizable.Quote.fetchShallowPost
            }
        }
    }
    
    @objc func buttonPressed() {
        guard case .accepted(let postOrID) = input.quote else { return }
        switch postOrID {
        case .post(let post):
            let vc = MastodonPostDetailViewController(with: post, environment: environment)
            showFromTimeline(vc)
        case .id(let postID):
            Task {
                let post = try await MastodonEndpoint.GetPost(postOrID: postOrID).request(with: environment)
                await MainActor.run {
                    do {
                        try environment.memoryStore.post.change(obj: post)
                    } catch {
                        reportError(error: error)
                    }
                    let vc = MastodonPostDetailViewController(with: post, environment: environment)
                    showFromTimeline(vc)
                }
            }
            break
        }
    }
}
