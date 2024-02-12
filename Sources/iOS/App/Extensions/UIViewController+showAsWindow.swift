//
//  UIViewController+showAsWindow.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2024/02/12.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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
import iMastiOSCore

extension UIViewController {
    enum ShowAsWindowFallbackOption {
        case timeline
        case push
        case modal
    }
    
    func showAsWindow(userActivity: NSUserActivity, fallback: ShowAsWindowFallbackOption) {
        if Defaults.openAsAnotherWindow {
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: UIWindowScene.ActivationRequestOptions() ※ {
                $0.requestingScene = view.window?.windowScene
                $0.preferredPresentationStyle = .prominent
            }) { [weak self] error in
                self?.showAsWindowFallback(userActivity: userActivity, fallback: fallback)
            }
            return
        }
        showAsWindowFallback(userActivity: userActivity, fallback: fallback)
    }
    
    fileprivate func showAsWindowFallback(userActivity: NSUserActivity, fallback: ShowAsWindowFallbackOption) {
        guard let vc = UIViewController.viewController(from: userActivity) else {
            return
        }
        switch fallback {
        case .timeline:
            showFromTimeline(vc)
        case .push:
            navigationController?.pushViewController(vc, animated: true)
        case .modal:
            present(ModalNavigationViewController(rootViewController: vc), animated: true)
        }
    }
    
    static func viewController(from userActivity: NSUserActivity) -> UIViewController? {
        switch userActivity.activityType {
        case NSUserActivity.activityTypeNewPost:
            let vc = NewPostViewController(userActivity: userActivity)
            return vc
        default:
            #if DEBUG
            fatalError("Unknown NSUserActivity: \(userActivity.activityType)")
            #endif
            return nil
        }
    }
}
