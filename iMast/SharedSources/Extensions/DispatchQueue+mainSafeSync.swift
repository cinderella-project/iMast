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
    
    class func mainSafeSync<T>(execute closure: () -> T) -> T {
        if Thread.isMainThread {
            return closure()
        } else {
            return DispatchQueue.main.sync(execute: closure)
        }
    }
    
    class func mainSafeSync<T>(execute closure: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try closure()
        } else {
            return try DispatchQueue.main.sync(execute: closure)
        }
    }
}
