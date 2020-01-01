//
//  AddAccountSelectLoginMethodViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/23.
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
import SafariServices
import Eureka
import iMastiOSCore

class AddAccountSelectLoginMethodViewController: FormViewController {
    
    var app: MastodonApp!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "認証"
        
        let authMethodSection = Section {
            ButtonRow { row in
                row.title = "Safariでログインする (推奨)"
                row.cellUpdate { cell, row in
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = .disclosureIndicator
                    cell.textLabel?.textColor = nil
                }
                row.onCellSelection { [weak self] cell, row in
                    self?.safariLoginButton()
                }
            }
            ButtonRow { row in
                row.title = "メールアドレスとパスワードでログインする"
                row.presentationMode = .show(controllerProvider: .callback(builder: {
                    let vc = AddAccountLoginViewController()
                    vc.title = row.title
                    vc.app = self.app
                    return vc
                }), onDismiss: nil)
            }
        }
        
        let tosSection = Section(header: "ログインすると、このインスタンスの以下の規約に同意したことになります。") {
            OpenSafariRow(title: "利用規約", url: URL(string: "https://\(app.instance.hostName)/about/more")!)
            OpenSafariRow(title: "プライバシーポリシー", url: URL(string: "https://\(app.instance.hostName)/terms")!)
        }
        
        form.append {
            authMethodSection
            tosSection
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var loginSafari: LoginSafari?
    
    func safariLoginButton() {
        let url = URL(string: self.app!.getAuthorizeUrl())!
        loginSafari = getLoginSafari()
        loginSafari?.open(url: url, viewController: self)
    }
}
