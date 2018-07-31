//
//  UNUserNotificationCenter.requestAuthorization+Hydra.Promise.swift
//  iMast
//
//  Created by user on 2018/07/31.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import UserNotifications
import Hydra

@available(iOS 10.0, *)
extension UNUserNotificationCenter {
    func requestAuthorization(options: UNAuthorizationOptions) -> Promise<Bool> {
        return Promise<Bool> { resolve, reject, _ in
            self.requestAuthorization(options: options, completionHandler: { accepted, error in
                if let error = error {
                    reject(error)
                } else {
                    resolve(accepted)
                }
            })
        }
    }
}
