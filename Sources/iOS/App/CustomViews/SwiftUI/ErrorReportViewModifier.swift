//
//  ErrorReportViewModifier.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/09/28.
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

class ErrorReporter: ObservableObject {
    weak var view: UIView?
    
    @MainActor func report(_ error: Error) {
        view?.viewController?.errorReport(error: error)
    }
    
    fileprivate struct InnerView: UIViewRepresentable {
        @ObservedObject var viewModel: ErrorReporter
        typealias UIViewType = UIView
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView(frame: .zero)
            viewModel.view = view
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
        }
    }
}

extension View {
    func attach(errorReporter: ErrorReporter) -> some View {
        self.background { ErrorReporter.InnerView(viewModel: errorReporter) }
    }
}
