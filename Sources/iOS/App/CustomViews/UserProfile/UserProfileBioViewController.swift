//
//  UserProfileBioViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/06/25.
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

import UIKit
import iMastiOSCore
import Ikemen
import Mew

class UserProfileBioViewController: UIViewController, Instantiatable, Injectable, UITextViewDelegate {
    typealias Input = MastodonAccount
    typealias Environment = MastodonUserToken

    internal let environment: Environment
    private var input: Input
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    let profileTextView = UITextView() ※ { v in
        v.isScrollEnabled = false
        v.isEditable = false
        v.isSelectable = true
        v.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(profileTextView)
        profileTextView.snp.makeConstraints { make in
            make.center.size.equalTo(view.readableContentGuide)
        }
        profileTextView.delegate = self
        self.input(input)
    }
    
    func input(_ input: Input) {
        self.input = input
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        if let attrStr = input.bio.parseText2HTML(attributes: [
            .paragraphStyle: paragraph,
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: UIColor.label,
        ]) {
            self.profileTextView.attributedText = attrStr
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            let string = (textView.attributedText.string as NSString).substring(with: characterRange)
            if string.hasPrefix("@") {
                resolveUserProfile(userToken: environment, url: url)
                return false
            }
            open(url: url)
            return false
        case .preview:
            return false
        case .presentActions:
            return true
        }
    }
}
