//
//  AddAccountLoginViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/24.
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
import Hydra
import Eureka
import EurekaFormBuilder
#if canImport(OnePasswordExtension)
import OnePasswordExtension
#endif
import iMastiOSCore

class AddAccountLoginViewController: FormViewController {

    var app: MastodonApp!
    var userToken: MastodonUserToken!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        #if canImport(OnePasswordExtension)
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            let onePassBundle = Bundle(for: OnePasswordExtension.self)
            let onePassResourceBundle = Bundle(path: onePassBundle.bundlePath + "/OnePasswordExtensionResources.bundle")
            let buttonImage = UIImage(named: "onepassword-button", in: onePassResourceBundle!, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            self.navigationItem.rightBarButtonItem = .init(
                image: buttonImage, style: .plain,
                target: self, action: #selector(callPasswordManager)
            )
        }
        #endif
        
        let mailAndPasswordSection = Section {
            TextRow("mail") { row in
                row.placeholder = "メールアドレス"
            }
            PasswordRow("password") { row in
                row.placeholder = "パスワード"
            }
        }
        form.append {
            mailAndPasswordSection
            Section {
                ButtonRow { row in
                    row.title = "ログイン"
                }.onCellSelection { [weak self] cell, row in
                    self?.loginButtonTapped()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButtonTapped() {
        let formValues = form.values()
        guard let mailAddress = formValues["mail"] as? String else {
            self.alert(title: "エラー", message: "メールアドレスを入力してください")
            return
        }
        
        guard let password = formValues["password"] as? String else {
            self.alert(title: "エラー", message: "パスワードを入力してください")
            return
        }
        
        async { status -> MastodonUserToken in
            let userToken = try await(self.app.authorizeWithPassword(email: mailAddress, password: password))
            let info = try await(userToken.getUserInfo())
            if info["error"].exists() {
                throw APIError.errorReturned(errorMessage: info["error"].stringValue, errorHttpCode: info["_response_code"].intValue)
            }
            userToken.save()
            userToken.use()
            return userToken
        }.then(in: Context.main, { userToken in
            let successVC = AddAccountSuccessViewController()
            successVC.userToken = userToken
            self.present(successVC, animated: true, completion: nil)
        })
    }
    
    #if canImport(OnePasswordExtension)
    @objc func callPasswordManager() {
        OnePasswordExtension.shared().findLogin(
            forURLString: "https://" + self.app!.instance.hostName,
            for: self, sender: self
        ) { (dict, error) in
            if let error = error {
                print(error)
                return
            }
            guard let dict = dict else { return }
            if let mailAddress = dict[AppExtensionUsernameKey] as? String {
                self.form.setValues(["mail": mailAddress])
            }
            if let password = dict[AppExtensionPasswordKey] as? String {
                self.form.setValues(["password": password])
            }
            self.form.allRows.forEach { $0.reload() }
        }
    }
    #endif
}
