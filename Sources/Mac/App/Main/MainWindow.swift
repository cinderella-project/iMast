//
//  MainWindow.swift
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
import Ikemen

private extension NSToolbarItem.Identifier {
    static let currentView = NSToolbarItem.Identifier("iMast.currentView")
    static let newPost = NSToolbarItem.Identifier("iMast.newPost")
}

class MainWindow: NSWindow {
    lazy var vc = MainViewController()
    lazy var currentViewSegmentedControl = NSSegmentedControl(images: [
        NSImage(systemSymbolName: "house", accessibilityDescription: nil)!,
    ], trackingMode: .momentary, target: nil, action: nil) ※ {
        $0.setShowsMenuIndicator(true, forSegment: 0)
        let menu = NSMenu() ※ {
            $0.delegate = self
            $0.update()
        }
        $0.setMenu(menu, forSegment: 0)
    }
    
    init() {
        super.init(contentRect: .zero, styleMask: [.closable, .miniaturizable, .resizable, .titled], backing: .buffered, defer: true)
        isReleasedWhenClosed = false
        toolbar = NSToolbar() ※ {
            $0.displayMode = .iconOnly
            $0.delegate = self
        }
        if let userToken = MastodonUserToken.getLatestUsed() {
            subtitle = "@\(userToken.acct)"
        }
        // setup
        contentViewController = vc
        setContentSize(.init(width: 360, height: 560))
        center()
    }
    
    @objc override func newWindowForTab(_ sender: Any?) {
        let newWindow = MainWindow()
        addTabbedWindow(newWindow, ordered: .above)
    }
}

extension MainWindow: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .currentView,
            .newPost,
        ]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .currentView:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.isNavigational = true
            item.view = currentViewSegmentedControl
            return item
        case .newPost:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)
            item.action = #selector(TimelineViewController.newDocument(_:))
            return item
        default:
            return nil
        }
    }
}

extension MainWindow: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        for userToken in MastodonUserToken.getAllUserTokens() {
            menu.addItem(.init(title: userToken.acct, action: nil, keyEquivalent: "") ※ {
                $0.submenu = NSMenu() ※ {
                    $0.identifier = .init(userToken.id!)
                    $0.addItem(.init(title: "Home", action: #selector(changeViewController(_:)), keyEquivalent: "") ※ {
                        $0.image = NSImage(systemSymbolName: "house", accessibilityDescription: nil)
                        $0.identifier = .init("home")
                    })
                    $0.addItem(.init(title: "Local", action: #selector(changeViewController(_:)), keyEquivalent: "") ※ {
                        $0.image = NSImage(systemSymbolName: "person.2", accessibilityDescription: nil)
                        $0.identifier = .init("local")
                    })
                }
            })
        }
    }
    
    @objc func changeViewController(_ sender: NSMenuItem) {
        print(sender)
        guard let userTokenID = sender.menu?.identifier?.rawValue, let userToken = MastodonUserToken.initFromId(id: userTokenID) else {
            return
        }
        currentViewSegmentedControl.setImage(sender.image, forSegment: 0)
        subtitle = "@\(userToken.acct)"
        switch sender.identifier?.rawValue {
        case "home":
            vc.child = TimelineViewController(userToken: userToken, timelineType: .home)
        case "local":
            vc.child = TimelineViewController(userToken: userToken, timelineType: .local)
        default:
            fatalError("Unknown Identifier: \(sender.identifier?.rawValue)")
        }
    }
}
