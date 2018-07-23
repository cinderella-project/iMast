//
//  LoginSafari.swift
//  iMast
//
//  Created by user on 2018/07/23.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

protocol LoginSafari {
    func open(url: URL, viewController: UIViewController)
}

class LoginSafariNormal: LoginSafari {
    func open(url: URL, viewController: UIViewController) {
        let safariVC = SFSafariViewController(url: url)
        viewController.present(safariVC, animated: true, completion: nil)
    }
}

@available(iOS 11.0, *)
class LoginSafari11: LoginSafari {
    var authSession: SFAuthenticationSession?
    func open(url: URL, viewController _: UIViewController) {
        self.authSession = SFAuthenticationSession(url: url, callbackURLScheme: nil, completionHandler: {callbackUrl, error in
            guard let callbackUrl = callbackUrl else {
                return
            }
            print(callbackUrl)
            UIApplication.shared.openURL(callbackUrl)
        })
        self.authSession?.start()
    }
}

func getLoginSafari() -> LoginSafari {
    if #available(iOS 11.0, *) {
        return LoginSafari11()
    } else {
        return LoginSafariNormal()
    }
}
