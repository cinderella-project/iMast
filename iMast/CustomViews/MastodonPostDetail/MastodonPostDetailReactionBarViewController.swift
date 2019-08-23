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
        v.setTitle("…", for: .normal)
        v.setTitleColor(.gray, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let stackView = UIStackView(arrangedSubviews: [
            replyButton,
            boostButton,
            favouriteButton,
            othersButton,
        ]) ※ { v in
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
        boostButton.setTitleColor(input.reposted ? ColorSet.boostedBar : .gray, for: .normal)
        favouriteButton.setTitleColor(input.favourited ? ColorSet.favouriteBar : .gray, for: .normal)
    }
    
    @objc func openReplyVC() {
        let post = self.input.originalPost
        let vc = R.storyboard.newPost.instantiateInitialViewController()!
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
        actionSheet.addAction(UIAlertAction(title: "文脈", style: UIAlertAction.Style.default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            strongSelf.environment.context(post: strongSelf.input).then { [weak self] res in
                guard let strongSelf = self else { return }
                let posts = res.ancestors + [strongSelf.input] + res.descendants
                let bunmyakuVC = TimeLineTableViewController()
                bunmyakuVC.posts = posts
                bunmyakuVC.isReadmoreEnabled = false
                bunmyakuVC.title = "文脈"
                strongSelf.navigationController?.pushViewController(bunmyakuVC, animated: true)
            }
        }))
        if (input.emojis?.count ?? 0) + (input.profileEmojis?.count ?? 0) > 0 { // カスタム絵文字がある
            actionSheet.addAction(UIAlertAction(title: "カスタム絵文字一覧", style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                let newVC = EmojiListTableViewController()
                newVC.emojis = (strongSelf.input.emojis ?? []) + (strongSelf.input.profileEmojis ?? [])
                newVC.account = strongSelf.input.account
                strongSelf.navigationController?.pushViewController(newVC, animated: true)
            }))
        }
        if environment.screenName == input.account.acct {
            actionSheet.addAction(UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive, handler: { [weak self] (action) in
                let message = Defaults[.deleteTootTeokure]
                    ? "失った信頼はもう戻ってきませんが、本当にこのトゥートを削除しますか?"
                    : "この投稿を削除しますか?"
                self?.confirm(title: "投稿の削除", message: message, okButtonMessage: "削除", style: .destructive).then { [weak self] res in
                    if !res {
                        return
                    }
                    guard let strongSelf = self else { return }
                    strongSelf.environment.delete(post: strongSelf.input).then { [weak self] res in
                        self?.navigationController?.popViewController(animated: true)
                        self?.alert(title: "投稿を削除しました", message: "投稿を削除しました。\n※画面に反映されるには時間がかかる場合があります")
                    }
                }
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "通報", style: UIAlertAction.Style.destructive, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            let newVC = MastodonPostAbuseViewController()
            newVC.targetPost = strongSelf.input
            newVC.placeholder = "『\(strongSelf.input.status.pregReplace(pattern: "<.+?>", with: ""))』を通報します。\n詳細をお書きください（必須ではありません）"
            strongSelf.navigationController?.pushViewController(newVC, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel))
        self.present(actionSheet, animated: true, completion: nil)
    }
}
