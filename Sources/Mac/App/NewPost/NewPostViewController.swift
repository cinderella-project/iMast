//
//  NewPostViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/01.
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

import Cocoa
import Ikemen
import iMastMacCore

class NewPostViewController: NSViewController {
    let userToken: MastodonUserToken
    let textView = NSTextView() ※ {
        $0.isEditable = true
        $0.isRichText = false
        $0.autoresizingMask = .width
        $0.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    }
    lazy var scrollView = NSScrollView() ※ {
        $0.documentView = textView
        $0.hasVerticalScroller = true
        $0.contentInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    }
    @objc dynamic var text = ""
    
    init(userToken: MastodonUserToken) {
        self.userToken = userToken
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = scrollView
    }
    
    override func viewDidLoad() {
        textView.bind(.value, to: self, withKeyPath: "text", options: [.continuouslyUpdatesValue: true])
    }
    
    @objc func sendPost(_ sender: Any) {
        let alert = NSAlert()
        alert.informativeText = "送信中…"
        alert.beginSheetModal(for: view.window!, completionHandler: nil)
        userToken.newPost(status: text).then(in: .main) { [weak self] post in
            print(post)
            self?.view.window?.close()
        }.catch { error in
            print(error)
        }
    }
}
