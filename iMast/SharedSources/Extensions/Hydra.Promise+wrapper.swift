//
//  Hydra.Promise+wrapper.swift
//  iMast
//
//  Created by user on 2018/07/31.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Hydra

func PromiseWrapper<T>(_ fnc: @escaping (() throws -> T)) -> Promise<T> {
    return Promise<T> { resolve, _, _ in
        resolve(try fnc())
    }
}
    
func PromiseWrapperWithPromise<T>(_ fnc: (() throws -> Promise<T>)) -> Promise<T> {
    do {
        return try fnc()
    } catch {
        return Promise<T>(rejected: error)
    }
}
