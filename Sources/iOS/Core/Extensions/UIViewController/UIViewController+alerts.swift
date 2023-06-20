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
import Ikemen

extension UIViewController {
    @MainActor
    public func alertAsync(title: String = "", message: String = "") async {
        print("alert", title, message)
        await withCheckedContinuation { continuation in
            self.alert(title: title, message: message) {
                continuation.resume()
            }
        } as Void
    }
    
    @MainActor
    public func alert(title: String = "", message: String = "", completionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            completionHandler?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @MainActor
    public func confirm(
        title: String = "", message: String = "",
        okButtonMessage: String = "OK", style: UIAlertAction.Style = .default,
        cancelButtonMessage: String = CoreL10n.cancel,
        completionHandler: ((Bool) -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: okButtonMessage, style: style, handler: { action in
            completionHandler?(true)
        }))
        alert.addAction(UIAlertAction(title: cancelButtonMessage, style: .cancel, handler: { action in
            completionHandler?(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @MainActor
    public func confirmAsync(
        title: String = "", message: String = "",
        okButtonMessage: String = "OK", style: UIAlertAction.Style = .default,
        cancelButtonMessage: String = CoreL10n.cancel
    ) async -> Bool {
        await withCheckedContinuation { continuation in
            self.confirm(
                title: title, message: message, okButtonMessage: okButtonMessage, style: style, cancelButtonMessage: cancelButtonMessage
            ) {
                continuation.resume(returning: $0)
            }
        }
    }
    
    @MainActor
    public func apiError(_ errorMsg: String? = nil, _ httpNumber: Int? = nil, completionHandler: (() -> Void)? = nil) {
        let msg = errorMsg ?? "不明なエラー(iMast)"
        let errorMessage = "エラーメッセージ:\n\(msg) (\(httpNumber ?? -1)\n\nエラーメッセージに従っても解決しない場合は、アプリを再起動してみてください。"
        alert(title: "APIエラー", message: errorMessage, completionHandler: completionHandler)
    }
    
    @MainActor
    public func apiErrorAsync(_ errorMsg: String? = nil, _ httpNumber: Int? = nil) async {
        await withCheckedContinuation { continuation in
            apiError(errorMsg, httpNumber) {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    public func errorReport(error: Error, completionHandler: (() -> Void)? = nil) {
        if case APIError.errorReturned(errorMessage: let message, errorHttpCode: let code) = error {
            return alert(title: CoreL10n.Error.Api.title, message: CoreL10n.Error.Api.text(message, code), completionHandler: completionHandler)
        }
        if case APIError.unknownResponse(errorHttpCode: let code, errorString: let message) = error {
            return alert(
                title: CoreL10n.Error.Http.title,
                message: CoreL10n.Error.Http.text(code, message ?? CoreL10n.Error.failedToDecodeAsUTF8),
                completionHandler: completionHandler
            )
        }
        let alert = UIAlertController(
            title: CoreL10n.ErrorAlert.title,
            message: CoreL10n.ErrorAlert.message(error.localizedDescription),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: CoreL10n.ErrorAlert.moreInfo,
            style: .default
        ) { _ in
            class ErrorReportViewController: UIViewController {
                var completionHandler: (() -> Void)? = nil
                
                let textView = UITextView() ※ { view in
                    view.font = UIFont.init(name: "Menlo", size: 15)
                    view.adjustsFontForContentSizeCategory = true
                    view.isEditable = false
                }
                
                override func loadView() {
                    view = textView
                }
                
                override func viewDidLoad() {
                    title = CoreL10n.ErrorMoreInfo.title
                    navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(close))
                }
                
                override func viewDidDisappear(_ animated: Bool) {
                    super.viewDidDisappear(animated)
                    completionHandler?()
                }
            }
            let vc = ErrorReportViewController()
            let navVC = UINavigationController(rootViewController: vc)
            vc.textView.text = "\(error)"
            vc.completionHandler = completionHandler
            self.present(navVC, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            completionHandler?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
