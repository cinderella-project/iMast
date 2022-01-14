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
        boostButton.setTitleColor(input.reposted ? Asset.barBoost.color : .gray, for: .normal)
        favouriteButton.setTitleColor(input.favourited ? Asset.barFavourite.color : .gray, for: .normal)

        // build
        var othersMenuChildrens = [UICommand]()
        othersMenuChildrens.append(.init(title: "共有", image: UIImage(systemName: "square.and.arrow.up"), action: #selector(openShareSheet)))
        othersMenuChildrens.append(.init(title: "文脈", image: UIImage(systemName: "list.bullet.indent"), action: #selector(openBunmyakuVC)))
        if input.hasCustomEmoji {
            othersMenuChildrens.append(.init(title: "カスタム絵文字一覧", action: #selector(openEmojiListVC)))
        }
        if environment.screenName == input.account.acct {
            othersMenuChildrens.append(.init(title: "削除", image: UIImage(systemName: "trash"), action: #selector(confirmDeletePost), attributes: .destructive))
        }
        othersMenuChildrens.append(.init(title: "通報", image: UIImage(systemName: "exclamationmark.bubble"), action: #selector(openAbuseVC)))
        othersButton.menu = UIMenu(children: othersMenuChildrens)
    }
    
    @objc func openReplyVC() {
        let post = self.input.originalPost
        let vc = StoryboardScene.NewPost.initialScene.instantiate()
        vc.userToken = environment
        vc.replyToPost = post
        vc.title = "返信"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func boostButtonTapped() {
        let promise = input.reposted
        ? MastodonEndpoint.DeleteRepost(post: input).request(with: environment)
        : MastodonEndpoint.CreateRepost(post: input).request(with: environment)
        promise.then { [weak self] res in
            self?.input(res)
        }
    }
    
    @objc func favouriteButtonTapped() {
        let promise = input.favourited
        ? MastodonEndpoint.DeleteFavourite(post: input).request(with: environment)
        : MastodonEndpoint.CreateFavourite(post: input).request(with: environment)
        promise.then { [weak self] res in
            self?.input(res)
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
        newVC.placeholder = "『\(input.status.pregReplace(pattern: "<.+?>", with: ""))』を通報します。\n詳細をお書きください（必須ではありません）"
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
