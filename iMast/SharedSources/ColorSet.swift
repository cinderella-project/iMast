//
//  ColorSet.swift
//  iMast
//
//  Created by user on 2019/03/19.
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

import Foundation
import UIKit

// iOS 10.x対応のため
// iOS 10.xを切ったらとっととColor Assetsに移行する
struct ColorSet {
    static let boostedBar = UIColor(red: 0.1, green: 0.7, blue: 0.1, alpha: 1)
    static let favouriteBar = UIColor(hue: 52 / 360.0, saturation: 0.9, brightness: 0.9, alpha: 1)
    
    @available(*, unavailable)
    init() {
        fatalError("これはinitするものじゃないです")
    }
}
