//
//  AppearancePreferencesPaneViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/19.
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

class AppearancePreferencesPaneViewController: NSViewController, PreferencesPaneProtocol {
    private lazy var v = AppearancePreferencesPaneView()
    
    override func loadView() {
        // todo
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        title = "表示"
    }
    
    func configureTabViewItem(item: NSTabViewItem) {
        item.label = "表示"
        item.image = NSImage(systemSymbolName: "eyeglasses", accessibilityDescription: nil)
    }
}
