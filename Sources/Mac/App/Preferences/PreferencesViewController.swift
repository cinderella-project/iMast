//
//  PreferencesViewController.swift
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

class PreferencesViewController: NSTabViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        tabStyle = .toolbar
        canPropagateSelectedChildViewControllerTitle = true
        
        let tabs: [NSViewController & PreferencesPaneProtocol] = [
            AccountsPreferencesPaneViewController(),
            AppearancePreferencesPaneViewController(),
        ]
        
        for tab in tabs {
            tab.view.snp.makeConstraints { make in
                make.width.equalTo(600)
            }
            addChild(tab)
            tab.configureTabViewItem(item: tabViewItem(for: tab)!)
        }
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if let tabViewItem = tabViewItem, let contentSize = tabViewItem.view?.fittingSize, let window = view.window {
            let frameSize = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize)).size
            let frame = NSRect(origin: window.frame.origin, size: frameSize).offsetBy(dx: 0, dy: window.frame.height - frameSize.height)
            
            NSAnimationContext.runAnimationGroup({ _ in
                view.isHidden = true
                window.animator().setFrame(frame, display: true)
            }, completionHandler: { [weak self] in
                self?.view.isHidden = false
                window.title = tabViewItem.label
            })
        }
        
        super.tabView(tabView, didSelect: tabViewItem)
    }
}
