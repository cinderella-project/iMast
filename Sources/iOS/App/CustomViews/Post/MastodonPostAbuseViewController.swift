//
//  MastodonPostAbuseViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/08/04.
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
import SwiftyJSON
import Eureka
import Mew
import iMastiOSCore

class MastodonPostAbuseViewController: FormViewController, Instantiatable {
    typealias Input = MastodonPost
    typealias Environment = MastodonUserToken
    
    private let input: Input
    internal let environment: Environment
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var placeholder = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "通報"
        
        self.form.append {
            Section {
                TextAreaRow("text") {
                    $0.placeholder = self.placeholder
                    $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                }
            }
        }
        
        if let remoteInstance = input.account.acct.split(separator: "@").safe(1) {
            let message = "このチェックボックスをONにすると、この通報内容は\(remoteInstance)にも転送されます。あなたのアカウントがあるインスタンスと\(remoteInstance)が共にMastodon 2.3以上であるか、通報の連合経由での転送に対応している必要があります。"
            self.form.append {
                Section(
                    footer: message
                ) {
                    SwitchRow("forward") { row in
                        row.title = "リモートインスタンスに転送"
                    }
                }
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "送信", style: .done, target: self, action: #selector(submitButtonTapped))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func submitButtonTapped() {
        let values = form.values()
        environment.reports(
            account: self.input.account,
            comment: (values["text"] as? String) ?? "",
            forward: (values["forward"] as? Bool) ?? false,
            posts: [input]
        ).then { (res) in
            self.alertWithPromise(title: "送信完了", message: "通報が完了しました！").then {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
