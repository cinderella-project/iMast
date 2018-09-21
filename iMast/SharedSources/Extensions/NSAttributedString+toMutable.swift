//
//  NSAttributedString+mutableCopy.swift
//  iMast
//
//  Created by user on 2018/09/21.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func toMutable() -> NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: self)
    }
}
