//
//  AutolayoutTextView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/15.
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

/// Auto Layout で NSTextView を複数行ラベル+αとして使う際にうまく動かないのをなんとかするサブクラス
class AutolayoutTextView: NSTextView {
    convenience init() {
        self.init(frame: .zero)
        // 横幅が狭くなったら即座に潰れる
        setContentCompressionResistancePriority(.init(1), for: .horizontal)
        // 横幅が広くなったら即座に広がる
        setContentHuggingPriority(.init(1), for: .horizontal)
        // 縦方向には絶対潰れないし必要以上に伸びもしない
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    override var intrinsicContentSize: NSSize {
        guard let layoutManager = layoutManager, let textContainer = textContainer else {
            return .zero
        }
        layoutManager.ensureLayout(for: textContainer)
        let size = layoutManager.usedRect(for: textContainer).size
        // 整数にしないと non-Retina ディスプレイでぼやける
        return .init(width: ceil(size.width), height: ceil(size.height))
    }
    
    override func layout() {
        // 現在の横幅に応じた必要高さを計算させなおす必要がある
        invalidateIntrinsicContentSize()
        super.layout()
    }
}
