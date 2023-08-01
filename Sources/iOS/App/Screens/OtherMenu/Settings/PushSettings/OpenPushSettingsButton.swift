//
//  OpenPushSettingsButton.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/06/15.
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

import SwiftUI
import iMastiOSCore

// TODO: PLEASE STOP THESE STUPID WORKAROUND ASAP
struct OpenPushSettingsButton: View {
    private struct VCExposer: UIViewControllerRepresentable {
        var callback: (UIViewController) -> Void
        
        func makeUIViewController(context: Context) -> some UIViewController {
            let vc = UIViewController()
            vc.view = .init(frame: .zero)
            return vc
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            callback(uiViewController)
        }
    }
    
    @State var viewController: UIViewController? = nil

    var body: some View {
        Button(L10n.Preferences.Push.title) {
            if let viewController {
                Task {
                    await PushSettingsTableViewController.openRequest(vc: viewController.view.superview?.viewController ?? viewController)
                }
            }
        }
        .overlay {
            VCExposer {
                viewController = $0
            }
            .opacity(0)
        }
    }
}
