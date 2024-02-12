//
//  NewPostSceneDelegate.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2024/02/06.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

class NewPostSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        var success = false
        defer {
            if !success {
                UIApplication.shared.requestSceneSessionDestruction(session, options: nil)
            }
        }
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        guard let activity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivity.activityTypeNewPost }) ?? scene.session.stateRestorationActivity,
              let userToken = activity.mastodonUserToken() else {
            print("does not find activity or userToken", scene.session.stateRestorationActivity)
            return
        }
        
        #if os(visionOS)
        windowScene.requestGeometryUpdate(.Vision(size: .init(width: 800, height: 600), minimumSize: .init(width: 320, height: 320)))
        #endif
        
        window = UIWindow(windowScene: windowScene)
        if let window = window {
            let newPostVC = NewPostViewController(userActivity: activity)
            window.rootViewController = ModalNavigationViewController(rootViewController: newPostVC, asSceneRoot: true)
            window.makeKeyAndVisible()

            success = true
        }
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        print("state restoration activity", scene.userActivity)
        return ((scene as? UIWindowScene)?.keyWindow?.rootViewController as? UINavigationController)?.viewControllers.first?.userActivity
    }
}
