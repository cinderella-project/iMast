//
//  NewPostWindowController.swift
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
import iMastMacCore

private extension NSToolbarItem.Identifier {
    static let send = NSToolbarItem.Identifier("iMast.send")
}

class NewPostWindowController: NSWindowController {
    let toolBar = NSToolbar()
    
    init(userToken: MastodonUserToken) {
        let window = NSWindow(contentViewController: NewPostViewController(userToken: userToken))
        super.init(window: window)
        window.setContentSize(.init(width: 320, height: 320))
        window.title = "新規投稿"
        window.subtitle = "@" + userToken.acct
        toolBar.displayMode = .iconOnly
        toolBar.delegate = self
        window.toolbar = toolBar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewPostWindowController: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .send,
        ]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .send:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = NSImage(systemSymbolName: "paperplane", accessibilityDescription: nil)
            item.action = #selector(NewPostViewController.send)
            item.isNavigational = true
            return item
        default:
            return nil
        }
    }
}
