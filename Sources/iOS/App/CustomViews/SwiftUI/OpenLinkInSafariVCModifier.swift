//
//  OpenLinkInSafariVCModifier.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/09/25.
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

struct OpenLinkInSafariVCModifier: ViewModifier {
    private class ViewModel: ObservableObject {
        fileprivate weak var view: UIView?
        
        @MainActor func openInSafariVC(url: URL) -> Bool {
            guard let view else {
                return false
            }
            view.window?.rootViewController?.open(url: url)
            return true
        }

        fileprivate struct InternalView: UIViewRepresentable {
            typealias UIViewType = UIView
            let viewModel: ViewModel
            
            func makeUIView(context: Context) -> UIView {
                let view = UIView(frame: .zero)
                viewModel.view = view
                return view
            }
            
            func updateUIView(_ uiView: UIView, context: Context) {
            }
        }
    }
    
    @StateObject private var viewModel: ViewModel = .init()
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: { url in
                if viewModel.openInSafariVC(url: url) {
                    return .handled
                }
                return .systemAction
            }))
            .background(ViewModel.InternalView(viewModel: viewModel))
    }
}
