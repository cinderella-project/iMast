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
    
    override var contentViewController: NSViewController? {
        willSet {
            // 適当に contentViewController を入れ替えると frame.size が .zero なせいでウインドウの大きさがそっちにひっぱられる
            // ので入れ替え時にサイズを自分で引き継がせる
            if let current = contentView, let newView = newValue?.view {
                newView.setFrameSize(current.frame.size)
            }
        }
    }
    
    deinit {
        print("deinit", self)
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
        if let userToken = MastodonUserToken.getLatestUsed() {
            contentViewController = TimelineViewController(userToken: userToken, timelineType: .home)
        }
        setContentSize(.init(width: 360, height: 560))
        bind(.title, to: self, withKeyPath: "contentViewController.title", options: nil)
        center()
    }
    
    @objc override func newWindowForTab(_ sender: Any?) {
        let newWindow = MainWindow()
        addTabbedWindow(newWindow, ordered: .above)
        newWindow.makeKeyAndOrderFront(sender)
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if super.performKeyEquivalent(with: event) {
            return true
        }
        
        if event.modifierFlags.contains(.command),
           let number = Int(event.characters ?? ""), number > 0,
           let tabGroup = tabGroup,
           let window = number == 9 ? tabGroup.windows.last : tabGroup.windows.safe(number - 1)
        {
            tabGroup.selectedWindow = window
            return true
        }
        
        return false
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
            item.menuFormRepresentation = .init(title: L10n.Timeline.switchTimelines, action: nil, keyEquivalent: "") ※ {
                $0?.submenu = currentViewSegmentedControl.menu(forSegment: 0)
            }
            return item
        case .newPost:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)
            item.action = #selector(TimelineViewController.newDocument(_:))
            item.isBordered = true
            item.menuFormRepresentation = .init(title: L10n.Timeline.newPost, action: #selector(TimelineViewController.newDocument(_:)), keyEquivalent: "")
            return item
        default:
            return nil
        }
    }
}

extension MainWindow: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        func addMenuItems(for userToken: MastodonUserToken, menu: NSMenu) {
            menu.addItem(.init(title: L10n.Timeline.home, action: #selector(changeViewController(_:)), keyEquivalent: "") ※ {
                $0.image = NSImage(systemSymbolName: "house", accessibilityDescription: nil)
                $0.identifier = .init("home")
            })
            menu.addItem(.init(title: L10n.Timeline.local, action: #selector(changeViewController(_:)), keyEquivalent: "") ※ {
                $0.image = NSImage(systemSymbolName: "person.2", accessibilityDescription: nil)
                $0.identifier = .init("local")
            })
            menu.addItem(.init(title: L10n.Timeline.federated, action: #selector(changeViewController(_:)), keyEquivalent: "") ※ {
                $0.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
                $0.identifier = .init("federated")
            })
        }
        let maybeUserToken = (contentViewController as? MaybeHasUserToken)?.getUserTokenIfAvailable()
        if let userToken = maybeUserToken {
            menu.addItem(.init(title: "@" + userToken.acct, action: nil, keyEquivalent: ""))
            menu.identifier = .init(userToken.id!)
            addMenuItems(for: userToken, menu: menu)
            menu.addItem(.separator())
        }
        for userToken in MastodonUserToken.getAllUserTokens() {
            menu.addItem(.init(title: userToken.acct, action: nil, keyEquivalent: "") ※ {
                if userToken.id == maybeUserToken?.id {
                    $0.state = .on
                }
                $0.submenu = NSMenu() ※ {
                    $0.identifier = .init(userToken.id!)
                    addMenuItems(for: userToken, menu: $0)
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
            contentViewController = TimelineViewController(userToken: userToken, timelineType: .home)
        case "local":
            contentViewController = TimelineViewController(userToken: userToken, timelineType: .local)
        case "federated":
            contentViewController = TimelineViewController(userToken: userToken, timelineType: .federated)
        default:
            fatalError("Unknown Identifier: \(sender.identifier?.rawValue)")
        }
    }
}
