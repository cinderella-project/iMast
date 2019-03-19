//
//  ColorSet.swift
//  iMast
//
//  Created by user on 2019/03/19.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import UIKit

// iOS 10.x対応のため
// iOS 10.xを切ったらとっととColor Assetsに移行する
struct ColorSet {
    static let boostedBar = UIColor(red: 0.1, green: 0.7, blue: 0.1, alpha: 1)
    
    @available(*, unavailable)
    init() {
        fatalError("これはinitするものじゃないです")
    }
}
