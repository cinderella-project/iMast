//
//  LoginSafari.swift
//  iMast
//
//  Created by rinsuki on 2018/07/23.
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

import Foundation
import UIKit
import AuthenticationServices

protocol LoginSafari {
    func open(url: URL, viewController: UIViewController, prefersEphemeralWebBrowserSession: Bool)
}

extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return .init(windowScene: view.window!.windowScene!)
    }
}

class LoginSafari12: LoginSafari {
    var authSession: ASWebAuthenticationSession?

    func open(url: URL, viewController: UIViewController, prefersEphemeralWebBrowserSession: Bool) {
        authSession = .init(url: url, callbackURLScheme: nil, completionHandler: { url, error in
            guard let url = url else {
                return
            }
            DispatchQueue.main.async {
                viewController.view.window?.windowScene?.open(url, options: nil, completionHandler: nil)
            }
        })
        authSession?.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        authSession?.presentationContextProvider = viewController
        authSession?.start()
    }
}

@MainActor
func getLoginSafari() -> LoginSafari {
    return LoginSafari12()
}
