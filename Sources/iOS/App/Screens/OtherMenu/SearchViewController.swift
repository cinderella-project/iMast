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
import Mew
import Ikemen
import iMastiOSCore

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
    
    var searchBar: UISearchBar!
    var trendTagsSnapshot = NSDiffableDataSourceSnapshot<Section, Body>()

    weak var presentor: UIViewController?

    enum Section {
        case accounts
        case toots
        case hashtags
        case trendTags
    }
    
    enum Body: Hashable {
        case account(MastodonAccount)
        case toot(MastodonPost)
        case hashtag(MastodonSearchResultHashtag)
        case trendTag(tag: String, score: Float)
    }
    
    var dataSource: TableViewDiffableDataSource<Section, Body>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = .init(tableView: tableView, cellProvider: { [environment] tableView, indexPath, body -> UITableViewCell? in
            switch body {
            case .account(let account):
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = account.name == "" ? account.screenName : account.name
                cell.detailTextLabel?.text = "@" + account.acct
                let iconUrl = URL(string: account.avatarUrl, relativeTo: URL(string: "https://" + environment.app.instance.hostName)!)
                cell.imageView?.loadImage(from: iconUrl) {
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                }
                return cell
            case .hashtag(let tag):
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "#" + tag.name
                return cell
            case .toot(let post):
                return TableViewCell<MastodonPostCellViewController>.dequeued(
                    from: tableView,
                    for: indexPath,
                    input: .init(post: post, pinned: false),
                    parentViewController: self
                )
            case .trendTag(let tag, let score):
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "#" + tag
                cell.detailTextLabel?.text = score.description
                return cell
            }
        })
        dataSource.sectionTitle = [
            .accounts: L10n.Search.Sections.Accounts.title,
            .toots: L10n.Search.Sections.Posts.title,
            .hashtags: L10n.Search.Sections.Hashtags.title,
        ]
        dataSource.defaultRowAnimation = .top
        
        title = L10n.Search.title
        tableView.delegate = self
        tableView.dataSource = dataSource
        self.searchBar.delegate = self
        self.refreshControl = .init() ※ { v in
            v.addTarget(self, action: #selector(reloadTrendTags), for: .valueChanged)
        }
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableView.automaticDimension
        self.reloadTrendTags()
        TableViewCell<MastodonPostCellViewController>.register(to: self.tableView)
    }
    
    var searchResultLoadTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        self.refreshControl?.beginRefreshing()
        searchResultLoadTask = Task {
            let result = try await environment.search(q: text)
            await MainActor.run { [weak self] in
                guard let self = self, !Task.isCancelled else {
                    return
                }
                var snapshot = self.dataSource.plainSnapshot()
                if result.accounts.count > 0 {
                    snapshot.appendSections([.accounts])
                    snapshot.appendItems(result.accounts.map { .account($0) }, toSection: .accounts)
                }
                if result.hashtags.count > 0 {
                    snapshot.appendSections([.hashtags])
                    snapshot.appendItems(result.hashtags.map { .hashtag($0) }, toSection: .hashtags)
                }
                if result.posts.count > 0 {
                    snapshot.appendSections([.toots])
                    snapshot.appendItems(result.posts.map { .toot($0) }, toSection: .toots)
                }
                self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func reloadTrendTags() {
        // TODO: トレンドタグのwhitelistを外部指定できるようにする
        guard ["imastodon.net", "imastodon.blue"].contains(environment.app.instance.hostName) else {
            return
        }
        MastodonEndpoint.GetTrendTagsThirdparty().request(with: environment).then { res in
            self.tableView.refreshControl?.endRefreshing()
            guard res.score.count > 0 else {
                return
            }
            let f = DateFormatter()
            f.dateStyle = .short
            f.timeStyle = .short
            self.dataSource.sectionTitle[.trendTags] = L10n.Search.Sections.TrendTags.title(f.string(from: res.updatedAt))

            self.trendTagsSnapshot = .init()
            let sortedArray = res.score.sorted { $0.1 != $1.1 ? $0.1 > $1.1 : $0.0 < $1.0}
            self.trendTagsSnapshot.appendSections([.trendTags])
            self.trendTagsSnapshot.appendItems(sortedArray.map { .trendTag(tag: $0.0, score: $0.1) }, toSection: .trendTags)
            self.dataSource.apply(self.trendTagsSnapshot)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item {
        case .account(let account):
            let vc = UserProfileTopViewController.instantiate(account, environment: self.environment)
            presentor?.navigationController?.pushViewController(vc, animated: true)
        case .hashtag(let hashtag):
            let vc = HashtagTimelineViewController(hashtag: hashtag.name, environment: self.environment)
            presentor?.navigationController?.pushViewController(vc, animated: true)
        case .toot(let post):
            let vc = MastodonPostDetailViewController.instantiate(post, environment: self.environment)
            presentor?.navigationController?.pushViewController(vc, animated: true)
        case .trendTag(let tag, _):
            let vc = HashtagTimelineViewController(hashtag: tag, environment: self.environment)
            presentor?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
        reloadTrendTags()
    }
    func didDismissSearchController(_ searchController: UISearchController) {
        dataSource.apply(trendTagsSnapshot, animatingDifferences: false, completion: nil)
    }
}
