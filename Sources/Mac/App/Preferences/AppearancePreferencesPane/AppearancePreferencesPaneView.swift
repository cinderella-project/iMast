//
//  AppearancePreferencesPaneView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/19.
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
import iMastMacCore
import Ikemen

class AppearancePreferencesPaneView: NSView {
    let slider = NSSlider(value: 0, minValue: -2, maxValue: 0, target: nil, action: nil) ※ {
        $0.numberOfTickMarks = 5
        $0.allowsTickMarkValuesOnly = true
        $0.bind(.value, to: NSUserDefaultsController.appGroup, withKeyPath: "values.trilinear_bias", options: [.continuouslyUpdatesValue: true])
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    init() {
        super.init(frame: .zero)
        let grid = NSGridView(views: [
            [NSTextField(labelWithString: "アンチエイリアス:"), NSStackView(views: [
                slider,
                NSStackView(views: [
                    NSTextField(labelWithString: "パリっと"),
                    SpacerView(horizontal: true, vertical: false),
                    NSTextField(labelWithString: "ボヤっと"),
                ]),
            ]) ※ {
                $0.orientation = .vertical
            }]
        ]) ※ {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
        }
        addSubview(grid)
        grid.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
