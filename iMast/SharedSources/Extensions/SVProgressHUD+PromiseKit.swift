//
//  SVProgressHUD+PromiseKit.swift
//  iMast
//
//  Created by user on 2018/07/23.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import SVProgressHUD
import PromiseKit

extension SVProgressHUD {
    static func dismissPromise() -> Promise<Void> {
        return Promise<Void>() { resolver in
            SVProgressHUD.dismiss {
                resolver.resolve((), nil)
            }
        }
    }
}
