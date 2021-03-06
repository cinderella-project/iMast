//
//  AccountsPreferencesPaneView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/11.
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

class AccountsPreferencesPaneView: NSView {
    
    let accountsTableView = NSTableView() ※ { v in
        v.addTableColumn(.init() ※ {
            $0.resizingMask = .autoresizingMask
        })
        v.headerView = nil
        v.usesAutomaticRowHeights = true
    }
    
    lazy private(set) var accountsTableViewWrapperScrollView = NSScrollView() ※ { v in
        v.documentView = self.accountsTableView
        v.borderType = .bezelBorder
        v.hasVerticalScroller = true
        v.autohidesScrollers = true
    }
    
    let addOrRemoveSegmentedControl = NSSegmentedControl(images: [
        NSImage(named: NSImage.addTemplateName)!,
        NSImage(named: NSImage.removeTemplateName)!,
        NSImage(size: .zero),
    ], trackingMode: .momentary, target: nil, action: nil) ※ { c in
        c.segmentStyle = .smallSquare
        c.setEnabled(false, forSegment: 2)
        c.setWidth(180, forSegment: 2)
        c.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    init() {
        super.init(frame: .zero)

        let topStackView = NSStackView(views: [
            NSStackView(views: [
                accountsTableViewWrapperScrollView,
                addOrRemoveSegmentedControl,
            ]) ※ { v in
                v.orientation = .vertical
                v.spacing = -1
                v.setHuggingPriority(.required, for: .horizontal)
                v.snp.makeConstraints { make in
                    make.width.equalTo(addOrRemoveSegmentedControl)
                }
            },
            NSBox() ※ { v in
                v.translatesAutoresizingMaskIntoConstraints = false
                v.titlePosition = .noTitle
                v.snp.makeConstraints { make in make.width.equalTo(320) }
            },
        ]) ※ { v in
            v.orientation = .horizontal
            v.setHuggingPriority(.required, for: .horizontal)
        }
        
        addSubview(topStackView)
        
        topStackView.snp.makeConstraints { make in
            make.center.size.equalToSuperview().inset(16)
            make.height.equalTo(480)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
