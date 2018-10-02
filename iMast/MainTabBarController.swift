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
        let homeVC = UINavigationController(rootViewController:  HomeTimeLineTableViewController())
        homeVC.tabBarItem.image = R.image.homeOutline()
        homeVC.tabBarItem.selectedImage = R.image.home()
        homeVC.tabBarItem.title = "ホーム"

        let notifyVC = UINavigationController(rootViewController: NotificationTableViewController())
        notifyVC.tabBarItem.image = R.image.notificationOutline()
        notifyVC.tabBarItem.selectedImage = R.image.notification()
        notifyVC.tabBarItem.title = "通知"

        let ltlVC = UINavigationController(rootViewController: LocalTimeLineTableViewController())
        ltlVC.tabBarItem.image = R.image.peopleOutline()
        ltlVC.tabBarItem.selectedImage = R.image.people()
        ltlVC.tabBarItem.title = "LTL"
        
        self.setViewControllers([
            homeVC,
            notifyVC,
            ltlVC,
            R.storyboard.otherMenu.instantiateInitialViewController()!,
        ], animated: false)
        
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
