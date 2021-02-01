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
import iMastMacCore

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: appGroupIdentifier)!
}

extension NSUserDefaultsController {
    static let appGroup = NSUserDefaultsController(defaults: .appGroup, initialValues: nil)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var preferencesWindowController = PreferencesWindowController()
    @objc dynamic var hidePrivatePosts = false {
        didSet {
            UserDefaults.appGroup.setValue(hidePrivatePosts, forKey: "hide_private_posts")
            hidePrivatePostsMenuItem.state = hidePrivatePosts ? .on : .off
        }
    }
    @IBOutlet var hidePrivatePostsMenuItem: NSMenuItem!
    
    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindowController.showWindow(sender)
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
