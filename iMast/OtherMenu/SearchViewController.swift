//
//  SearchViewController.swift
//  iMast
//
//  Created by user on 2018/10/27.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import UIKit
import SafariServices

class SearchViewController: UITableViewController, UISearchBarDelegate {
    var result: MastodonSearchResult?
    let searchBar = UISearchBar()
    var trendTags: ThirdpartyTrendsTags?
    var trendTagsArray: [(tag: String, score: Float)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.tableHeaderView = self.searchBar
        searchBar.sizeToFit()
        self.title = R.string.search.title()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        self.refreshControl = UIRefreshControl { _ in
            self.reloadTrendTags()
            self.refreshControl?.endRefreshing()
        }
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableView.automaticDimension
        self.reloadTrendTags()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        self.refreshControl?.beginRefreshing()
        MastodonUserToken.getLatestUsed()!.search(q: text).then { result in
            self.result = result
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func reloadTrendTags() {
        guard let token = MastodonUserToken.getLatestUsed() else {
            return
        }
        // TODO: トレンドタグのwhitelistを外部指定できるようにする
        guard ["imastodon.net", "imastodon.blue"].contains(token.app.instance.hostName) else {
            return
        }
        token.getTrendTags().then { res in
            self.trendTags = res
            self.trendTagsArray = res.score.map { $0 }.sorted { $0.1 != $1.1 ? $0.1 > $1.1 : $0.0 < $1.0}
            print(self.trendTagsArray)
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return result?.accounts.count ?? 0
        case 1:
            return result?.hashtags.count ?? 0
        case 2:
            return result?.posts.count ?? 0
        case 3:
            return result == nil ? trendTagsArray.count : 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard self.tableView(tableView, numberOfRowsInSection: section) > 0 else {
            return nil
        }
        switch section {
        case 0:
            return R.string.search.sectionsAccountsTitle()
        case 1:
            return R.string.search.sectionsHashtagsTitle()
        case 2:
            return R.string.search.sectionsPostsTitle()
        case 3:
            guard let trendTags = self.trendTags else {
                return nil
            }
            let f = DateFormatter()
            f.dateStyle = .short
            f.timeStyle = .short
            return R.string.search.sectionsTrendTagsTitle(f.string(from: trendTags.updatedAt))
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let account = self.result!.accounts[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = account.name == "" ? account.screenName : account.name
            cell.detailTextLabel?.text = "@" + account.acct
            let iconUrl = URL(string: account.avatarUrl, relativeTo: URL(string: "https://" + MastodonUserToken.getLatestUsed()!.app.instance.hostName)!)
            cell.imageView?.sd_setImage(with: iconUrl, completed: { (_, _, _, _) in
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            })
            return cell
        case 1:
            let hashtag = self.result!.hashtags[indexPath.row]
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "#" + hashtag
            return cell
        case 2:
            let post = self.result!.posts[indexPath.row]
            let cell = MastodonPostCell.getInstance()
            cell.load(post: post)
            return cell
        case 3:
            let tag = self.trendTagsArray[indexPath.row]
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "#" + tag.tag
            cell.detailTextLabel?.text = tag.score.description
            return cell
        default:
            fatalError("what")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = openUserProfile(user: self.result!.accounts[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = HashtagTimeLineTableViewController(hashtag: self.result!.hashtags[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = R.storyboard.mastodonPostDetail.instantiateInitialViewController()!
            vc.load(post: self.result!.posts[indexPath.row])
        case 3:
            let vc = HashtagTimeLineTableViewController(hashtag: self.trendTagsArray[indexPath.row].tag)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
