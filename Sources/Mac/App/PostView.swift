//
//  PostView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/01.
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

import Cocoa
import Ikemen
import iMastMacCore

class PostView: NSView {
    let imageView = NSImageView()
    let textField = NSTextField(wrappingLabelWithString: "") ※ {
        $0.allowsEditingTextAttributes = true
        $0.isSelectable = true
        $0.becomeFirstResponder()
    }
    
    init(post: MastodonPost) {
        super.init(frame: .zero)
        imageView.sd_setImage(with: URL(string: post.originalPost.account.avatarUrl), completed: nil)
        if let attributedString = post.originalPost.status.parseText2HTML(attributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)]) {
            textField.attributedStringValue = attributedString
        } else {
            textField.stringValue = post.originalPost.status
        }
        addSubview(imageView)
        addSubview(textField)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
            make.leading.equalToSuperview().inset(4)
            make.size.equalTo(48)
        }
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
