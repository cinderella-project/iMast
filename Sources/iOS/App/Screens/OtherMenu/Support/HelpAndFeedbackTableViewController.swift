//
//  HelpAndFeedbackTableViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/24.
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
import SafariServices
import iMastiOSCore

class HelpAndFeedbackTableViewController: UITableViewController {
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section {
        case one
    }
    
    enum Item: Hashable {
        case web(title: String, url: URL)
        case feedback
    }
    
    lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: self.tableView, cellProvider: self.cellProvider)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        var snapshot = dataSource.plainSnapshot()
        snapshot.appendSections([.one])
        snapshot.appendItems([
            .web(title: L10n.Localizable.Help.title, url: URL(string: "https://cinderella-project.github.io/iMast/help/")!),
            .feedback,
            .web(title: "GitHub Issues", url: URL(string: "https://github.com/cinderella-project/iMast/issues")!),
        ], toSection: .one)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        title = L10n.Localizable.helpAndFeedback
    }

    // MARK: - Table view data source

    func cellProvider(_ tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? {
        let cell: UITableViewCell
        switch item {
        case .web(let title, let url):
            cell = .init(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = url.absoluteString
        case .feedback:
            cell = .init(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Feedback"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // MARK: - Table view Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .web(_, let url):
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        case .feedback:
            let vc = FeedbackViewController()
            self.show(vc, sender: self)
        }
    }
}
