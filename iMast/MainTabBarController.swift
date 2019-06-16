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
        let homeVC = UINavigationController(rootViewController: HomeTimeLineTableViewController())
        homeVC.tabBarItem.image = UIImage(systemName: "house")
        homeVC.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        homeVC.tabBarItem.title = R.string.localizable.homeTimelineShort()

        let notifyVC = UINavigationController(rootViewController: NotificationTableViewController())
        notifyVC.tabBarItem.image = UIImage(systemName: "bell")
        notifyVC.tabBarItem.selectedImage = UIImage(systemName: "bell.fill")
        notifyVC.tabBarItem.title = R.string.localizable.notifications()

        let ltlVC = UINavigationController(rootViewController: LocalTimeLineTableViewController())
        ltlVC.tabBarItem.image = UIImage(systemName: "person.and.person")
        ltlVC.tabBarItem.selectedImage = UIImage(systemName: "person.and.person.fill")
        ltlVC.tabBarItem.title = R.string.localizable.localTimelineShort()

        let otherVC = UINavigationController(rootViewController: OtherMenuViewController())
        otherVC.tabBarItem.image = R.image.moreOutline()
        otherVC.tabBarItem.selectedImage = R.image.more()
        otherVC.tabBarItem.title = R.string.localizable.other()
        
        self.setViewControllers([
            homeVC,
            notifyVC,
            ltlVC,
            otherVC,
        ], animated: false)
        
        let longPressRecognizer = UILongPressGestureRecognizer { _ in
            if self.selectedIndex != (self.tabBar.items ?? []).count-1 {
                return
            }
            let navC = UINavigationController()
            let vc = ChangeActiveAccountViewController()
            vc.navigationItem.leftBarButtonItems = [
                UIBarButtonItem(title: R.string.localizable.cancel(), style: .plain) { _ in
                    navC.dismiss(animated: true, completion: nil)
                },
            ]
            vc.title = R.string.localizable.switchActiveAccount()
            navC.pushViewController(vc, animated: false)
            self.present(navC, animated: true, completion: nil)
        }
        self.tabBar.addGestureRecognizer(longPressRecognizer)
    }
}
