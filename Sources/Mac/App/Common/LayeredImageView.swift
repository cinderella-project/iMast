//
//  LayeredImageView.swift
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
import SDWebImage

/// CALayer で NSImage を描画する View
/// 環境設定→表示内のアンチエイリアスの設定によってアンチエイリアスがかかる
class LayeredImageView: NSView {
    var image: NSImage? {
        didSet {
            layer?.contents = image
        }
    }
    
    @objc dynamic var filterBias: Float = 0 {
        didSet {
            layer?.minificationFilterBias = filterBias
        }
    }
    
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.minificationFilter = .trilinear
        bind(.init("filterBias"), to: NSUserDefaultsController.appGroup, withKeyPath: "values.trilinear_bias", options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImage(url: URL?) {
        SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { [weak self] (image, _, _, _, _, _) in
            self?.image = image
        }
    }
}
