//
//  SceneDelegate.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/07/24.
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

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var windows: [UIWindow] = []
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            if let myAccount = MastodonUserToken.getLatestUsed() {
                window.rootViewController = MainTabBarController.instantiate(environment: myAccount)
                myAccount.getUserInfo().then { json in
                    if json["error"].string != nil && json["_response_code"].number == 401 {
                        myAccount.delete()
                        window.rootViewController = UINavigationController(rootViewController: AddAccountIndexViewController())
                    }
                }
            } else {
                window.rootViewController = UINavigationController(rootViewController: AddAccountIndexViewController())
            }
            window.makeKeyAndVisible()
            self.windows.append(window)
        }
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
}
