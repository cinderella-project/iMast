//
//  OtherMenuHelpAndFeedbackTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/10/05.
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
//

import UIKit
import SafariServices
import Alamofire
import SwiftUI


struct OtherMenuHelpAndFeedbackView: View {
    
    struct AutoRepresentable<VC: UIViewController>: UIViewControllerRepresentable {
        typealias UIViewControllerType = VC

        func makeUIViewController(context: UIViewControllerRepresentableContext<OtherMenuHelpAndFeedbackView.AutoRepresentable<VC>>) -> VC {
            return VC()
        }
        
        func updateUIViewController(_ uiViewController: VC, context: UIViewControllerRepresentableContext<OtherMenuHelpAndFeedbackView.AutoRepresentable<VC>>) {
        }
    }
    
    var body: some View {
        return List {
            OpenSafariCellView(url: URL(string: "https://cinderella-project.github.io/iMast/help/")!, text: Text("ヘルプ"))

            NavigationLink(destination: AutoRepresentable<FeedbackViewController>().navigationBarTitle(Text("Feedback"))) {
                Text("Feedback")
            }

            OpenSafariCellView(url: URL(string: "https://github.com/cinderella-project/iMast/issues")!, text: Text("GitHub Issues"))
        }.navigationBarTitle(Text(R.string.localizable.helpAndFeedback()), displayMode: .inline)
    }
}
