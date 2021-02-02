//
//  AppDelegate.swift
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
import iMastMacCore

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: appGroupIdentifier)!
}

extension NSUserDefaultsController {
    static let appGroup = NSUserDefaultsController(defaults: .appGroup, initialValues: nil)
}

class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var preferencesWindowController = PreferencesWindowController()
    @objc dynamic var hidePrivatePosts = false {
        didSet {
            UserDefaults.appGroup.setValue(hidePrivatePosts, forKey: "hide_private_posts")
            hidePrivatePostsMenuItem?.state = hidePrivatePosts ? .on : .off
        }
    }
    var hidePrivatePostsMenuItem: NSMenuItem?
    
    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindowController.showWindow(sender)
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let menu = NSMenu(title: "")
        let appName = "iMast"
        menu.addItem(.init() ※ {
            $0.submenu = NSMenu() ※ {
                $0.addItem(.init(title: L10n.Menu.about(appName), action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.preferences, action: #selector(openPreferences(_:)), keyEquivalent: ","))
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.services, action: nil, keyEquivalent: "") ※ {
                    let menu = NSMenu()
                    $0.submenu = menu
                    NSApplication.shared.servicesMenu = menu
                })
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.hide(appName), action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"))
                $0.addItem(.init(title: L10n.Menu.hideOthers, action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h") ※ {
                    $0.keyEquivalentModifierMask = [.command, .option]
                })
                $0.addItem(.init(title: L10n.Menu.showAll, action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""))
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.quit(appName), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            }
        })
        menu.addItem(.init() ※ {
            $0.submenu = NSMenu(title: L10n.Menu.file) ※ {
                $0.addItem(.init(title: L10n.Menu.new, action: #selector(TimelineViewController.newDocument(_:)), keyEquivalent: "n") ※ {
                    $0.keyEquivalentModifierMask = []
                })
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.close, action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
            }
        })
        menu.addItem(.init() ※ {
            $0.submenu = NSMenu(title: NSLocalizedString(L10n.Menu.edit, comment: "")) ※ {
                $0.addItem(.init(title: "Undo", action: Selector("undo:"), keyEquivalent: "z"))
                $0.addItem(.init(title: "Redo", action: Selector("redo:"), keyEquivalent: "Z"))
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.cut, action: Selector("cut:"), keyEquivalent: "x"))
                $0.addItem(.init(title: L10n.Menu.copy, action: Selector("copy:"), keyEquivalent: "c"))
                $0.addItem(.init(title: L10n.Menu.paste, action: Selector("paste:"), keyEquivalent: "v"))
                $0.addItem(.init(title: L10n.Menu.delete, action: Selector("delete:"), keyEquivalent: ""))
                $0.addItem(.init(title: L10n.Menu.selectAll, action: Selector("selectAll:"), keyEquivalent: "a"))
            }
        })
        menu.addItem(.init() ※ {
            $0.submenu = NSMenu(title: L10n.Menu.view) ※ {
                $0.addItem(.init(title: L10n.Menu.showToolbar, action: #selector(NSWindow.toggleToolbarShown(_:)), keyEquivalent: "t") ※ {
                    $0.keyEquivalentModifierMask = [.command, .option]
                })
                $0.addItem(.init(title: L10n.Menu.customizeToolbar, action: #selector(NSWindow.runToolbarCustomizationPalette(_:)), keyEquivalent: ""))
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.showSidebar, action: "toggleSidebar:", keyEquivalent: "s") ※ {
                    $0.keyEquivalentModifierMask = [.command, .control]
                })
                $0.addItem(.init(title: "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f") ※ {
                    $0.keyEquivalentModifierMask = [.command, .control]
                })
            }
        })
        menu.addItem(.init() ※ {
            $0.submenu = NSMenu(title: L10n.Menu.post) ※ {
                $0.addItem(.init(title: L10n.Menu.sendPost, action: #selector(NewPostViewController.sendPost(_:)), keyEquivalent: "\r"))
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.hidePrivatePosts, action: #selector(toggleHidePrivatePosts(_:)), keyEquivalent: "") ※ {
                    hidePrivatePostsMenuItem = $0
                })
            }
        })
        menu.addItem(.init() ※ {
            $0.submenu = NSMenu(title: L10n.Menu.window) ※ {
                $0.addItem(.init(title: L10n.Menu.minimize, action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m"))
                $0.addItem(.init(title: L10n.Menu.zoom, action: #selector(NSWindow.performZoom(_:)), keyEquivalent: ""))
                $0.addItem(.separator())
                $0.addItem(.init(title: L10n.Menu.bringAllToFront, action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: ""))
                NSApplication.shared.windowsMenu = $0
            }
        })
        menu.addItem(.init() ※ {
            $0.submenu = NSMenu(title: L10n.Menu.help) ※ {
                $0.addItem(.init(title: L10n.Menu.help(appName), action: #selector(NSApplication.showHelp(_:)), keyEquivalent: "?"))
                NSApplication.shared.helpMenu = $0
            }
        })
        NSApplication.shared.mainMenu = menu
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0)
        initDatabase()
        if MastodonUserToken.getAllUserTokens().count < 1 {
            openPreferences(self)
        }
        
        let windowController = MainWindowController()
        windowController.showWindow(nil)
        hidePrivatePosts = UserDefaults.appGroup.bool(forKey: "hide_private_posts")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func toggleHidePrivatePosts(_ sender: NSMenuItem) {
        print(hidePrivatePosts)
        hidePrivatePosts = !hidePrivatePosts
    }
}
