//
//  AccountsPreferencesPaneViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/10.
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

import Cocoa
import Ikemen
import SnapKit
import Combine
import iMastMacCore
import SDWebImage

class AccountsPreferencesPaneViewController: NSViewController, PreferencesPaneProtocol {
    private lazy var v = AccountsPreferencesPaneView()
    var userTokens = [MastodonUserToken]()
    @objc var selectionIndexes: IndexSet = .init() {
        didSet {
            v.addOrRemoveSegmentedControl.setEnabled(!selectionIndexes.isEmpty, forSegment: 1)
        }
    }
    
    override func loadView() {
        // todo
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        title = "アカウント"
        v.addOrRemoveSegmentedControl.target = self
        v.addOrRemoveSegmentedControl.action = #selector(openAddAccountSheet(_:))
        v.accountsTableView.bind(.selectionIndexes, to: self, withKeyPath: "selectionIndexes", options: nil)
        v.accountsTableView.delegate = self
        v.accountsTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUserTokens), name: .userTokenChanged, object: nil)
        NotificationCenter.default.post(name: .userTokenChanged, object: nil)
    }
    
    func configureTabViewItem(item: NSTabViewItem) {
        item.label = "アカウント"
        item.image = NSImage(systemSymbolName: "at", accessibilityDescription: nil)
    }
    
    @objc func reloadUserTokens() {
        userTokens = MastodonUserToken.getAllUserTokens()
        DispatchQueue.mainSafeSync {
            v.accountsTableView.reloadData()
        }
    }
    
    @objc func openAddAccountSheet(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            presentAsSheet(AddMastodonAccountSheetViewController())
        case 1:
            removeSelectedAccounts()
        default:
            break
        }
    }
    
    @objc func removeSelectedAccounts() {
        do {
            for tokenIndex in selectionIndexes {
                let token = userTokens[tokenIndex]
                try token.delete()
            }
        } catch {
            NSAlert(error: error).beginSheetModal(for: view.window!, completionHandler: nil)
        }
        NotificationCenter.default.post(name: .userTokenChanged, object: nil)
    }
}

extension AccountsPreferencesPaneViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return userTokens.count
    }
}

extension AccountsPreferencesPaneViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let token = userTokens.safe(row) else {
            return nil
        }
        let view = NSView()
        let imageView = LayeredImageView() ※ {
            $0.wantsLayer = true
            $0.layer?.cornerRadius = 4
            $0.layer?.cornerCurve = .continuous
            $0.layer?.masksToBounds = true
        }
        if let avatarUrlString = token.avatarUrl {
            imageView.loadImage(url: URL(string: avatarUrlString))
        }
        let stackView = NSStackView(views: [
            NSTextField(labelWithString: token.name ?? token.screenName ?? "(null)") ※ {
                $0.setContentHuggingPriority(.required, for: .vertical)
            },
            NSTextField(labelWithString: "@\(token.acct)") ※ {
                $0.textColor = .secondaryLabelColor
                $0.setContentHuggingPriority(.required, for: .vertical)
            },
        ]) ※ {
            $0.alignment = .leading
            $0.spacing = 4
            $0.orientation = .vertical
            $0.setHuggingPriority(.required, for: .vertical)
        }
        view.addSubview(imageView)
        view.addSubview(stackView)
        imageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(4)
            make.width.equalTo(imageView.snp.height)
        }
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(8)
        }
        return view
    }
}
