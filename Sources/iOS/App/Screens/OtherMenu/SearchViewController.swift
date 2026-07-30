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
    typealias Input = String
    typealias Environment = MastodonUserToken
    let input: Input
    let environment: Environment

    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var searchBar: UISearchBar!

    weak var presentor: UIViewController?

    enum Section {
        case accounts
        case toots
        case hashtags
    }
    
    enum Body: Hashable {
        case account(MastodonAccount)
        case toot(MastodonPost)
        case hashtag(MastodonSearchResultHashtag)
    }
    
    var dataSource: TableViewDiffableDataSource<Section, Body>!
    var lastSearchWasEmpty = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = .init(tableView: tableView, cellProvider: { [environment] tableView, indexPath, body -> UITableViewCell? in
            switch body {
            case .account(let account):
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = account.name == "" ? account.screenName : account.name
                cell.detailTextLabel?.text = "@" + account.acct
                let iconUrl = URL(string: account.avatarUrl, relativeTo: environment.app.instance.url)!
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
        if searchBar == nil, !input.isEmpty { // InquiryWithAnotherAccount
            searchBar = .init()
            if presentor == nil {
                presentor = self
            }
        }
        self.searchBar.delegate = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableView.automaticDimension
        TableViewCell<MastodonPostCellViewController>.register(to: self.tableView)
    }
    
    var searchResultLoadTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !input.isEmpty {
            searchBar.text = input
            startSearch()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        startSearch()
    }
    
    func startSearch() {
        guard let text = searchBar.text else {
            return
        }
        self.refreshControl?.beginRefreshing()
        self.dataSource.apply(.init())
        searchResultLoadTask = Task {
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.searchResultLoadTask = nil
                    if #available(iOS 17.0, *) {
                        self?.setNeedsUpdateContentUnavailableConfiguration()
                    }
                }
            }
            let result = try await environment.search(q: text)
            await MainActor.run { [weak self] in
                guard let self = self, !Task.isCancelled else {
                    return
                }
                self.lastSearchWasEmpty = true
                var snapshot = self.dataSource.plainSnapshot()
                if result.accounts.count > 0 {
                    self.lastSearchWasEmpty = false
                    snapshot.appendSections([.accounts])
                    snapshot.appendItems(result.accounts.map { .account($0) }, toSection: .accounts)
                }
                if result.hashtags.count > 0 {
                    self.lastSearchWasEmpty = false
                    snapshot.appendSections([.hashtags])
                    snapshot.appendItems(result.hashtags.map { .hashtag($0) }, toSection: .hashtags)
                }
                if result.posts.count > 0 {
                    self.lastSearchWasEmpty = false
                    snapshot.appendSections([.toots])
                    snapshot.appendItems(result.posts.map { .toot($0) }, toSection: .toots)
                }
                self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
                self.refreshControl?.endRefreshing()
            }
        }
        if #available(iOS 17.0, *) {
            self.setNeedsUpdateContentUnavailableConfiguration()
        }
    }

    @available(iOS 17.0, *)
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        guard dataSource.snapshot().itemIdentifiers.isEmpty else {
            contentUnavailableConfiguration = nil
            return
        }
        guard searchResultLoadTask == nil else {
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.loading()
            return
        }
        contentUnavailableConfiguration = lastSearchWasEmpty ? UIContentUnavailableConfiguration.search() : nil
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
        }
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
    func didDismissSearchController(_ searchController: UISearchController) {
        lastSearchWasEmpty = false
        dataSource.apply(.init(), animatingDifferences: false, completion: nil)
        if #available(iOS 17.0, *) {
            setNeedsUpdateContentUnavailableConfiguration()
        }
    }
}
