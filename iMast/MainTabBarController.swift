//
//  MainTabBarController.swift
//  iMast
//
//  Created by user on 2017/11/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import ActionClosurable

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressRecognizer = UILongPressGestureRecognizer { _ in
            if self.selectedIndex != (self.tabBar.items ?? []).count-1 {
                return
            }
            let navC = UINavigationController()
            let vc = OtherMenuAccountChangeTableViewController()
            vc.navigationItem.leftBarButtonItems = [
                UIBarButtonItem(title: "キャンセル", style: .plain) { _ in
                    navC.dismiss(animated: true, completion: nil)
                }
            ]
            vc.title = "アカウントを変更"
            navC.pushViewController(vc, animated: false)
            self.present(navC, animated: true, completion: nil)
        }
        self.tabBar.addGestureRecognizer(longPressRecognizer)
    }
}
