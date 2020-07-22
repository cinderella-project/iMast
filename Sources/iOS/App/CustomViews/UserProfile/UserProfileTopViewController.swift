//
//  UserProfileTopViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/07.
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
import SwiftyJSON
import Accounts
import SafariServices
import Mew
import iMastiOSCore

class UserProfileTopViewController: StableTableViewController, Instantiatable, Injectable {
    typealias Input = MastodonAccount
    typealias Environment = MastodonUserToken

    internal let environment: Environment
    private var input: Input
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var loadAfter = false
    var isLoaded = false
    var externalServiceLinks: [(name: String, userId: String?, urls: [(appName: String, url: URL)])] = []
    
    let infoCell = UserProfileInfoTableViewCell()
    let bioCell = UserProfileBioTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reload(sender:)), for: .valueChanged)
        
        self.title = L10n.UserProfile.title
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle.fill"), style: .plain,
            target: self, action: #selector(moreButtonTapped(_:))
        )
       
        self.input(input)
    }
    
    @objc func reload(sender: UIRefreshControl) {
        MastodonEndpoint.GetAccount(target: input.id)
            .request(with: environment)
            .then { res in
                print(res)
                self.input(res)
                self.refreshControl?.endRefreshing()
            }
    }
    
    func input(_ input: Input) {
        self.input = input
        
        self.infoCell.userToken = environment
        self.infoCell.load(user: input)
        self.infoCell.separatorInset = .zero
        self.bioCell.userToken = environment
        self.bioCell.load(user: input)
        
        let tootCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        tootCell.textLabel?.text = L10n.UserProfile.Cells.Toots.title
        tootCell.accessoryType = .disclosureIndicator
        tootCell.detailTextLabel?.text = numToCommaString(input.postsCount)

        let followingCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        followingCell.textLabel?.text = L10n.UserProfile.Cells.Following.title
        followingCell.accessoryType = .disclosureIndicator
        followingCell.detailTextLabel?.text = numToCommaString(input.followingCount)

        let followersCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        followersCell.textLabel?.text = L10n.UserProfile.Cells.Followers.title
        followersCell.accessoryType = .disclosureIndicator
        followersCell.detailTextLabel?.text = numToCommaString(input.followersCount)

        let createdAt = input.createdAt
        let createdAtCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        createdAtCell.textLabel?.text = L10n.UserProfile.Cells.CreatedAt.title
        createdAtCell.detailTextLabel?.text = DateUtils.stringFromDate(
            createdAt,
            format: "yyyy/MM/dd HH:mm:ss"
        )

        let createdAtSabunCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        createdAtSabunCell.textLabel?.text = "登録してから"
        createdAtSabunCell.detailTextLabel?.text = numToCommaString(-Int(createdAt.timeIntervalSinceNow/60/60/24)) + "日"
        
        let tootDaysCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        tootDaysCell.textLabel?.text = "平均投稿/日"
        tootDaysCell.detailTextLabel?.text = numToCommaString(-(input.postsCount/Int(min(-1, createdAt.timeIntervalSinceNow/60/60/24))))
        self.externalServiceLinks = []

        if let niconicoUrl = input.niconicoUrl, let niconicoId = niconicoUrl.absoluteString.components(separatedBy: "/").last {
            self.externalServiceLinks.append((name: "niconico", userId: "user/\(niconicoId)", urls: [
                (appName: "Web", url: niconicoUrl),
                (appName: "niconicoアプリ", url: URL(string: "nicovideo://web?/User?id=\(niconicoId)")!),
                (appName: "nicocasアプリ(自動再生注意)", url: URL(string: "nicocas://user/\(niconicoId)")!),
            ]))
        }
        
        if let oauthAuths = input.oauthAuthentications {
            for auth in oauthAuths {
                if auth.provider != "pixiv" { continue }
                self.externalServiceLinks.append((name: "pixiv", userId: auth.uid, urls: [
                    (appName: "Web", url: URL(string: "https://www.pixiv.net/member.php?id="+auth.uid)!),
                ]))
            }
        }
        self.cells = [
            input.bio == "<p></p>" ? [self.infoCell] : [
                self.infoCell,
                self.bioCell,
            ],
            [
                tootCell,
                followingCell,
                followersCell,
                createdAtCell,
                createdAtSabunCell,
                tootDaysCell,
            ],
            self.externalServiceLinks.map({ service in
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = service.name
                cell.detailTextLabel?.text = service.userId
                cell.accessoryType = .disclosureIndicator
                return cell
            }),
        ]
        self.tableView.reloadData()
    }
    
    func createAlertAction<T: MastodonEndpointProtocol>(endpoint: T, title: String, confirm: String?) -> UIAlertAction {
        let callAPI = { [environment] in
            endpoint
                .request(with: environment)
                .always(in: .main) {
                    self.reload(sender: self.refreshControl!)
                }
        }
        if let confirm = confirm {
            return .init(title: title, style: .destructive) { _ in
                self.confirm(
                    title: "確認", message: confirm,
                    okButtonMessage: "はい", style: .destructive,
                    cancelButtonMessage: L10n.Localizable.cancel
                ).then { result in
                    if result {
                        callAPI()
                    }
                }
            }
        } else {
            return .init(title: title, style: .default) { _ in callAPI() }
        }
    }

    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        let myScreenName = "@"+self.environment.screenName!
        MastodonEndpoint.Relationship
            .Get(accounts: [input])
            .request(with: environment)
            .then { (relationships) in
                let relationship = relationships[0]
                let screenName = "@"+self.input.acct
                let actionSheet = UIAlertController(title: L10n.UserProfile.Actions.title, message: screenName, preferredStyle: UIAlertController.Style.actionSheet)
                actionSheet.popoverPresentationController?.barButtonItem = sender
                actionSheet.addAction(UIAlertAction(title: L10n.UserProfile.Actions.share, style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                    let activityItems: [Any] = [
                        (self.input.name != "" ? self.input.name : self.input.screenName).emojify()+"さんのプロフィール - Mastodon",
                        NSURL(string: self.input.url)!,
                    ]
                    let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    activityVC.popoverPresentationController?.barButtonItem = sender
                    self.present(activityVC, animated: true, completion: nil)
                }))
                if myScreenName != screenName { // 自分じゃない
                    if !relationship.following { // 未フォロー
                        if !relationship.requested { // リクエストもしてない
                            actionSheet.addAction(self.createAlertAction(
                                endpoint: MastodonEndpoint.Relationship.Follow(target: self.input),
                                title: L10n.UserProfile.Actions.follow, confirm: nil
                            ))
                        } else { // フォローリクエスト中
                            actionSheet.addAction(self.createAlertAction(
                                endpoint: MastodonEndpoint.Relationship.Unfollow(target: self.input),
                                title: L10n.UserProfile.Actions.followRequestCancel, confirm: screenName+"へのフォローリクエストを撤回しますか?"
                            ))
                        }
                    } else { // フォロー済み

                        actionSheet.addAction(self.createAlertAction(
                            endpoint: MastodonEndpoint.Relationship.Unfollow(target: self.input),
                            title: L10n.UserProfile.Actions.unfollow, confirm: screenName+"のフォローを解除しますか?"
                        ))
                        actionSheet.addAction(UIAlertAction(title: "リストへ追加/削除", style: .default, handler: { _ in
                            let newVC = ListAdderTableViewController(with: self.input, environment: self.environment)
                            self.navigationController?.pushViewController(newVC, animated: true)
                        }))
                    }
                    if !relationship.muting { // 未ミュート
                        actionSheet.addAction(self.createAlertAction(
                            endpoint: MastodonEndpoint.Relationship.Mute(target: self.input),
                            title: L10n.UserProfile.Actions.mute, confirm: screenName+"をミュートしますか?"
                        ))
                    } else {
                        actionSheet.addAction(self.createAlertAction(
                            endpoint: MastodonEndpoint.Relationship.Unmute(target: self.input),
                            title: L10n.UserProfile.Actions.unmute, confirm: screenName+"のミュートを解除しますか?"
                        ))
                    }
                    if !relationship.blocking { // 未ブロック
                        actionSheet.addAction(self.createAlertAction(
                            endpoint: MastodonEndpoint.Relationship.Block(target: self.input),
                            title: L10n.UserProfile.Actions.block, confirm: screenName+"をブロックしますか?"
                        ))
                    } else {
                        actionSheet.addAction(self.createAlertAction(
                            endpoint: MastodonEndpoint.Relationship.Unblock(target: self.input),
                            title: L10n.UserProfile.Actions.unblock, confirm: screenName+"のブロックを解除しますか?"
                        ))
                    }
                } else { // 自分なら
                    actionSheet.addAction(UIAlertAction(title: L10n.UserProfile.Actions.profileCard, style: .default, handler: { action in
                        let newVC = StoryboardScene.ProfileCard.initialScene.instantiate()
                        newVC.user = self.input
                        newVC.userToken = self.environment
                        self.navigationController?.pushViewController(newVC, animated: true)
                    }))
                    actionSheet.addAction(UIAlertAction(title: L10n.Localizable.favouritesList, style: .default, handler: { action in
                        self.navigationController?.pushViewController(FavouritesTableViewController.instantiate(.init(), environment: self.environment), animated: true)
                    }))
                    if self.input.isLocked {
                        actionSheet.addAction(UIAlertAction(title: L10n.UserProfile.Actions.followRequestsList, style: .default) { _ in
                            let newVC = FollowRequestsListTableViewController.instantiate(environment: self.environment)
                            self.navigationController?.pushViewController(newVC, animated: true)
                        })
                    }
                }
                actionSheet.addAction(UIAlertAction(title: L10n.UserProfile.Actions.cancel, style: UIAlertAction.Style.cancel))
                self.present(actionSheet, animated: true, completion: nil)
            }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let newVC = UserTimeLineTableViewController.instantiate(.plain, environment: self.environment)
                newVC.user = self.input
                newVC.title = "投稿一覧"
                self.navigationController?.pushViewController(newVC, animated: true)
                return
            } else if indexPath.row == 1 || indexPath.row == 2 {
                let newVC = FollowTableViewController.instantiate(
                    (type: indexPath.row == 1 ? .following : .followers, userId: self.input.id),
                    environment: self.environment
                )
                self.navigationController?.pushViewController(newVC, animated: true)
                return
            }
        }
        
        if indexPath.section == 2 {
            let urls = self.externalServiceLinks[indexPath.row].urls.filter { UIApplication.shared.canOpenURL($0.url) }
            func openUrl(url: URL) {
                if url.scheme?.starts(with: "http") ?? false {
                    self.open(url: url)
                } else {
                    UIApplication.shared.open(url)
                }
            }
            
            if urls.count == 0 {
                return
            } else if urls.count == 1 {
                openUrl(url: urls[0].url)
                return
            } else if urls.count > 1 {
                let alert = UIAlertController(title: "リンクの開き方", message: "リンクを開くアプリを選択してください。", preferredStyle: .alert)
                for url in urls {
                    alert.addAction(UIAlertAction(title: url.appName, style: .default, handler: { _ in
                        openUrl(url: url.url)
                    }))
                }
                alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 && self.cells[2].count > 0 {
            return "外部サービスのアカウント"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0, self.input.acct.contains("@") {
            return L10n.UserProfile.federatedUserWarning
        }
        return nil
    }
}
