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

class AccountsPreferencesPaneViewController: NSViewController, PreferencesPaneProtocol {
    private lazy var content = AccountsPreferencesPaneView()
    var disposeBag = Set<AnyCancellable>()
    
    override func loadView() {
        // todo
        view = content
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        title = "アカウント"
        _ = content.addOrRemoveSegmentedControl ※ { c in
            c.target = self
            c.action = #selector(openAddAccountSheet)
        }
    }
    
    func configureTabViewItem(item: NSTabViewItem) {
        item.label = "アカウント"
        item.image = NSImage(systemSymbolName: "at", accessibilityDescription: nil)
    }
    
    @objc func openAddAccountSheet(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            presentAsSheet(AddMastodonAccountSheetViewController())
        default:
            break
        }
    }
}
