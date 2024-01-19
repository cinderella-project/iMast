//
//  ShareNewPostView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/08/01.
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
import SnapKit
import iMastiOSCore

class ShareNewPostView: UIView {
    let textInput = UITextView() ※ {
        $0.font = .systemFont(ofSize: 14)
        #if !os(visionOS)
        $0.keyboardDismissMode = .interactiveWithAccessory
        #endif
    }
    
    let cwInput = UITextFieldWithInsets() ※ {
        $0.placeholder = L10n.NewPost.Placeholders.cwWarningText
        $0.containerInsets = .init(width: 4, height: 0)
        $0.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        $0.font = .systemFont(ofSize: 14)
    }
    
    let currentAccountLabel = UILabel() ※ {
        $0.text = "rin@mastodon.example"
        $0.textColor = .tertiaryLabel
        $0.textAlignment = .right
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 14)
    }
    
    let toolBar = UIToolbar() ※ {
        $0.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    private lazy var imageSelectItem = UIBarButtonItem(customView: imageSelectButton)
    let imageSelectButton = UIButton(type: .system) ※ {
        $0.setImage(.init(systemName: "camera.fill"), for: .normal)
        $0.setTitle(" 0", for: .normal)
        $0.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    let nsfwSwitchItem = UIBarButtonItem(image: .init(systemName: "eye"), style: .plain, target: nil, action: nil) ※ {
        $0.width = 44
    }
    let scopeSelectItem = UIBarButtonItem(image: MastodonPostVisibility.public.uiImage, style: .plain, target: nil, action: nil) ※ {
        $0.width = 44
    }
    
    convenience init() {
        self.init(frame: .zero)
        textInput.backgroundColor = .clear
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        effectView.frame = frame
        addSubview(effectView)
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(toolBar)
        toolBar.items = [
            imageSelectItem,
            nsfwSwitchItem,
            scopeSelectItem,
        ]
        toolBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        let separatorView = SeparatorView()
        
        let stackView = UIStackView(arrangedSubviews: [
            cwInput,
            separatorView,
            textInput,
        ])
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(toolBar.snp.top)
        }
        cwInput.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
        }
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        textInput.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
        }
        
        addSubview(currentAccountLabel)
        currentAccountLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(safeAreaLayoutGuide).inset(8)
        }
        bringSubviewToFront(toolBar)
    }
}
