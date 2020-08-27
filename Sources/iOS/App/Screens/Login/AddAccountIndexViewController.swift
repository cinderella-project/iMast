//
//  AddAccountIndexViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/22.
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
//

import UIKit
import Eureka
import Hydra
import iMastiOSCore

class AddAccountIndexViewController: FormViewController {
    
    var latestToken: MastodonUserToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = L10n.Login.title
        if latestToken == nil {
            latestToken = MastodonUserToken.getLatestUsed()
        }
        if latestToken != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self, action: #selector(onCancelTapped)
            )
        }
        self.form.append {
            Section(header: L10n.Login.pleaseInputMastodonInstance) {
                TextRow("instance") { row in
                    row.placeholder = "mastodon.example"
                    row.cellUpdate { cell, row in
                        cell.textField.autocorrectionType = .no
                        cell.textField.autocapitalizationType = .none
                        cell.textField.keyboardType = UIKeyboardType.URL
                    }
                }
            }
            Section {
                ButtonRow { row in
                    row.title = L10n.Login.loginButton
                    row.disabled = "$instance == nil"
                    row.cellSetup { cell, _ in
                        cell.accessibilityIdentifier = "loginButton"
                    }
                    row.onCellSelection { [weak self] cell, row in
                        self?.onLoginTapped()
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func onLoginTapped() {
        let values = form.values()
        guard let hostName = values["instance"] as? String else {
            return
        }
        let alert = UIAlertController(title: L10n.Login.ProgressDialog.title, message: "...", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let promise = async { status -> MastodonApp in
            DispatchQueue.mainSafeSync {
                alert.message = "\(L10n.Login.ProgressDialog.fetchingServerInfo) (1/4)"
            }
            let instance = MastodonInstance(hostName: hostName)
            _ = try await(instance.getInfo())
            DispatchQueue.mainSafeSync {
                alert.message = "\(L10n.Login.ProgressDialog.registeringApplication) (2/4)"
            }
            let appName = Defaults[.newAccountVia]
            let app = try await(instance.createApp(name: appName))
            app.save()
            DispatchQueue.mainSafeSync {
                alert.message = "\(L10n.Login.ProgressDialog.pleaseAuthorize) (3/4)"
            }
            return app
        }
        promise.then { app in
            alert.dismiss(animated: true, completion: {
                let vc = AddAccountSelectLoginMethodViewController()
                vc.app = app
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }.catch { (error) in
            alert.dismiss(animated: true, completion: {
                self.errorReport(error: error)
            })
        }
    }
    
    @objc func onCancelTapped() {
        guard let latestToken = latestToken else {
            return
        }
        changeRootVC(MainTabBarController.instantiate((), environment: latestToken))
    }
}
