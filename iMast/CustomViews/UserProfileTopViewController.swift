//
//  UserProfileTopViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/07.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Accounts
import SafariServices

class UserProfileTopViewController: StableTableViewController {

//    @IBOutlet weak var tootCell: UITableViewCell!
//    @IBOutlet weak var userIconView: UIImageView!
//    @IBOutlet weak var userNameView: UILabel!
//    @IBOutlet weak var userScreenNameView: UILabel!
//    @IBOutlet weak var followingCell: UITableViewCell!
//    @IBOutlet weak var followersCell: UITableViewCell!
//    @IBOutlet weak var createdAtCell: UITableViewCell!
//    @IBOutlet weak var tootDaysCell: UITableViewCell!
//    @IBOutlet weak var createdAtSabunCell: UITableViewCell!
    var moreButton: UIBarButtonItem!
//    @IBOutlet weak var relationShipLabel: UILabel!
    var loadAfter = false
    var isLoaded = false
    var user: MastodonAccount?
    var externalServiceLinks: [(name: String, userId: String?, url: URL)] = []
    
    let infoCell = Bundle.main.loadNibNamed("UserProfileInfoTableViewCell", owner: self, options: nil)!.first! as! UserProfileInfoTableViewCell
    let bioCell = Bundle.main.loadNibNamed("UserProfileBioTableViewCell", owner: self, options: nil)!.first! as! UserProfileBioTableViewCell
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        isLoaded = true
        if loadAfter {
            loadAfter = false
            load(user: user!)
        }
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reload(sender:)), for: .valueChanged)
        
        self.tableView.register(UINib(nibName: "UserProfileInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "profileInfo")
        self.title = "プロフィール"
        self.moreButton = UIBarButtonItem(image: UIImage(named: "More"), style: .plain, closure: { self.moreButtonTapped($0) })
        self.navigationItem.rightBarButtonItems = [
            self.moreButton,
        ]
        self.tableView.separatorInset = .zero
    }
    
    @objc func reload(sender: UIRefreshControl) {
        MastodonUserToken.getLatestUsed()!.getAccount(id: user!.id).then { res in
            print(res)
            self.load(user: res)
            self.refreshControl?.endRefreshing()
        }
    }
    
    func load(user: MastodonAccount) {
        self.user = user
        if isLoaded == false {
            loadAfter = true
            return
        }
        
        self.infoCell.load(user: user)
        self.bioCell.load(user: user)
        
        let tootCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        tootCell.textLabel?.text = "トゥート"
        tootCell.accessoryType = .disclosureIndicator
        tootCell.detailTextLabel?.text = numToCommaString(user.postsCount)

        let followingCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        followingCell.textLabel?.text = "フォロー"
        followingCell.detailTextLabel?.text = numToCommaString(user.followingCount)

        let followersCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        followersCell.textLabel?.text = "フォロワー"
        followersCell.detailTextLabel?.text = numToCommaString(user.followersCount)

        let createdAt = user.createdAt
        let createdAtCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        createdAtCell.textLabel?.text = "作成日時"
        createdAtCell.detailTextLabel?.text = DateUtils.stringFromDate(
            createdAt,
            format: "yyyy/MM/dd HH:mm:ss"
        )

        let createdAtSabunCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        createdAtSabunCell.textLabel?.text = "登録してから"
        createdAtSabunCell.detailTextLabel?.text = numToCommaString(-Int(createdAt.timeIntervalSinceNow/60/60/24)) + "日"
        
        let tootDaysCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        tootDaysCell.textLabel?.text = "平均トゥート/日"
        tootDaysCell.detailTextLabel?.text = numToCommaString(-(user.postsCount/Int(min(-1, createdAt.timeIntervalSinceNow/60/60/24))))
        self.externalServiceLinks = []

        if let niconicoUrl = user.niconicoUrl {
            let niconicoId = niconicoUrl.absoluteString.components(separatedBy: "/").last
            self.externalServiceLinks.append((name: "niconico", userId: niconicoId != nil ? "user/"+niconicoId! : nil, url: niconicoUrl))
        }
        
        if let oauthAuths = user.oauthAuthentications {
            for auth in oauthAuths {
                if auth.provider != "pixiv" { continue }
                self.externalServiceLinks.append((name: "pixiv", userId: auth.uid, url: URL(string: "https://www.pixiv.net/member.php?id="+auth.uid)!))
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

    @IBAction func moreButtonTapped(_ sender: Any) {
        guard let user = self.user else {
            return
        }
        let myScreenName = "@"+(MastodonUserToken.getLatestUsed()!.screenName!)
        MastodonUserToken.getLatestUsed()?.getRelationship([user]).then({ (relationships) in
            let relationship = relationships[0]
            let screenName = "@"+user.acct
            let actionSheet = UIAlertController(title: "アクション", message: screenName, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSheet.popoverPresentationController?.barButtonItem = self.moreButton
            actionSheet.addAction(UIAlertAction(title: "共有", style: UIAlertActionStyle.default, handler: {
                (action: UIAlertAction!) in
                let activityItems:[Any] = [
                    (user.name != "" ? user.name : user.screenName).emojify()+"さんのプロフィール - Mastodon",
                    NSURL(string: user.url)!
                ]
                let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.moreButton.value(forKey: "view") as? UIView
                activityVC.popoverPresentationController?.sourceRect = (self.moreButton.value(forKey: "view") as! UIView).bounds
                self.present(activityVC, animated: true, completion: nil)
            }))
            if myScreenName != screenName {
                if !relationship.following { // 未フォロー
                    if !relationship.requested { // 未フォロー
                        actionSheet.addAction(UIAlertAction(title: "フォローする", style: UIAlertActionStyle.default, handler: {
                            (action: UIAlertAction!) in
                            MastodonUserToken.getLatestUsed()?.follow(account: user).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        }))
                    } else {// フォローリクエスト中
                        actionSheet.addAction(UIAlertAction(title: "フォローリクエストの撤回", style: UIAlertActionStyle.destructive, handler: {
                            (action: UIAlertAction!) in
                            self.confirm(title: "確認", message: screenName+"へのフォローリクエストを撤回しますか?", okButtonMessage: "撤回", style: .destructive).then({ (result) in
                                if !result {
                                    return
                                }
                                MastodonUserToken.getLatestUsed()?.unfollow(account: user).then({ (res) in
                                    self.reload(sender: self.refreshControl!)
                                })
                            })
                        }))
                    }
                } else { // フォロー済み
                    actionSheet.addAction(UIAlertAction(title: "フォロー解除", style: UIAlertActionStyle.destructive, handler: {
                        (action: UIAlertAction!) in
                        self.confirm(title: "確認", message: screenName+"のフォローを解除しますか?", okButtonMessage: "解除", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            MastodonUserToken.getLatestUsed()?.unfollow(account: user).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                    }))
                }
                if !relationship.muting { // 未ミュート
                    actionSheet.addAction(UIAlertAction(title: "ミュート", style: UIAlertActionStyle.destructive, handler: { (action) in
                        self.confirm(title: "確認", message: screenName+"をミュートしますか?", okButtonMessage: "ミュート", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            MastodonUserToken.getLatestUsed()?.mute(account: user).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                    }))
                } else {
                    actionSheet.addAction(UIAlertAction(title: "ミュート解除", style: UIAlertActionStyle.destructive, handler: { (action) in
                        self.confirm(title: "確認", message: screenName+"のミュートを解除しますか?", okButtonMessage: "ミュート解除", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            MastodonUserToken.getLatestUsed()?.unmute(account: user).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                    }))
                }
                if !relationship.blocking { // 未ブロック
                    actionSheet.addAction(UIAlertAction(title: "ブロック", style: UIAlertActionStyle.destructive, handler: { (action) in
                        self.confirm(title: "確認", message: screenName+"をブロックしますか?", okButtonMessage: "ブロック", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            MastodonUserToken.getLatestUsed()?.block(account: user).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                    }))
                } else {
                    actionSheet.addAction(UIAlertAction(title: "ブロック解除", style: UIAlertActionStyle.destructive, handler: { (action) in
                        self.confirm(title: "確認", message: screenName+"のブロックを解除しますか?", okButtonMessage: "ブロック解除", style: .destructive).then({ (result) in
                            if !result {
                                return
                            }
                            MastodonUserToken.getLatestUsed()?.unblock(account: user).then({ (res) in
                                self.reload(sender: self.refreshControl!)
                            })
                        })
                        
                    }))
                }
            } else {
                actionSheet.addAction(UIAlertAction(title: "名刺", style: .default, handler: { action in
                    let storyboard = UIStoryboard(name: "ProfileCard", bundle: nil)
                    let newVC = storyboard.instantiateInitialViewController()! as! ProfileCardViewController
                    newVC.user = user
                    self.navigationController?.pushViewController(newVC, animated: true)
                }))
                if user.isLocked {
                    actionSheet.addAction(UIAlertAction(title: "フォローリクエスト一覧", style: .default) { _ in
                        MastodonUserToken.getLatestUsed()?.followRequests().then { res in
                            let newVC = FollowRequestsListTableViewController()
                            newVC.followRequests = res
                            self.navigationController?.pushViewController(newVC, animated: true)
                        }
                    })
                }
            }
            actionSheet.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel))
            self.present(actionSheet, animated: true, completion: nil)
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return -1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let newVC = UserTimeLineTableViewController()
                newVC.user = self.user!
                newVC.title = "トゥート一覧"
                self.navigationController?.pushViewController(newVC, animated: true)
                return
            }
        }
        
        if indexPath.section == 2 {
            let safariVC = SFSafariViewController(url: self.externalServiceLinks[indexPath.row].url)
            self.present(safariVC, animated: true, completion: nil)
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
}

func openUserProfile(user: MastodonAccount) -> UserProfileTopViewController {
    let newVC = UserProfileTopViewController(style: .grouped)
    newVC.load(user: user)
    return newVC
}
