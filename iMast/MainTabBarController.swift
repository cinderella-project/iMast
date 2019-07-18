//
//  MainTabBarController.swift
//  iMast
//
//  Created by user on 2017/11/24.
//  
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2019 rinsuki and other contributors.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import ActionClosurable

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let homeVC = UINavigationController(rootViewController: HomeTimeLineTableViewController())
        homeVC.tabBarItem.image = R.image.homeOutline()
        homeVC.tabBarItem.selectedImage = R.image.home()
        homeVC.tabBarItem.title = R.string.localizable.homeTimelineShort()

        let notifyVC = UINavigationController(rootViewController: NotificationTableViewController())
        notifyVC.tabBarItem.image = R.image.notificationOutline()
        notifyVC.tabBarItem.selectedImage = R.image.notification()
        notifyVC.tabBarItem.title = R.string.localizable.notifications()

        let ltlVC = UINavigationController(rootViewController: LocalTimeLineTableViewController())
        ltlVC.tabBarItem.image = R.image.peopleOutline()
        ltlVC.tabBarItem.selectedImage = R.image.people()
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
