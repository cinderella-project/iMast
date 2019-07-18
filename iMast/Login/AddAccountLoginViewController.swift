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
import OnePasswordExtension

class AddAccountLoginViewController: FormViewController {

    var app: MastodonApp!
    var userToken: MastodonUserToken!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            let onePassBundle = Bundle(for: OnePasswordExtension.self)
            let onePassResourceBundle = Bundle(path: onePassBundle.bundlePath + "/OnePasswordExtensionResources.bundle")
            let buttonImage = UIImage(named: "onepassword-button", in: onePassResourceBundle!, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            let button = UIBarButtonItem(image: buttonImage, style: .plain, closure: { item in
                self.callPasswordManager()
            })
            self.navigationItem.rightBarButtonItem = button
        }
        
        self.form +++ Section()
        <<< TextRow("mail") { row in
            row.placeholder = "メールアドレス"
        }
        <<< PasswordRow("password") { row in
            row.placeholder = "パスワード"
        }
        self.form +++ Section()
        <<< ButtonRow { row in
            row.title = "ログイン"
            row.onCellSelection { cell, row in
                self.loginButtonTapped()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func loginButtonTapped() {
        guard let mailAddress = (self.form.rowBy(tag: "mail") as? TextRow)?.value, mailAddress.count > 0 else {
            self.alert(title: "エラー", message: "メールアドレスを入力してください")
            return
        }
        
        guard let password = (self.form.rowBy(tag: "password") as? PasswordRow)?.value, password.count > 0 else {
            self.alert(title: "エラー", message: "パスワードを入力してください")
            return
        }
        
        let promise = async { status -> MastodonUserToken in
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
//        app!.authorizeWithPassword(email: mailAddressInput.text!, password: passwordInput.text!).then { userToken in
//            self.userToken = userToken
//            self.performSegue(withIdentifier: "backToProgress", sender: self)
//        }.catch { (error) -> Void in
//            print(error)
//            do {
//                throw error
//            } catch APIError.errorReturned (let e) {
//                self.apiError(e.errorMessage, e.errorHttpCode)
//            } catch APIError.unknownResponse (let e) {
//                self.apiError(nil, e)
//            } catch {
//                self.apiError(nil, nil)
//            }
//        }
    }
    
    func callPasswordManager() {
        OnePasswordExtension.shared().findLogin(forURLString: "https://" + self.app!.instance.hostName, for: self, sender: self) { (dict, error) in
            if let error = error {
                print(error)
                return
            }
            guard let dict = dict else { return }
            if let mailAddress = dict[AppExtensionUsernameKey] as? String {
                if let row = self.form.rowBy(tag: "mail") as? TextRow {
                    row.value = mailAddress
                    row.reload()
                }
            }
            if let password = dict[AppExtensionPasswordKey] as? String {
                if let row = self.form.rowBy(tag: "password") as? PasswordRow {
                    row.value = password
                    row.reload()
                }
            }
        }
    }
}
