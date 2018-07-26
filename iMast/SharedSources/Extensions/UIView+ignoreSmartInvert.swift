//
//  UIView+ignoreSmartInvert.swift
//  iMast
//
//  Created by user on 2018/07/27.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit

extension UIView {
    func ignoreSmartInvert(_ state: Bool = true) {
        if #available(iOS 11.0, *) {
            self.accessibilityIgnoresInvertColors = state
        }
    }
}
