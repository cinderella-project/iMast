//
//  ModalLoadingIndicatorViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/08/26.
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
import SwiftUI

struct ModalLoadingIndicatorView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ModalLoadingIndicatorViewController
    
    func makeUIViewController(context: Context) -> ModalLoadingIndicatorViewController {
        return .init()
    }
    
    func updateUIViewController(_ uiViewController: ModalLoadingIndicatorViewController, context: Context) {
    }
}

class ModalLoadingIndicatorViewController: UIViewController {
    
    let indicator = UIActivityIndicatorView(style: .large)
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        indicator.startAnimating()
        
        visualEffectView.contentView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview().inset(1)
            make.size.equalToSuperview().inset(12)
        }
        visualEffectView.layer.cornerRadius = 12
        visualEffectView.clipsToBounds = true
        
        self.view.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.backgroundColor = UIColor { traitCollection -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.black.withAlphaComponent(0.4)
            case .unspecified, .light:
                return UIColor.black.withAlphaComponent(0.1)
            @unknown default:
                return UIColor.black.withAlphaComponent(0.1)
            }
        }
    }
}
