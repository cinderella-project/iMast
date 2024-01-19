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
    let othersMenuItem = UIBarButtonItem(
        image: UIImage(systemName: "ellipsis.circle"), style: .plain,
        target: nil, action: nil
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        self.title = L10n.UserProfile.title
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = othersMenuItem
       
        self.input(input)
        TableViewCell<UserProfileBioViewController>.register(to: tableView)
        TableViewCell<UserProfileFieldViewController>.register(to: tableView)
    }
    
    @objc func reload() {
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
        
        let checkLatestProfileCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        checkLatestProfileCell.textLabel?.text = L10n.UserProfile.checkLatestProfileInWeb
        checkLatestProfileCell.detailTextLabel?.text = self.input.url
        checkLatestProfileCell.accessoryType = .disclosureIndicator
        checkLatestProfileCell.accessibilityIdentifier = "checkLatestProfileCell"
        
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
            [
                self.infoCell
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
        
        if input.bio.toPlainText() != "" {
            let cell = UITableViewCell()
            cell.accessibilityIdentifier = "bioCell"
            cells[0].append(cell)
        }
        if let fields = input.fields {
            for index in fields.indices {
                let cell = UITableViewCell()
                cell.accessibilityIdentifier = "fieldCell"
                cell.tag = index
                cells[0].append(cell)
            }
        }
        if input.acct.contains("@") {
            cells[0].append(checkLatestProfileCell)
        }
        self.tableView.reloadData()
        
        var othersMenuItems = [UIMenuElement]()
        othersMenuItems.append(UIDeferredMenuElement { [weak self] completion in
            guard let strongSelf = self else {
                completion([])
                return
            }
            Task {
                completion(await strongSelf.buildRelationshipsMenu())
            }
        })
        othersMenuItem.menu = UIMenu(children: othersMenuItems)
    }
    
    func createAlertAction<T: MastodonEndpointProtocol>(endpoint: T, title: String, image: UIImage? = nil, confirm: String?) -> UIAction {
        let callAPI = { [environment] in
            endpoint
                .request(with: environment)
                .always(in: .main) { [weak self] in
                    self?.reload()
                }
        }
        if let confirm = confirm {
            return .init(title: title, image: image, attributes: .destructive) { [weak self] _ in
                self?.confirm(
                    title: "確認", message: confirm,
                    okButtonMessage: "はい", style: .destructive,
                    cancelButtonMessage: L10n.Localizable.cancel
                ) { result in
                    if result {
                        callAPI()
                    }
                }
            }
        } else {
            return .init(title: title, image: image) { _ in callAPI() }
        }
    }

    func buildRelationshipsMenu() async -> [UIMenuElement] {
        // UIDeferredMenuElement に UICommand を渡すとガン無視されるので UIAction を使う
        let shareCommand = UIAction(title: L10n.UserProfile.Actions.share, image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
            self?.openSharesheet()
        }
        let myScreenName = "@"+self.environment.screenName!
        let screenName = "@"+input.acct
        do {
            async let version = environment.getIntVersion()
            let relationship = try await MastodonEndpoint.Relationship.Get(accounts: [input]).request(with: environment)[0]
            var items = [UIMenuElement]()
            items.append(shareCommand)
            let isMe = myScreenName == screenName
            if !isMe { // 自分じゃない
                if !relationship.following { // 未フォロー
                    if !relationship.requested { // リクエストもしてない
                        items.append(self.createAlertAction(
                            endpoint: MastodonEndpoint.Relationship.Follow(target: self.input),
                            title: L10n.UserProfile.Actions.follow, image: UIImage(systemName: "person.badge.plus"),
                            confirm: nil
                        ))
                    } else { // フォローリクエスト中
                        items.append(self.createAlertAction(
                            endpoint: MastodonEndpoint.Relationship.Unfollow(target: self.input),
                            title: L10n.UserProfile.Actions.followRequestCancel, image: UIImage(systemName: "person.crop.circle.badge.xmark"),
                            confirm: screenName+"へのフォローリクエストを撤回しますか?"
                        ))
                    }
                } else { // フォロー済み
                    items.append(self.createAlertAction(
                        endpoint: MastodonEndpoint.Relationship.Unfollow(target: self.input),
                        title: L10n.UserProfile.Actions.unfollow, image: UIImage(systemName: "person.crop.circle.badge.minus"),
                        confirm: screenName+"のフォローを解除しますか?"
                    ))
                }
                if !relationship.muting { // 未ミュート
                    items.append(self.createAlertAction(
                        endpoint: MastodonEndpoint.Relationship.Mute(target: self.input),
                        title: L10n.UserProfile.Actions.mute, image: UIImage(systemName: "speaker.slash"),
                        confirm: screenName+"をミュートしますか?"
                    ))
                } else {
                    items.append(self.createAlertAction(
                        endpoint: MastodonEndpoint.Relationship.Unmute(target: self.input),
                        title: L10n.UserProfile.Actions.unmute, image: UIImage(systemName: "speaker.1"),
                        confirm: screenName+"のミュートを解除しますか?"
                    ))
                }
                if !relationship.blocking { // 未ブロック
                    items.append(self.createAlertAction(
                        endpoint: MastodonEndpoint.Relationship.Block(target: self.input),
                        title: L10n.UserProfile.Actions.block, image: UIImage(systemName: "nosign"),
                        confirm: screenName+"をブロックしますか?"
                    ))
                } else {
                    items.append(self.createAlertAction(
                        endpoint: MastodonEndpoint.Relationship.Unblock(target: self.input),
                        title: L10n.UserProfile.Actions.unblock,
                        confirm: screenName+"のブロックを解除しますか?"
                    ))
                }
            } else { // 自分なら
                items.append(UIAction(title: L10n.Localizable.favouritesList, image: UIImage(systemName: "star")) { [weak self] _ in
                    self?.openFavouritesList()
                })
                items.append(UIAction(title: L10n.UserProfile.Actions.followRequestsList, image: UIImage(systemName: "rectangle.stack.person.crop")) { [weak self] _ in
                    self?.openFollowRequestsList()
                })
            }
            if isMe || relationship.following {
                var shouldDisplayListAdder = false
                if let version = try? await version {
                    shouldDisplayListAdder = version.supportingFeature(.list)
                } else {
                    shouldDisplayListAdder = true
                }
                if shouldDisplayListAdder {
                    items.append(UIAction(title: "リストへ追加/削除", image: UIImage(systemName: "list.bullet")) { [weak self] _ in
                        self?.openListAdder()
                    })
                } else {
                    items.append(UIAction(title: "リストへ追加/削除", subtitle: "サーバーが古いので利用できません", image: UIImage(systemName: "list.bullet"), attributes: .disabled) { _ in })
                }
            }
            return items
        } catch {
            print(error)
            return [shareCommand]
        }
    }
    
    @objc func openSharesheet() {
        let activityItems: [Any] = [
            "\(self.input.name != "" ? self.input.name : self.input.screenName)さんのプロフィール - Mastodon",
            NSURL(string: self.input.url)!,
        ]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = othersMenuItem
        present(activityVC, animated: true, completion: nil)
    }
    
    @objc func openListAdder() {
        let newVC = ListAdderTableViewController(with: self.input, environment: self.environment)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    @objc func openFavouritesList() {
        let newVC = FavouritesTableViewController.instantiate(.init(), environment: self.environment)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    @objc func openFollowRequestsList() {
        let newVC = FollowRequestsListTableViewController.instantiate(environment: self.environment)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if cell.accessibilityIdentifier == "bioCell" {
            let cell = TableViewCell<UserProfileBioViewController>.dequeued(
                from: tableView,
                for: indexPath,
                input: input,
                parentViewController: self
            )
            cell.separatorInset = .zero
            return cell
        } else if cell.accessibilityIdentifier == "fieldCell" {
            let cell = TableViewCell<UserProfileFieldViewController>.dequeued(
                from: tableView,
                for: indexPath,
                input: (account: input, field: input.fields![cell.tag]),
                parentViewController: self
            )
            cell.separatorInset = .zero
            cell.layoutIfNeeded()
            return cell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = cells[0][indexPath.row]
            if cell.accessibilityIdentifier == "checkLatestProfileCell", let url = URL(string: input.url) {
                open(url: url)
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let newVC = UserTimelineViewController.instantiate(.plain, environment: self.environment)
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
        let cell = cells[indexPath.section][indexPath.row]
        return cell.accessoryType == .disclosureIndicator
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
