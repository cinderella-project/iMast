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
import Mew
import iMastiOSCore

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
        for descriptor in [
            CodableViewDescriptor.home,
            CodableViewDescriptor.notifications,
            CodableViewDescriptor.local,
        ] {
            let vc = UINavigationController(rootViewController: descriptor.createViewController(with: environment))
            vc.tabBarItem.image = descriptor.systemImage
            vc.tabBarItem.title = descriptor.localizedShortTitle
            vc.tabBarItem.accessibilityIdentifier = "descriptor:" + String(data: try! JSONEncoder().encode(descriptor), encoding: .utf8)!
            lazyLoadVCs.append(vc)
        }

        let otherVC = UINavigationController(rootViewController: OtherMenuViewController.instantiate(environment: self.environment))
        otherVC.tabBarItem.image = UIImage(systemName: "ellipsis")
        otherVC.tabBarItem.title = L10n.Localizable.other
        otherVC.tabBarItem.accessibilityIdentifier = "others"
        lazyLoadVCs.append(otherVC)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressed))
        self.tabBar.addGestureRecognizer(longPressRecognizer)
    }
    
    var firstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        if firstAppear {
            self.setViewControllers(lazyLoadVCs, animated: false)
            firstAppear = false
            startStateRestoration()
            for (i, vc) in lazyLoadVCs.enumerated() {
                var cmd = (i + 1)
                if cmd > 8 && cmd != lazyLoadVCs.count {
                    continue
                }
                if cmd == lazyLoadVCs.count {
                    cmd = 9
                }
                addKeyCommand(.init(
                    title: L10n.Localizable.switchTab(vc.tabBarItem.title ?? "(unknown)"),
                    action: #selector(changeActiveTab(_:)),
                    input: cmd.description, modifierFlags: .command,
                    propertyList: i
                ))
            }
        }
        super.viewDidAppear(animated)
    }
    
    @objc func changeActiveTab(_ sender: UIKeyCommand) {
        guard let i = sender.propertyList as? Int else { return }
        selectedIndex = i
    }
    
    @objc func onLongPressed() {
        if selectedIndex != (tabBar.items ?? []).count-1 {
            return
        }
        let vc = ChangeActiveAccountViewController()
        vc.title = L10n.Localizable.switchActiveAccount
        let navC = UINavigationController(rootViewController: vc)
        vc.navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel, target: navC, action: #selector(navC.close))
        present(navC, animated: true, completion: nil)
    }
    
    func startStateRestoration() {
        guard var mastodonStateRestoration = view.window?.windowScene?.session.mastodonStateRestoration else { return }
        mastodonStateRestoration.userToken = environment
        _ = try? dbQueue.inDatabase { db in
            try mastodonStateRestoration.save(db)
        }
        let displayingScreen = mastodonStateRestoration.displayingScreen
        guard displayingScreen.safe(0) == "main" else { return }
        guard let id = displayingScreen.safe(1).map({ String($0) }) else { return }
        guard let viewControllers = viewControllers else { return }
        if let vc = viewControllers.first(where: { $0.tabBarItem.accessibilityIdentifier == id }) {
            selectedViewController = vc
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let id = item.accessibilityIdentifier,
            var mastodonStateRestoration = view.window?.windowScene?.session.mastodonStateRestoration {
            mastodonStateRestoration.displayingScreen = ["main", id]
            _ = try? dbQueue.inDatabase { db in
                try mastodonStateRestoration.save(db)
            }
        }
    }
}
