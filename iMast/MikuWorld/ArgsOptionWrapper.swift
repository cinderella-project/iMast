//
//  ArgsOptionWrapper.swift
//  iMast
//
//  Created by user on 2019/02/23.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

extension mrb_aspec {
    static let none: mrb_aspec = 0
    
    static func requiredArgs(_ count: UInt32) -> mrb_aspec {
        return (count & 0x1f) << 18
    }
    
    static func optionalArgs(_ count: UInt32) -> mrb_aspec {
        return (count & 0x1f) << 13
    }
    
    // *hoge 的な
    static let rest: mrb_aspec = 1 << 12
    
    // *hoge の後のやつ
    static func afterRestRequiredArgs(_ count: UInt32) -> mrb_aspec {
        return (count & 0x1f) << 7
    }
    
    static func keyArgs(keys: UInt32, kdict: Bool) -> mrb_aspec {
        return ((keys & 0x1f) << 2) | (kdict ? 1 : 0)
    }
    
    static let blockArg: mrb_aspec = 1
}
