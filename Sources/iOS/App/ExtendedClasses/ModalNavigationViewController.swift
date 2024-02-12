//
//  ModalNavigationViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/09/29.
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

class ModalNavigationViewController: UINavigationController {
    var asSceneRoot: Bool

    init(rootViewController: UIViewController, asSceneRoot: Bool = false) {
        self.asSceneRoot = asSceneRoot
        super.init(rootViewController: rootViewController)
        if #available(iOS 17.0, *), traitCollection.userInterfaceIdiom == .vision, asSceneRoot {
        } else {
            rootViewController.navigationItem.leftBarButtonItem = .init(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(closeAsDecline)
            )
        }
    }
    
    @objc func closeAsDecline() {
        if asSceneRoot {
            guard let windowScene = view.window?.windowScene else {
                return
            }
            UIApplication.shared.requestSceneSessionDestruction(windowScene.session, options: UIWindowSceneDestructionRequestOptions() ※ {
                $0.windowDismissalAnimation = .decline
            })
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func closeAsCommit() {
        if asSceneRoot {
            guard let windowScene = view.window?.windowScene else {
                return
            }
            UIApplication.shared.requestSceneSessionDestruction(windowScene.session, options: UIWindowSceneDestructionRequestOptions() ※ {
                $0.windowDismissalAnimation = .commit
            })
        } else {
            dismiss(animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
