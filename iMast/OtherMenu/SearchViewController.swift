//
//  SearchViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/10/27.
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
import SafariServices
import Mew
import Ikemen

class SearchViewController: UITableViewController, UISearchBarDelegate, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken
    let environment: Environment

    required init(with input: Input, environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        self.refreshControl = .init() ※ { v in
            v.addTarget(self, action: #selector(reloadTrendTags), for: .valueChanged)
        }
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableView.automaticDimension
        self.reloadTrendTags()
        TableViewCell<MastodonPostCellViewController>.register(to: self.tableView)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        self.refreshControl?.beginRefreshing()
        environment.search(q: text).then { result in
            self.result = result
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc func reloadTrendTags() {
        // TODO: トレンドタグのwhitelistを外部指定できるようにする
        guard ["imastodon.net", "imastodon.blue"].contains(environment.app.instance.hostName) else {
            return
        }
        environment.getTrendTags().then { res in
            self.trendTags = res
            self.trendTagsArray = res.score.map { $0 }.sorted { $0.1 != $1.1 ? $0.1 > $1.1 : $0.0 < $1.0}
            print(self.trendTagsArray)
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
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
            let iconUrl = URL(string: account.avatarUrl, relativeTo: URL(string: "https://" + environment.app.instance.hostName)!)
            cell.imageView?.sd_setImage(with: iconUrl, completed: { (_, _, _, _) in
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            })
            return cell
        case 1:
            let hashtag = self.result!.hashtags[indexPath.row]
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "#" + hashtag.name
            return cell
        case 2:
            let post = self.result!.posts[indexPath.row]
            return TableViewCell<MastodonPostCellViewController>.dequeued(
                from: tableView,
                for: indexPath,
                input: .init(post: post, pinned: false),
                parentViewController: self
            )
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
            let vc = UserProfileTopViewController.instantiate(self.result!.accounts[indexPath.row], environment: self.environment)
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = HashtagTimeLineTableViewController(hashtag: self.result!.hashtags[indexPath.row].name, environment: self.environment)
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = MastodonPostDetailViewController.instantiate(self.result!.posts[indexPath.row], environment: self.environment)
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = HashtagTimeLineTableViewController(hashtag: self.trendTagsArray[indexPath.row].tag, environment: self.environment)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
