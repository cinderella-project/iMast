//
//  UIViewController+presentPromise.swift
//  iMast
//
//  Created by user on 2019/01/21.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Hydra

extension UIViewController {
    func presentPromise(_ viewControllerToPresent: UIViewController, animated: Bool) -> Promise<Void> {
        return Promise<Void>(in: .main) { resolve, _, _ in
            self.present(viewControllerToPresent, animated: animated) {
                resolve(())
            }
        }
    }
}
