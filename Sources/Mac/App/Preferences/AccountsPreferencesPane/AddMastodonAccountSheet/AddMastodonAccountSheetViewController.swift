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
            if showCodeField { // codeが出るフェーズに行った後にホストを変えたらフェーズを戻す
                app = nil
            }
        }
    }
    @objc dynamic var nowLoading = false {
        didSet {
            recalcCanLogin()
        }
    }
    @objc dynamic var canLogin = false
    @objc dynamic var code = "" {
        didSet {
            recalcCanLogin()
        }
    }
    @objc dynamic var showCodeField = false {
        didSet {
            // app != nil と showCodeField が連動してなかったらバグ
            if showCodeField != (app != nil) {
                fatalError("unexpected state (showCodeField=true, app=nil)")
            }
            // code のフィールドを非表示にされたらcodeを消す
            if showCodeField == false {
                code = ""
            }
        }
    }
    @objc dynamic var error: Error? = nil
    var app: MastodonApp? {
        didSet {
            showCodeField = app != nil
        }
    }
    
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
        v.indicator.bind(.hidden, to: self, withKeyPath: "nowLoading", options: [.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName])
        v.codeLabel.bind(.hidden, to: self, withKeyPath: "showCodeField", options: [.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName])
        v.codeField.bind(.value, to: self, withKeyPath: "code", options: [.continuouslyUpdatesValue: true])
        v.codeField.bind(.hidden, to: self, withKeyPath: "showCodeField", options: [.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName])
        v.codeField.bind(.enabled, to: self, withKeyPath: "nowLoading", options: [.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName])
        v.errorTextLabel.bind(.value, to: self, withKeyPath: "error.localizedDescription", options: nil)
        v.errorTextLabel.bind(.hidden, to: self, withKeyPath: "error", options: [.valueTransformerName: NSValueTransformerName.isNilTransformerName])
    }
    
    override func viewDidAppear() {
        view.window?.styleMask.remove(.resizable)
    }
    
    func recalcCanLogin() {
        // ロード中でない かつ サーバードメインが入力されている かつ (コード入力フェーズでない もしくは コードを入力済み)
        canLogin = !nowLoading && serverDomain.count > 0 && (showCodeField == false || code.count > 0)
        print(canLogin)
    }
    
    @objc func dismissSheet() {
        dismiss(nil)
    }
    
    @objc func startLogin() {
        nowLoading = true
        error = nil
        if let app = app {
            asyncPromise { [code] in
                let token = try await app.authorizeWithCode(code: code)
                try await token.getUserInfo()
                try token.save()
                NotificationCenter.default.post(name: .userTokenChanged, object: nil)
            }.then(in: .main) { [weak self] in
                self?.dismissSheet()
            }.always(in: .main) { [weak self] in
                self?.nowLoading = false
            }.catch { [weak self] error in
                self?.error = error
            }
        } else {
            Task { [weak self] in
                do {
                    let app = try await MastodonInstance(hostName: serverDomain).createApp(redirect_uri: "urn:ietf:wg:oauth:2.0:oob")
                    try app.save()
                    NSWorkspace.shared.open(app.getAuthorizeUrl())
                    self?.app = app
                    self?.nowLoading = false
                } catch {
                    self?.error = error
                    self?.nowLoading = false
                }
            }
        }
    }
}
