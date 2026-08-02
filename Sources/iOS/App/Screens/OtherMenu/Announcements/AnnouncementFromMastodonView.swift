//
//  AnnouncementFromMastodonView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2026/08/02.
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
import Combine
import Mew
import Ikemen
import SnapKit

class AnnouncementFromMastodonView: UIView {
    let unreadIndicator = UIView() ※ {
        $0.snp.makeConstraints { make in
            make.size.equalTo(9)
        }
        $0.layer.cornerRadius = 9.0 / 2.0
        $0.backgroundColor = .tintColor
    }
    let titleLabel = UILabel() ※ {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    let publishedAtLabel = UILabel() ※ {
        $0.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        $0.textColor = .secondaryLabel
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    let contentTextView = UITextView(frame: .zero) ※ {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.backgroundColor = nil
        $0.isScrollEnabled = false
        $0.isEditable = false
        $0.textContainer.lineFragmentPadding = 0
    }
    let markAsReadButton = UIButton() ※ {
        var config = UIButton.Configuration.borderedProminent()
        #if !os(visionOS)
        if #available(iOS 26.0, *) {
            config = .prominentGlass()
        }
        #endif
        config.image = UIImage(systemName: "checkmark")
        config.imagePadding = 8
        config.title = L10n.Localizable.Announcements.markAsReadButton
        $0.configuration = config
    }
    
    var readed: Bool = true {
        didSet {
            unreadIndicator.isHidden = readed
            markAsReadButton.isEnabled = !readed && (markAsReadButton.configuration?.showsActivityIndicator != true)
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        let stackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [
                unreadIndicator,
                titleLabel,
                publishedAtLabel,
            ]) ※ {
                $0.alignment = .center
                $0.spacing = 8
                $0.setContentHuggingPriority(.required, for: .vertical)
            },
            contentTextView,
            markAsReadButton,
        ]) ※ {
            $0.alignment = .fill
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.axis = .vertical
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    let view = AnnouncementFromMastodonView()
    view.titleLabel.text = "ultra.super.long.mastodon.example"
    view.publishedAtLabel.text = "2006/01/02 03:04:05"
    view.contentTextView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    view.backgroundColor = .gray
    view.markAsReadButton.isEnabled = false
    view.snp.makeConstraints { make in
        make.width.equalTo(320)
    }
    return view
}
