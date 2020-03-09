//
//  FeedbackViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/10/10.
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
import Alamofire

class FeedbackViewController: FormViewController {
    
    let versionString = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)+"(\((Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)))"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let footerText = "GitHub アカウントをお持ちの場合、公開できる内容のバグ報告は GitHub 上でしてくれるとうれしいです\nhttps://github.com/cinderella-project/iMast"
        self.form.append {
            Section(footer: footerText) {
                TextAreaRow("body") { row in
                    row.placeholder = "Feedbackの内容をお書きください"
                    row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                }
            }
            Section(header: "Feedbackを送信すると、以下の情報も一緒に送信され、iMastの改善に役立てられます。") {
                LabelRow {
                    $0.title = "iMastのバージョン"
                    $0.value = versionString
                }
                LabelRow {
                    $0.title = "iOSのバージョン"
                    $0.value = UIDevice.current.systemVersion
                }
                LabelRow {
                    $0.title = "端末名"
                    $0.value = UIDevice.current.platform
                }
            }
            Section {
                ButtonRow {
                    $0.title = "送信"
                    $0.onCellSelection { [weak self] cell, row in
                        self?.sendFeedback()
                    }
                }
            }
        }
        title = "Feedback"
    }
    
    func sendFeedback() {
        let values = form.values()
        guard let body = values["body"] as? String, body.count > 0 else {
            alert(title: "エラー", message: "Feedbackの内容を入力してください")
            return
        }
        let postBody = [
            "body": body,
            "app_version": versionString,
            "ios_version": UIDevice.current.systemVersion,
            "device_name": UIDevice.current.platform,
        ]
        Alamofire.request("https://imast-backend.rinsuki.net/old-api/feedback", method: .post, parameters: postBody).responseJSON { request in
            if (request.response?.statusCode ?? 0) >= 400 {
                self.alert(title: "通信エラー", message: "通信に失敗しました。(HTTP-\((request.response?.statusCode ?? 599)))\nしばらく待ってから、もう一度送信してみてください。\nFeedbackは@imast_ios@mstdn.rinsuki.netへのリプライでも受け付けています。")
            }
            if request.error != nil {
                self.alert(title: "通信エラー", message: "通信に失敗しました。\nしばらく待ってから、もう一度送信してみてください。\nFeedbackは@imast_ios@mstdn.rinsuki.netへのリプライでも受け付けています。")
                return
            }
            self.navigationController?.popViewController(animated: true)
            self.alert(title: "送信しました!", message: "Feedbackありがとうございました。")
        }
    }
}
