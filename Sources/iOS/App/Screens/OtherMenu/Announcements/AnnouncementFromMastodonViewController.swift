//
//  AnnouncementFromMastodonViewController.swift
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

class AnnouncementFromMastodonViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonAnnouncement
    typealias Environment = MastodonUserToken
    
    internal var input: Input
    internal let environment: Environment
    
    private let contentView = AnnouncementFromMastodonView()
    
    required init(with input: MastodonAnnouncement, environment: MastodonUserToken) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(contentView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.contentTextView.delegate = self
        contentView.markAsReadButton.addTarget(self, action: #selector(markAsRead), for: .touchUpInside)
        input(self.input)
    }
    
    var horizontalConstraint: SnapKit.Constraint?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        horizontalConstraint?.deactivate()
        contentView.snp.makeConstraints { make in
            self.horizontalConstraint = make.edges.equalTo(view.superview!.readableContentGuide).constraint
        }
    }
    
    func input(_ input: Input) {
        if self.input.id != input.id {
            contentView.markAsReadButton.configuration?.showsActivityIndicator = false
        }
        self.input = input
        
        contentView.readed = input.read
        
        let host = environment.app.instance.hostName
        contentView.titleLabel.text = host
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        contentView.publishedAtLabel.text = formatter.string(from: input.publishedAt)
        
        contentView.contentTextView.attributedText = input.content.parseText2HTMLNew(attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label,
        ])?.emojify(asyncLoadProgressHandler: { [weak contentView] in
            contentView?.contentTextView.setNeedsDisplay()
        }, emojifyProtocol: input)
    }
    
    @objc func markAsRead() {
        let currentInput = input
        contentView.markAsReadButton.configuration?.showsActivityIndicator = true
        contentView.markAsReadButton.isEnabled = false
        Task {
            do {
                _ = try await MastodonEndpoint.AnnouncementDismiss(id: currentInput.id).request(with: environment)
                await MainActor.run {
                    environment.markAsRead(id: currentInput.id)
                    if input.id == currentInput.id {
                        contentView.markAsReadButton.configuration?.showsActivityIndicator = false
//                        contentView.readed = true
                    }
                }
            } catch {
                await MainActor.run {
                    if input.id == currentInput.id {
                        contentView.markAsReadButton.configuration?.showsActivityIndicator = false
                    }
                    self.errorReport(error: error)
                }
            }
        }
    }
}

extension AnnouncementFromMastodonViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            if let mention = input.mentions.first(where: { $0.url == url }) {
                MastodonEndpoint.GetAccount(target: mention.id)
                    .request(with: environment)
                    .then { [weak self] user in
                        guard let strongSelf = self else { return }
                        let newVC = UserProfileTopViewController.instantiate(user, environment: strongSelf.environment)
                        strongSelf.navigationController?.pushViewController(newVC, animated: true)
                    }
                return false
            }
            if let status = input.statuses.first(where: { $0.url == url }) {
                MastodonEndpoint.GetPost(postOrID: .id(status.id))
                    .request(with: environment)
                    .then { [weak self] post in
                        guard let strongSelf = self else { return }
                        let newVC = MastodonPostDetailViewController.instantiate(post, environment: strongSelf.environment)
                        strongSelf.navigationController?.pushViewController(newVC, animated: true)
                    }
                return false
            }
            if let hashtag = input.tags.first(where: { $0.url == url }) {
                let newVC = HashtagTimelineViewController(hashtag: hashtag.name, environment: environment)
                self.navigationController?.pushViewController(newVC, animated: true)
                return false
            }
            self.open(url: url, role: .links)
            return false
        case .presentActions:
            return true // TODO: メニュー項目に追加できないか検討
        case .preview:
            return false // TODO: 独自プレビュー実装できないか検討
        @unknown default:
            return true
        }
    }
}
