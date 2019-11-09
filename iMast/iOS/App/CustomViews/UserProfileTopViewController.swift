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
    
    let infoCell = R.nib.userProfileInfoTableViewCell.firstView(owner: self as AnyObject)!
    let bioCell = R.nib.userProfileBioTableViewCell.firstView(owner: self as AnyObject)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reload(sender:)), for: .valueChanged)
        
        self.title = R.string.userProfile.title()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle.fill"), style: .plain,
            target: self, action: #selector(moreButtonTapped(_:))
        )
       
        self.input(input)
    }
    
    @objc func reload(sender: UIRefreshControl) {
        self.environment.getAccount(id: self.input.id).then { res in
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
        tootCell.textLabel?.text = R.string.userProfile.cellsTootsTitle()
        tootCell.accessoryType = .disclosureIndicator
        tootCell.detailTextLabel?.text = numToCommaString(input.postsCount)

        let followingCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        followingCell.textLabel?.text = R.string.userProfile.cellsFollowingTitle()
        followingCell.accessoryType = .disclosureIndicator
        followingCell.detailTextLabel?.text = numToCommaString(input.followingCount)

        let followersCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        followersCell.textLabel?.text = R.string.userProfile.cellsFollowersTitle()
        followersCell.accessoryType = .disclosureIndicator
        followersCell.detailTextLabel?.text = numToCommaString(input.followersCount)

        let createdAt = input.createdAt
        let createdAtCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        createdAtCell.textLabel?.text = R.string.userProfile.cellsCreatedAtTitle()
        createdAtCell.detailTextLabel?.text = DateUtils.stringFromDate(
            createdAt,
            format: "yyyy/MM/dd HH:mm:ss"
        )

        let createdAtSabunCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        createdAtSabunCell.textLabel?.text = "登録してから"
        createdAtSabunCell.detailTextLabel?.text = numToCommaString(-Int(createdAt.timeIntervalSinceNow/60/60/24)) + "日"
        
        let tootDaysCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        tootDaysCell.textLabel?.text = "平均トゥート/日"
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
            [
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

    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        let myScreenName = "@"+self.environment.screenName!
        self.environment.getRelationship([input]).then({ (relationships) in
            let relationship = relationships[0]
            let screenName = "@"+self.input.acct
            let actionSheet = UIAlertController(title: R.string.userProfile.actionsTitle(), message: screenName, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.popoverPresentationController?.barButtonItem = sender
            actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsShare(), style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
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
                        actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsFollow(), style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                            self.environment.follow(account: self.input).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        }))
                    } else { // フォローリクエスト中
                        actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsFollowRequestCancel(), style: UIAlertAction.Style.destructive, handler: { (action: UIAlertAction!) in
                            self.confirm(title: "確認", message: screenName+"へのフォローリクエストを撤回しますか?", okButtonMessage: "撤回", style: .destructive).then({ (result) in
                                if !result {
                                    return
                                }
                                self.environment.unfollow(account: self.input).then({ (res) in
                                    self.reload(sender: self.refreshControl!)
                                })
                            })
                        }))
                    }
                } else { // フォロー済み
                    actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsUnfollow(), style: UIAlertAction.Style.destructive, handler: { (action: UIAlertAction!) in
                        self.confirm(title: "確認", message: screenName+"のフォローを解除しますか?", okButtonMessage: "解除", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            self.environment.unfollow(account: self.input).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                    }))
                    actionSheet.addAction(UIAlertAction(title: "リストへ追加/削除", style: .default, handler: { _ in
                        let newVC = ListAdderTableViewController(with: self.input, environment: self.environment)
                        self.navigationController?.pushViewController(newVC, animated: true)
                    }))
                }
                if !relationship.muting { // 未ミュート
                    actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsMute(), style: UIAlertAction.Style.destructive, handler: { (action) in
                        self.confirm(title: "確認", message: screenName+"をミュートしますか?", okButtonMessage: "ミュート", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            self.environment.mute(account: self.input).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                    }))
                } else {
                    actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsUnmute(), style: UIAlertAction.Style.destructive, handler: { (action) in
                        self.confirm(title: "確認", message: screenName+"のミュートを解除しますか?", okButtonMessage: "ミュート解除", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            self.environment.unmute(account: self.input).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                    }))
                }
                if !relationship.blocking { // 未ブロック
                    actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsBlock(), style: UIAlertAction.Style.destructive, handler: { (action) in
                        self.confirm(title: "確認", message: screenName+"をブロックしますか?", okButtonMessage: "ブロック", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            self.environment.block(account: self.input).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                    }))
                } else {
                    actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsUnblock(), style: UIAlertAction.Style.destructive, handler: { (action) in
                        self.confirm(title: "確認", message: screenName+"のブロックを解除しますか?", okButtonMessage: "ブロック解除", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            self.environment.unblock(account: self.input).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                        
                    }))
                }
            } else { // 自分なら
                actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsProfileCard(), style: .default, handler: { action in
                    guard let newVC = R.storyboard.profileCard.instantiateInitialViewController() else {
                        return
                    }
                    newVC.user = self.input
                    self.navigationController?.pushViewController(newVC, animated: true)
                }))
                if self.input.isLocked {
                    actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsFollowRequestsList(), style: .default) { _ in
                        self.environment.followRequests().then { res in
                            let newVC = FollowRequestsListTableViewController.instantiate(environment: self.environment)
                            newVC.followRequests = res
                            self.navigationController?.pushViewController(newVC, animated: true)
                        }
                    })
                }
            }
            actionSheet.addAction(UIAlertAction(title: R.string.userProfile.actionsCancel(), style: UIAlertAction.Style.cancel))
            self.present(actionSheet, animated: true, completion: nil)
        })
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
                newVC.title = "トゥート一覧"
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
                    UIApplication.shared.openURL(url)
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
            return R.string.userProfile.federatedUserWarning()
        }
        return nil
    }
}
