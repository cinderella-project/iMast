//
//  NSRange+optional.swift
//  iMast
//
//  Created by user on 2018/10/22.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import Foundation

extension NSRange {
    var optional: NSRange? { get {
        return self.location == NSNotFound ? nil : self
    } }
}
