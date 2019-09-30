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

class AddAccountIndexViewController: FormViewController {
    
    var latestToken: MastodonUserToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = R.string.localizable.login()
        if latestToken == nil {
            latestToken = MastodonUserToken.getLatestUsed()
        }
        if latestToken != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self, action: #selector(onCancelTapped)
            )
        }
        self.form +++ Section(R.string.localizable.pleaseInputMastodonInstance())
        <<< TextRow("instance") { row in
            row.placeholder = "mastodon.example"
        }.cellUpdate { cell, row in
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.textField.keyboardType = UIKeyboardType.URL
        }
        self.form +++ ButtonRow { row in
            row.title = "ログイン"
            row.disabled = "$instance == nil"
            row.onCellSelection { cell, row in
                guard let instanceRow = self.form.rowBy(tag: "instance") as? TextRow else {
                    return
                }
                guard let hostName = instanceRow.value else {
                    return
                }
                let alert = UIAlertController(title: "ログイン中...", message: "ログインしています", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                let promise = async { status -> MastodonApp in
                    DispatchQueue.mainSafeSync {
                        alert.message = "ログインしています\nインスタンス情報を取得中... (1/4)"
                    }
                    let instance = MastodonInstance(hostName: hostName)
                    let _ = try await(instance.getInfo())
                    DispatchQueue.mainSafeSync {
                        alert.message = "ログインしています\nアプリ情報を登録中... (2/4)"
                    }
                    let appName = Defaults[.newAccountVia]
                    let app = try await(instance.createApp(name: appName))
                    app.save()
                    DispatchQueue.mainSafeSync {
                        alert.message = "ログインしています\n認証してください (3/4)"
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
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func onCancelTapped() {
        guard let latestToken = latestToken else {
            return
        }
        changeRootVC(MainTabBarController.instantiate((), environment: latestToken), animated: true)
    }
}
