//
//  AnnouncementsViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2026/08/02.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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
import iMastiOSCore
import SwiftUI
import Ikemen
import Combine

class AnnouncementsViewController: UIViewController, Instantiatable, UITableViewDelegate {
    typealias Input = Void
    typealias Environment = MastodonUserToken

    internal let environment: Environment
    
    enum Section: Hashable {
        case mastodonAnnouncement(String)
    }

    enum Item: Hashable {
        case mastodonAnnouncement(String)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let refreshControl = UIRefreshControl()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var lastValidAnnouncements: [MastodonAnnouncement] = []
    private lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        guard let self else { return nil }
        
        switch itemIdentifier {
        case .mastodonAnnouncement(let id):
            guard let announcement = lastValidAnnouncements.first(where: { $0.id == id }) else {
                return nil
            }
            return TableViewCell<AnnouncementFromMastodonViewController>.dequeued(from: tableView, for: indexPath, input: announcement, parentViewController: self)
        }
    }
    
    required init(with input: Void, environment: MastodonUserToken) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        title = L10n.Localizable.Announcements.title
        
        refreshControl.addTarget(self, action: #selector(reloadAnnouncements), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        TableViewCell<AnnouncementFromMastodonViewController>.register(to: tableView)
        
        if (try? environment.announcements?.get()) == nil {
            environment.reloadAnnouncements()
        }
        
        environment.$announcements
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let announcements):
                    self.refreshControl.endRefreshing()
                    if #available(iOS 17.0, *) {
                        self.contentUnavailableConfiguration = nil
                    }
                    var snapshot = dataSource.plainSnapshot()
                    for announcment in announcements {
                        snapshot.appendSections([.mastodonAnnouncement(announcment.id)])
                        snapshot.appendItems([.mastodonAnnouncement(announcment.id)])
                        snapshot.reconfigureItems([.mastodonAnnouncement(announcment.id)])
                    }
                    self.lastValidAnnouncements = announcements
                    dataSource.apply(snapshot)
                    if #available(iOS 17.0, *) {
                        if announcements.isEmpty {
                            var config = UIContentUnavailableConfiguration.empty()
                            config.image = UIImage(systemName: "megaphone.fill")
                            config.text = L10n.Localizable.Announcements.Empty.title
                            config.secondaryText = L10n.Localizable.Announcements.Empty.subtitle(environment.app.instance.hostName)
                            self.contentUnavailableConfiguration = config
                        } else {
                            self.contentUnavailableConfiguration = nil
                        }
                    }
                case .failure(let error):
                    self.refreshControl.endRefreshing()
                    if #available(iOS 17.0, *) {
                        var config = ReadmoreView.makeUIContentUnavailableConfiguration(from: error)
                        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
                            guard let self else { return }
                            self.environment.reloadAnnouncements()
                        }
                        config.secondaryButtonProperties.primaryAction = UIAction { [weak self] _ in
                            guard let self else { return }
                            self.presentErrorDetailReport(error: error)
                        }
                        self.contentUnavailableConfiguration = config
                    } else {
                        self.errorReport(error: error)
                    }
                case .none:
                    if #available(iOS 17.0, *) {
                        self.contentUnavailableConfiguration = UIContentUnavailableConfiguration.loading()
                    } else {
                        self.refreshControl.beginRefreshing()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func reloadAnnouncements() {
        environment.reloadAnnouncements()
    }
}
