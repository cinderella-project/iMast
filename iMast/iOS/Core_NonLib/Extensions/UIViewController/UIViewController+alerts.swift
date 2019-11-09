//
//  UIViewController+alerts.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/10.
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

import UIKit
import Hydra
import Ikemen
import SwiftyJSON

extension UIViewController {
    func alertWithPromise(title: String = "", message: String = "") -> Promise<Void> {
        print("alert", title, message)
        return Promise<Void>(in: .main) { resolve, reject, _ in
            print("alert", title, message)
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                resolve(Void())
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func confirm(title: String = "", message: String = "", okButtonMessage: String = "OK", style: UIAlertAction.Style = .default, cancelButtonMessage: String = "キャンセル") -> Promise<Bool> {
        return Promise<Bool>(in: .main) { resolve, reject, _ in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: okButtonMessage, style: style, handler: { action in
                resolve(true)
            }))
            alert.addAction(UIAlertAction(title: cancelButtonMessage, style: .cancel, handler: { action in
                resolve(false)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func alert(title: String = "", message: String = "") {
        alertWithPromise(title: title, message: message).then {}
    }
    
    func errorWithPromise(errorMsg: String = "不明なエラー") -> Promise<Void> {
        let promise = alertWithPromise(
            title: "内部エラー",
            message: "あれ？何かがおかしいようです。\nこのメッセージは通常このアプリにバグがあるときに表示されます。\nもしよければ、下のエラーメッセージを開発者にお伝え下さい。\nエラーメッセージ: \(errorMsg)\n同じことをしようとしてもこのエラーが出る場合は、アプリを再起動してみてください。"
        ).then {}
        return promise
    }
    func error(errorMsg: String = "") {
        errorWithPromise(errorMsg: errorMsg).then {}
    }
    
    func apiErrorWithPromise(_ errorMsg: String? = nil, _ httpNumber: Int? = nil) -> Promise<Void> {
        let errorMessage: String = String(format: "エラーメッセージ:\n%@ (%@)\n\nエラーメッセージに従っても解決しない場合は、アプリを再起動してみてください。", arguments: [
            errorMsg ?? "不明なエラー(iMast)",
            String(httpNumber ?? -1),
        ])
        return alertWithPromise(
            title: "APIエラー",
            message: errorMessage
        )
    }
    func apiError(_ errorMsg: String? = nil, _ httpNumber: Int? = nil) {
        apiErrorWithPromise(errorMsg, httpNumber).then {}
    }
    func apiError(_ json: JSON) {
        apiError(json["error"].string, json["_response_code"].int)
    }
    
    func errorReport(error: Error) {
        let alert = UIAlertController(title: "エラー", message: "エラーが発生しました。\n\n\(error.localizedDescription)", preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "詳しい情報を見る", style: .default, handler: { _ in
            class ErrorReportViewController: UIViewController {
                let textView = UITextView() ※ { view in
                    view.font = UIFont.init(name: "Menlo", size: 15)
                    view.adjustsFontForContentSizeCategory = true
                    view.isEditable = false
                }
                
                override func loadView() {
                    view = textView
                }
                
                override func viewDidLoad() {
                    title = "エラー詳細"
                    navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(close))
                }
            }
            let vc = ErrorReportViewController()
            let navVC = UINavigationController(rootViewController: vc)
            vc.textView.text = "\(error)"
            self.present(navVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
