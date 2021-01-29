//
//  AddMastodonAccountSheetViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/12/23.
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

class AddMastodonAccountSheetViewController: NSViewController {
    private lazy var v = AddMastodonAccountSheetView()
    @objc var serverDomain = "" {
        didSet {
            recalcCanLogin()
        }
    }
    @objc var forceLogin = false
    @objc dynamic var nowLoading = false {
        didSet {
            recalcCanLogin()
        }
    }
    @objc dynamic var canLogin = false
    
    override func loadView() {
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        v.cancelButton.target = self
        v.cancelButton.action = #selector(dismissSheet)
        v.nextButton.target = self
        v.nextButton.action = #selector(startLogin)
        v.nextButton.bind(.enabled, to: self, withKeyPath: "canLogin", options: nil)
        v.hostNameField.bind(.value, to: self, withKeyPath: "serverDomain", options: [.continuouslyUpdatesValue: true])
        v.hostNameField.bind(.enabled, to: self, withKeyPath: "nowLoading", options: [.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName])
        v.forceLoginCheckbox.bind(.value, to: self, withKeyPath: "forceLogin", options: nil)
        v.indicator.bind(.hidden, to: self, withKeyPath: "nowLoading", options: [.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName])
    }
    
    override func viewDidAppear() {
        view.window?.styleMask.remove(.resizable)
    }
    
    func recalcCanLogin() {
        canLogin = !nowLoading && serverDomain.count > 0
        print(canLogin)
    }
    
    @objc func dismissSheet() {
        dismiss(nil)
    }
    
    @objc func startLogin() {
        nowLoading = true
        MastodonInstance(hostName: serverDomain).createApp().then { app in
            let url = app.getAuthorizeUrl()
            NSWorkspace.shared.open(url)
        }.always(in: .main) { [weak self] in
            self?.nowLoading = false
        }
    }
}
