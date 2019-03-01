//
//  UIViewController+fakeSafeAreaLayoutGuide.swift
//  iMast
//
//  Created by user on 2019/03/02.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // iOS 11以前の場合Safe Areaのかわりに(Top|Bottom) Layout Guideを使うやつ
    var fakeSafeAreaLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaLayoutGuide
        } else {
            let layoutGuide = UILayoutGuide()
            self.view.addLayoutGuide(layoutGuide)
            self.topLayoutGuide.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
            self.bottomLayoutGuide.topAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
            self.view.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor).isActive = true
            self.view.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor).isActive = true
            return layoutGuide
        }
    }
}
