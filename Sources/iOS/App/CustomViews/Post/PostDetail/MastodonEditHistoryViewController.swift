//
//  MastodonEditHistoryViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/03/31.
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

class MastodonEditHistoryViewController: UITableViewController, Instantiatable {
    typealias Input = MastodonID
    typealias Environment = MastodonUserToken
    
    let input: Input
    let environment: Environment
    var contents: [MastodonPostContent] = []

    private let formatter = DateFormatter()

    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(style: .grouped)
        formatter.dateStyle = .long
        formatter.timeStyle = .long
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = L10n.Localizable.EditHistory.title
        TableViewCell<MastodonPostDetailContentViewController>.register(to: tableView)
        
        MastodonEndpoint.GetPostEditHistory(input).request(with: environment).then(in: .main) { history in
            self.contents = history
            self.tableView.reloadData()
        }.catch { error in
            print(error)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contents.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formatter.string(from: contents[section].createdAt)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return L10n.Localizable.EditHistory.Desc.original
        } else {
            var changed: [String] = []
            let previous = contents[section-1]
            let current = contents[section]
            if previous.status != current.status {
                changed.append(L10n.Localizable.EditHistory.Desc.Diff.content)
            }
            if previous.sensitive != current.sensitive {
                changed.append(L10n.Localizable.EditHistory.Desc.Diff.sensitive)
            }
            if previous.spoilerText != current.spoilerText {
                changed.append(L10n.Localizable.EditHistory.Desc.Diff.cw)
            }
            if previous.attachments.count != current.attachments.count {
                changed.append(L10n.Localizable.EditHistory.Desc.Diff.attachments)
            } else if current.attachments.count > 0 {
                for i in 0..<current.attachments.count {
                    if previous.attachments[i].url != current.attachments[i].url {
                        changed.append(L10n.Localizable.EditHistory.Desc.Diff.attachments)
                        break
                    }
                }
            }
            return L10n.Localizable.EditHistory.Desc.Diff.template(ListFormatter.localizedString(byJoining: changed))
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = contents[indexPath.section]
        return TableViewCell<MastodonPostDetailContentViewController>.dequeued(
            from: tableView,
            for: indexPath,
            input: content,
            output: { [weak self] in
                guard let tableView = self?.tableView else { return }
                tableView.beginUpdates()
                tableView.endUpdates()
            },
            parentViewController: self
        )
    }
}
