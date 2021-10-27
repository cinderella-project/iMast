//
//  NewPostWindow.swift
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

class NewPostWindow: NSWindow {
    let toolBar = NSToolbar()
    
    init(userToken: MastodonUserToken) {
        super.init(contentRect: .zero, styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        isReleasedWhenClosed = false
        contentViewController = NewPostViewController(userToken: userToken)
        setContentSize(.init(width: 320, height: 320))
        title = "新規投稿"
        subtitle = "@" + userToken.acct
        toolBar.displayMode = .iconOnly
        toolBar.delegate = self
        toolbar = toolBar
    }
    
}

extension NewPostWindow: NSToolbarDelegate {
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
            item.action = #selector(NewPostViewController.sendPost)
            item.isBordered = true
            item.isNavigational = true
            return item
        default:
            return nil
        }
    }
}
