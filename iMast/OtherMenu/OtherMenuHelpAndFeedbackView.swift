//
//  OtherMenuHelpAndFeedbackTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/10/05.
//  Copyright © 2017年 rinsuki. All rights reserved.
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
