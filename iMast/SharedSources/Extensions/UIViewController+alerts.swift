//
//  UIViewController+alerts.swift
//  iMast
//
//  Created by user on 2018/07/21.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit


extension UIViewController {
    func alertWithPromise(title: String = "", message: String = "") -> Promise<Void> {
        print("alert", title, message)
        return Promise<Void> { resolver in
            print("alert", title, message)
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                resolver.resolve((), nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func confirm(title: String = "", message: String = "", okButtonMessage:String = "OK", style:UIAlertActionStyle = .default, cancelButtonMessage:String = "キャンセル") -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: okButtonMessage, style: style, handler: { action in
                resolver.resolve(true, nil)
            }))
            alert.addAction(UIAlertAction(title: cancelButtonMessage, style: .cancel, handler: { action in
                resolver.resolve(false, nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func errorWithPromise(errorMsg: String = "不明なエラー") -> Promise<Void>{
        return alertWithPromise(
            title: "内部エラー",
            message: "あれ？何かがおかしいようです。\nこのメッセージは通常このアプリにバグがあるときに表示されます。\nもしよければ、下のエラーメッセージを開発者にお伝え下さい。\nエラーメッセージ: \(errorMsg)\n同じことをしようとしてもこのエラーが出る場合は、アプリを再起動してみてください。"
            ).map { $0 }
    }
    
    func apiErrorWithPromise(_ errorMsg: String? = nil, _ httpNumber: Int? = nil) -> Promise<Void>{
        let errorMessage:String = String(format: "エラーメッセージ:\n%@ (%@)\n\nエラーメッセージに従っても解決しない場合は、アプリを再起動してみてください。", arguments:[
            errorMsg ?? "不明なエラー(iMast)",
            String(httpNumber ?? -1)
            ])
        return alertWithPromise(
            title: "APIエラー",
            message: errorMessage
        )
    }
}
