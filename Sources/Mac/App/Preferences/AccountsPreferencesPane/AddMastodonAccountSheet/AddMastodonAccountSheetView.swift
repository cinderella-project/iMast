//
//  AddMastodonAccountSheetView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/12/23.
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

import Cocoa
import Ikemen
import iMastMacCore
import AuthenticationServices

class AddMastodonAccountSheetView: NSView {
    let errorTextLabel = NSTextField(labelWithString: "") ※ { v in
        v.textColor = .systemRed
    }
    let cancelButton = NSButton(title: "キャンセル", target: nil, action: nil) ※ { b in
        b.keyEquivalent = "\u{1B}"
    }
    let nextButton = NSButton(title: "次へ", target: nil, action: nil) ※ { b in
        b.keyEquivalent = "\r"
    }
    
    let hostNameField = NSTextField(string: "") ※ { v in
        v.placeholderString = "mstdn.example.com"
    }
    
    let loginMethodSelect = NSPopUpButton() ※ { v in
        v.addItems(withTitles: [
            // TODO: Safariログインに対応 (たぶんないと審査が通らない)
//            "Safari",
//            "Safari（プライベートブラウズ）",
            "デフォルトブラウザ",
        ])
    }
    
    let indicator = NSProgressIndicator() ※ { v in
        v.style = .spinning
        v.controlSize = .small
        v.startAnimation(nil)
    }
    
    let codeLabel = NSTextField(labelWithString: "コード:")
    let codeField = NSSecureTextField(string: "") ※ { v in
        v.placeholderString = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsUuTtV"
    }
    
    init() {
        super.init(frame: .zero)
        
        let stackView = NSStackView(views: [
            NSTextField(labelWithString: "Mastodonアカウントにサインイン") ※ { v in
                v.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
                v.alignment = .natural
            },
            errorTextLabel,
            NSGridView(views: [
                [ NSTextField(labelWithString: "サーバアドレス:"), hostNameField ],
                [ NSTextField(labelWithString: "認証に使用するブラウザ:"), loginMethodSelect ],
                [ codeLabel, codeField ],
            ]) ※ { v in
                v.column(at: 0).xPlacement = .trailing
                v.rowAlignment = .firstBaseline
                for r in 1..<v.numberOfRows {
                    v.row(at: r).topPadding = 8
                }
            },
            NSStackView(views: [
                SpacerView(),
                indicator,
                cancelButton,
                nextButton,
            ]) ※ { v in
                v.orientation = .horizontal
                v.setHuggingPriority(.required, for: .horizontal)
                v.setHuggingPriority(.required, for: .vertical)
            },
        ]) ※ { v in
            v.spacing = 16
            v.orientation = .vertical
            v.setHuggingPriority(.required, for: .horizontal)
            v.setHuggingPriority(.required, for: .vertical)
        }
        
        nextButton.snp.makeConstraints { make in
            make.width.equalTo(cancelButton.snp.width)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.size.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
