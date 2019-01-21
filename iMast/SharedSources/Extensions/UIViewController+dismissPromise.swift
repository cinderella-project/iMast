//
//  UIViewController+dismissPromise.swift
//  iMast
//
//  Created by user on 2019/01/21.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Hydra

extension UIViewController {
    func dismissPromise(animated: Bool) -> Promise<()> {
        return Promise<()> { resolve, _, _ in
            self.dismiss(animated: animated) {
                resolve(())
            }
        }
    }
}
