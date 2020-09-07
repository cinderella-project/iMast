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
        v.setTitle("⋯", for: .normal)
        v.setTitleColor(.gray, for: .normal)
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
        othersButton.addTarget(self, action: #selector(self.othersButtonTapped), for: .touchUpInside)
        
        self.input(input)
    }
    
    func input(_ input: Input) {
        self.input = input
        boostButton.setTitleColor(input.reposted ? Asset.barBoost.color : .gray, for: .normal)
        favouriteButton.setTitleColor(input.favourited ? Asset.barFavourite.color : .gray, for: .normal)
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
        if input.reposted {
            environment.unrepost(post: input).then { [weak self] res in
                self?.input(res)
            }
        } else {
            environment.repost(post: input).then { [weak self] res in
                self?.input(res)
            }
        }
    }
    
    @objc func favouriteButtonTapped() {
        if input.favourited {
            environment.unfavourite(post: input).then { [weak self] res in
                self?.input(res)
            }
        } else {
            environment.favourite(post: input).then { [weak self] res in
                self?.input(res)
            }
        }
    }
    
    @objc func othersButtonTapped() {
        let actionSheet = UIAlertController(title: "アクション", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.popoverPresentationController?.sourceView = self.othersButton
        actionSheet.popoverPresentationController?.sourceRect = self.othersButton.bounds
        actionSheet.popoverPresentationController?.permittedArrowDirections = [.up]
        // ---
        actionSheet.addAction(.init(title: "文脈", style: .default) { [weak self] _ in
            self?.openBunmyakuVC()
        })
        if input.hasCustomEmoji { // カスタム絵文字がある
            actionSheet.addAction(.init(title: "カスタム絵文字一覧", style: .default) { [weak self] _ in
                self?.openEmojiListVC()
            })
        }
        if environment.screenName == input.account.acct {
            actionSheet.addAction(.init(title: "削除", style: .destructive) { [weak self] _ in
                let message = Defaults[.deleteTootTeokure]
                    ? "失った信頼はもう戻ってきませんが、本当にこの投稿を削除しますか?"
                    : "この投稿を削除しますか?"
                self?.confirm(title: "投稿の削除", message: message, okButtonMessage: "削除", style: .destructive).then { [weak self] res in
                    guard res else { return }
                    guard let strongSelf = self else { return }
                    strongSelf.environment.delete(post: strongSelf.input).then { [weak self] res in
                        self?.navigationController?.popViewController(animated: true)
                        self?.alert(title: "投稿を削除しました", message: "投稿を削除しました。\n※画面に反映されるには時間がかかる場合があります")
                    }
                }
            })
        }
        actionSheet.addAction(.init(title: "通報", style: .destructive) { [weak self] _ in
            self?.openAbuseVC()
        })
        actionSheet.addAction(.init(title: "共有", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            guard let url = strongSelf.input.originalPost.parsedUrl else { return }
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            vc.popoverPresentationController?.sourceView = strongSelf.othersButton
            vc.popoverPresentationController?.sourceRect = strongSelf.othersButton.bounds
            strongSelf.present(vc, animated: true, completion: nil)
        })
        actionSheet.addAction(.init(title: "キャンセル", style: UIAlertAction.Style.cancel))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openBunmyakuVC() {
        let bunmyakuVC = BunmyakuTableViewController.instantiate(.plain, environment: environment)
        bunmyakuVC.basePost = input.originalPost
        navigationController?.pushViewController(bunmyakuVC, animated: true)
    }
    
    func openEmojiListVC() {
        let newVC = EmojiListTableViewController()
        newVC.emojis = (input.emojis ?? []) + (input.profileEmojis ?? [])
        newVC.account = input.account
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    func openAbuseVC() {
        let newVC = MastodonPostAbuseViewController.instantiate(input, environment: environment)
        newVC.placeholder = "『\(input.status.pregReplace(pattern: "<.+?>", with: ""))』を通報します。\n詳細をお書きください（必須ではありません）"
        navigationController?.pushViewController(newVC, animated: true)
    }
}
