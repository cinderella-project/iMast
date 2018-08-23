//
//  DispatchQueue+mainSafeSync.swift
//  iMast
//
//  Created by user on 2018/08/23.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

extension DispatchQueue {
    class func mainSafeSync(execute closure: () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.sync(execute: closure)
        }
    }
}
