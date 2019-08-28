//
//  MainTabBarController.swift
//  iMast
//
//  Created by rinsuki on 2017/11/24.
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
import Mew

class MainTabBarController: UITabBarController, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken

    let environment: Environment
    
    var lazyLoadVCs: [UIViewController] = []

    required init(with input: Input, environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let homeVC = UINavigationController(rootViewController: HomeTimeLineTableViewController.instantiate(.plain, environment: self.environment))
        homeVC.tabBarItem.image = UIImage(systemName: "house")
        homeVC.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        homeVC.tabBarItem.title = R.string.localizable.homeTimelineShort()
        homeVC.tabBarItem.accessibilityIdentifier = "home"

        let notifyVC = UINavigationController(rootViewController: NotificationTableViewController.instantiate(environment: self.environment))
        notifyVC.tabBarItem.image = UIImage(systemName: "bell")
        notifyVC.tabBarItem.selectedImage = UIImage(systemName: "bell.fill")
        notifyVC.tabBarItem.title = R.string.localizable.notifications()
        notifyVC.tabBarItem.accessibilityIdentifier = "notifications"

        let ltlVC = UINavigationController(rootViewController: LocalTimeLineTableViewController.instantiate(.plain, environment: self.environment))
        ltlVC.tabBarItem.image = UIImage(systemName: "person.and.person")
        ltlVC.tabBarItem.selectedImage = UIImage(systemName: "person.and.person.fill")
        ltlVC.tabBarItem.title = R.string.localizable.localTimelineShort()
        ltlVC.tabBarItem.accessibilityIdentifier = "ltl"

        let otherVC = UINavigationController(rootViewController: OtherMenuViewController.instantiate(environment: self.environment))
        otherVC.tabBarItem.image = R.image.moreOutline()
        otherVC.tabBarItem.selectedImage = R.image.more()
        otherVC.tabBarItem.title = R.string.localizable.other()
        otherVC.tabBarItem.accessibilityIdentifier = "others"
        
        lazyLoadVCs = [
            homeVC,
            notifyVC,
            ltlVC,
            otherVC,
        ]
        
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
    
    var firstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        if firstAppear {
            self.setViewControllers(lazyLoadVCs, animated: false)
            firstAppear = false
            startStateRestoration()
        }
        super.viewDidAppear(animated)
    }
    
    func startStateRestoration() {
        guard var mastodonStateRestoration = view.window?.windowScene?.session.mastodonStateRestoration else { return }
        mastodonStateRestoration.userToken = environment
        _ = try? dbQueue.inDatabase { db in
            try mastodonStateRestoration.save(db)
        }
        let displayingScreen = mastodonStateRestoration.displayingScreen.split(separator: ".")
        guard displayingScreen.safe(0) == "main" else { return }
        guard let id = displayingScreen.safe(1).map({ String($0) }) else { return }
        guard let viewControllers = viewControllers else { return }
        for vc in viewControllers where vc.tabBarItem.accessibilityIdentifier == id {
            selectedViewController = vc
            break
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let id = item.accessibilityIdentifier,
            var mastodonStateRestoration = view.window?.windowScene?.session.mastodonStateRestoration {
            mastodonStateRestoration.displayingScreen = ["main", id].joined(separator: ".")
            _ = try? dbQueue.inDatabase { db in
                try mastodonStateRestoration.save(db)
            }
        }
    }
}
