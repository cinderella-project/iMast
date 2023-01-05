//
//  DispatchQueue+mainSafeSync.swift
//  iMast
//
//  Created by rinsuki on 2018/08/23.
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

extension DispatchQueue {
    static public func mainSafeSync(execute closure: () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.sync(execute: closure)
        }
    }
    
    static public func mainSafeSync<T>(execute closure: () -> T) -> T {
        if Thread.isMainThread {
            return closure()
        } else {
            return DispatchQueue.main.sync(execute: closure)
        }
    }
    
    static public func mainSafeSync<T>(execute closure: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try closure()
        } else {
            return try DispatchQueue.main.sync(execute: closure)
        }
    }
    
    static public func mainAsyncIfNeed(execute closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
}
