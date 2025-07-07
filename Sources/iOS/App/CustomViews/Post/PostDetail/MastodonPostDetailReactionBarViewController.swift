//
//  MastodonPostDetailReactionBarViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by rinsuki on 2019/07/30.
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

import UIKit
import Mew
import Ikemen
import iMastiOSCore
import ExtensionFoundation
import iMastExtensionKit

class MastodonPostDetailReactionBarViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonPost
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let replyButton = UIButton() ※ { v in
        v.setTitle("リプライ", for: .normal)
        v.setTitleColor(.gray, for: .normal)
    }
    let boostButton = UIButton() ※ { v in
        v.setTitle("ブースト", for: .normal)
        v.setTitleColor(.gray, for: .normal)
    }
    let favouriteButton = UIButton() ※ { v in
        v.setTitle("ふぁぼ", for: .normal)
        v.setTitleColor(.gray, for: .normal)
    }
    let othersButton = UIButton() ※ { v in
        v.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        v.tintColor = .gray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let buttons = [
            replyButton,
            boostButton,
            favouriteButton,
            othersButton,
        ]
        for button in buttons {
            button.isPointerInteractionEnabled = true
            button.snp.makeConstraints { make in
                make.width.lessThanOrEqualTo(300)
            }
        }
        let stackView = UIStackView(arrangedSubviews: buttons.map { button in
            let view = UIView()
            view.addSubview(button)
            button.contentEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24)
            button.titleEdgeInsets = .init(top: 0, left: -24, bottom: 0, right: -24)
            button.snp.makeConstraints { make in
                make.height.equalToSuperview()
                make.center.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
            return view
        }) ※ { v in
            v.distribution = .fillEqually
        }
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.size.equalTo(self.view.readableContentGuide)
            make.height.equalTo(44)
        }
        
        replyButton.addTarget(self, action: #selector(self.openReplyVC), for: .touchUpInside)
        boostButton.addTarget(self, action: #selector(self.boostButtonTapped), for: .touchUpInside)
        favouriteButton.addTarget(self, action: #selector(self.favouriteButtonTapped), for: .touchUpInside)
        othersButton.showsMenuAsPrimaryAction = true
        
        self.input(input)
    }
    
    func input(_ input: Input) {
        self.input = input
        boostButton.setTitleColor(input.reposted ? UIColor(resource: .barBoost) : .gray, for: .normal)
        favouriteButton.setTitleColor(input.favourited ? UIColor(resource: .barFavourite) : .gray, for: .normal)

        // build
        var othersMenuChildrens = [UICommand]()
        othersButton.menu = UIMenu(children: [UIDeferredMenuElement { [weak self] completion in
            guard let strongSelf = self else {
                completion([])
                return
            }
            Task {
                do {
                    completion(try await strongSelf.buildOthersMenu())
                } catch {
                    completion([])
                }
            }
        }])
    }
    
    func buildOthersMenu() async throws -> [UIMenuElement] {
        var elements = [UIMenuElement]()
        let version = try await environment.getIntVersion()
        if version.supportingFeature(.bookmark) {
            if input.bookmarked {
                elements.append(UICommand(title: "ブックマークから削除", image: UIImage(systemName: "bookmark.slash"), action: #selector(removeFromBookmark)))
            } else {
                elements.append(UICommand(title: "ブックマーク", image: UIImage(systemName: "bookmark"), action: #selector(addToBookmark)))
            }
        }
        if version.supportingFeature(.editPost) {
            if input.account.acct == environment.screenName {
                elements.append(UICommand(title: L10n.NewPost.edit, image: UIImage(systemName: "pencil"), action: #selector(openEditPostVC)))
            }
        }
        elements.append(UICommand(title: L10n.Localizable.PostDetail.share, image: UIImage(systemName: "square.and.arrow.up"), action: #selector(openShareSheet)))
        if #available(iOS 26, *) {
            elements.append(UIMenu(title: "拡張機能", image: UIImage(systemName: "puzzlepiece.extension"), children: [UIDeferredMenuElement({ callback in
                Task {
                    let monitor = try? await AppExtensionPoint.Monitor(appExtensionPoint: .postActionExtension)
                    var items: [UIMenuElement] = []
                    for identity in monitor?.identities ?? [] {
                        items.append(UIAction(title: identity.localizedName, handler: { _ in
                            self.handleExtension(identity: identity)
                        }))
                    }
                    await MainActor.run {
                        callback(items)
                    }
                }
            })]))
        }
        elements.append(UICommand(title: L10n.Localizable.Bunmyaku.title, image: UIImage(systemName: "list.bullet.indent"), action: #selector(openBunmyakuVC)))
        if input.hasCustomEmoji {
            elements.append(UICommand(title: L10n.Localizable.CustomEmojis.title, action: #selector(openEmojiListVC)))
        }
        if environment.screenName == input.account.acct {
            elements.append(UICommand(title: L10n.Localizable.PostDetail.delete, image: UIImage(systemName: "trash"), action: #selector(confirmDeletePost), attributes: .destructive))
        }
        elements.append(UICommand(title: L10n.Localizable.PostDetail.reportAbuse, image: UIImage(systemName: "exclamationmark.bubble"), action: #selector(openAbuseVC)))
        return elements
    }
    
    @available(iOS 26, *)
    func handleExtension(identity: AppExtensionIdentity) {
        let input = self.input.originalPost
        Task {
            let config = AppExtensionProcess.Configuration(appExtensionIdentity: identity)
            let proc = try await AppExtensionProcess(configuration: config)
            let connection = try proc.makeXPCSession()
            try connection.activate()
            try connection.send(SocialPost(uri: "", author: .init(uri: "", acct: input.account.acct))) { (result: Result<PostActionResult, any Error>) in
                switch result {
                case .success(.composeReply(let text)):
                    DispatchQueue.main.async {
                        let post = self.input.originalPost
                        self.showAsWindow(userActivity: .init(newPostWithMastodonUserToken: self.environment) ※ {
                            $0.setNewPostReplyInfo(post)
                            $0.newPostSuffix = text
                        }, fallback: .push)
                    }
                default:
                    print(result)
                }
                connection.cancel(reason: "")
            }
        }
    }
    
    @objc func openReplyVC() {
        let post = self.input.originalPost
        showAsWindow(userActivity: .init(newPostWithMastodonUserToken: environment) ※ {
            $0.setNewPostReplyInfo(post)
        }, fallback: .push)
    }
    
    @objc func boostButtonTapped() {
        Task {
            do {
                let res: MastodonPost
                if input.reposted {
                    res = try await MastodonEndpoint.DeleteRepost(post: input).request(with: environment)
                } else {
                    res = try await MastodonEndpoint.CreateRepost(post: input).request(with: environment)
                }
                await MainActor.run {
                    self.input(res)
                }
            } catch {
                await MainActor.run {
                    self.errorReport(error: error)
                }
            }
        }
    }
    
    @objc func favouriteButtonTapped() {
        Task {
            do {
                let res: MastodonPost
                if input.favourited {
                    res = try await MastodonEndpoint.DeleteFavourite(post: input).request(with: environment)
                } else {
                    res = try await MastodonEndpoint.CreateFavourite(post: input).request(with: environment)
                }
                await MainActor.run {
                    self.input(res)
                }
            } catch {
                await MainActor.run {
                    self.errorReport(error: error)
                }
            }
        }
    }
    
    @objc func addToBookmark() {
        Task {
            do {
                let res = try await MastodonEndpoint.CreateBookmark(post: input).request(with: environment)
                await MainActor.run {
                    self.input(res)
                }
            } catch {
                await MainActor.run {
                    self.errorReport(error: error)
                }
            }
        }
    }
    
    @objc func removeFromBookmark() {
        Task {
            do {
                let res = try await MastodonEndpoint.DeleteBookmark(post: input).request(with: environment)
                await MainActor.run {
                    self.input(res)
                }
            } catch {
                await MainActor.run {
                    self.errorReport(error: error)
                }
            }
        }
    }
                                
    @objc func openEditPostVC() {
        Task {
            do {
                let source = try await MastodonEndpoint.GetPostSource(input.id).request(with: environment)
                let userActivity = NSUserActivity(newPostWithMastodonUserToken: environment)
                let vc = NewPostViewController(userActivity: userActivity)
                vc.editPost = (post: input, source: source)
                present(ModalNavigationViewController(rootViewController: vc), animated: true)
            } catch {
                reportError(error: error)
            }
        }
    }
    
    @objc func openBunmyakuVC() {
        let bunmyakuVC = BunmyakuTableViewController.instantiate(.plain, environment: environment)
        bunmyakuVC.basePost = input.originalPost
        navigationController?.pushViewController(bunmyakuVC, animated: true)
    }
    
    @objc func openEmojiListVC() {
        let newVC = EmojiListTableViewController()
        newVC.emojis = (input.emojis ?? []) + (input.profileEmojis ?? [])
        newVC.account = input.account
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    @objc func confirmDeletePost() {
        let message = Defaults.deleteTootTeokure
            ? "失った信頼はもう戻ってきませんが、本当にこの投稿を削除しますか?"
            : "この投稿を削除しますか?"
        confirm(title: "投稿の削除", message: message, okButtonMessage: "削除", style: .destructive) { [weak self] res in
            guard res else { return }
            guard let strongSelf = self else { return }
            MastodonEndpoint.DeletePost(post: strongSelf.input).request(with: strongSelf.environment).then { [weak self] res in
                self?.navigationController?.popViewController(animated: true)
                self?.alert(title: "投稿を削除しました", message: "投稿を削除しました。\n※画面に反映されるには時間がかかる場合があります")
            }
        }
    }
    
    @objc func openAbuseVC() {
        let newVC = MastodonPostAbuseViewController.instantiate(input, environment: environment)
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    @objc func openShareSheet() {
        guard let url = input.originalPost.parsedUrl else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = othersButton
        vc.popoverPresentationController?.sourceRect = othersButton.bounds
        present(vc, animated: true, completion: nil)
    }
}
