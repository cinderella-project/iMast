//
//  AboutAppPanel.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/16.
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

class AboutAppPanel: NSPanel {
    lazy var acknowledgementsWindow = AcknowledgementsWindow()
    
    let iconView = NSImageView() ※ {
        $0.snp.makeConstraints { make in
            make.size.equalTo(96)
        }
    }
    let appNameField = NSTextField(labelWithString: "iMast") ※ {
        $0.font = .boldSystemFont(ofSize: 14)
    }
    let appVersionField = NSTextField(labelWithString: "Version X.X (XXX)") ※ {
        $0.font = .systemFont(ofSize: 10)
    }
    let appCopyrightField = NSTextField(labelWithString: "Copyrights here") ※ {
        $0.font = .systemFont(ofSize: 10)
    }
    lazy var openAcknowledgementsButton = NSButton(title: "Acknowledgements…", target: self, action: #selector(openAcknowledgementsWindow(_:)))
    
    convenience init() {
        self.init(contentRect: .zero, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        hidesOnDeactivate = false
        
        iconView.image = NSApplication.shared.applicationIconImage
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        appVersionField.stringValue = "Version \(appVersion) (\(appBuild))"
        appCopyrightField.stringValue = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
        let view = NSView()
        let stackView = NSStackView(views: [
            appNameField,
            appVersionField,
            appCopyrightField,
        ]) ※ {
            $0.orientation = .vertical
            $0.alignment = .leading
            $0.spacing = 8
        }
        let infoStackView = NSStackView(views: [
            iconView,
            stackView,
        ]) ※ {
            $0.spacing = 8
            $0.alignment = .centerY
        }
        let topStackView = NSStackView(views: [
            infoStackView,
            openAcknowledgementsButton,
        ]) ※ {
            $0.spacing = 8
            $0.orientation = .vertical
        }
        view.addSubview(topStackView)
        topStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        contentView = view
    }
    
    @objc func openAcknowledgementsWindow(_ sender: Any) {
        acknowledgementsWindow.isReleasedWhenClosed = false
        acknowledgementsWindow.center()
        acknowledgementsWindow.makeKeyAndOrderFront(self)
        acknowledgementsWindow.center()
    }
}
