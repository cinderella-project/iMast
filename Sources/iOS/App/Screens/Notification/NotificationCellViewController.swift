//
//  NotificationCellViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/12/20.
//  
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2019 rinsuki and other contributors.
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
//

import UIKit
import iMastiOSCore
import Ikemen
import Mew

class NotificationCellViewController: UIViewController, Instantiatable, Injectable {
    typealias Environment = MastodonUserToken
    typealias Input = MastodonNotification
    var environment: Environment
    var input: Input
    
    let notifyTypeImageView = UIImageView() ※ { v in
        v.tintColor = .label
        v.contentMode = .scaleAspectFit
        v.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }
    let titleLabel = UILabel() ※ { v in
        v.font = .systemFont(ofSize: 14)
    }
    let descriptionLabel = UILabel() ※ { v in
        v.font = .systemFont(ofSize: 17)
    }
    
    required init(with input: MastodonNotification, environment: MastodonUserToken) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        let mainStackView = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 4
        let topStackView = UIStackView(arrangedSubviews: [
            notifyTypeImageView,
            mainStackView
        ])
        topStackView.axis = .horizontal
        topStackView.spacing = 8
        topStackView.alignment = .top
        view.addSubview(topStackView)
        notifyTypeImageView.snp.makeConstraints { make in
            make.trailing.equalTo(view.snp.leading).inset(Defaults.timelineIconSize + 8)
        }
        topStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(8)
        }
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        input(input)
    }
    
    func input(_ input: MastodonNotification) {
        self.input = input
        notifyTypeImageView.image = Self.getIcon(type: input.type)
        titleLabel.text = getTitle(notification: input)
        descriptionLabel.text = (input.status?.status.toPlainText() ?? input.account?.name ?? " ")
            .replacingOccurrences(of: "\n", with: " ")
    }
    
    static func getIcon(type: String) -> UIImage? {
        switch type {
        case "reblog":
            return .init(resource: .boost)
        case "favourite":
            return .init(resource: .star)
        case "mention":
            return .init(resource: .reply)
        case "follow":
            return .init(resource: .follow)
        case "poll":
            return .init(resource: .poll)
        case "update":
            return UIImage(systemName: "pencil")
        default:
            return nil
        }
    }
    
    func getTitle(notification: MastodonNotification) -> String {
        let acct = notification.account?.acct ?? ""
        switch notification.type {
        case "reblog":
            return L10n.Notification.Types.boost(acct)
        case "favourite":
            return L10n.Notification.Types.favourite(acct)
        case "mention":
            return L10n.Notification.Types.mention(acct)
        case "follow":
            return L10n.Notification.Types.follow(acct)
        case "poll":
            if environment.screenName == notification.account?.acct {
                return L10n.Notification.Types.Poll.owner
            } else {
                return L10n.Notification.Types.Poll.notowner
            }
        case "follow_request":
            return L10n.Notification.Types.followRequest(acct)
        case "update":
            if environment.screenName == notification.status?.originalPost.account.acct {
                return L10n.Notification.Types.PostUpdated.isMe
            } else {
                return L10n.Notification.Types.PostUpdated.notMe
            }
        default:
            return L10n.Notification.Types.unknown(notification.type)
        }
    }
}
