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
import Crossroad
import Hydra
import iMastiOSCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var windows: [UIWindow] = []
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print(session.mastodonStateRestoration)
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        var token = MastodonUserToken.getLatestUsed()
        let stateRestoration = session.mastodonStateRestoration
        if let t = stateRestoration.userToken {
            token = t
        }
        if let notifyRes = connectionOptions.notificationResponse {
            let content = notifyRes.notification.request.content
            notificationModal: do {
                guard let account = content.userInfo["account"] as? [String], account.count == 2 else {
                    break notificationModal
                }
                guard let t = try? MastodonUserToken.findUserToken(userName: account[0], instance: account[1]) else {
                    break notificationModal
                }
                token = t
            }
        }
        if let myAccount = token {
            window.rootViewController = Defaults[.newFirstScreen]
                ? TopViewController()
                : MainTabBarController.instantiate(environment: myAccount)
            #if !targetEnvironment(macCatalyst)
            if let item = connectionOptions.shortcutItem {
                self.windowScene(windowScene, performActionFor: item) { _ in }
            }
            #endif
            myAccount.getUserInfo().then { json in
                if json["error"].string != nil && json["_response_code"].number == 401 {
                    try myAccount.delete()
                    window.rootViewController = UINavigationController(rootViewController: AddAccountIndexViewController())
                }
            }
            if let notifyRes = connectionOptions.notificationResponse {
                let content = notifyRes.notification.request.content
                notificationModal: do {
                    if let urlString = content.userInfo["informationUrl"] as? String, let url = URL(string: urlString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        break notificationModal
                    }

                    guard let notificationJson = content.userInfo["upstreamObject"] as? String else {
                        print("notify object not found")
                        break notificationModal
                    }
                    
                    let decoder = JSONDecoder()
                    guard let notification = try? decoder.decode(MastodonNotification.self, from: notificationJson.data(using: .utf8)!) else {
                        print("decode failed")
                        break notificationModal
                    }
                    
                    guard let newVC = NotificationTableViewController.getNotifyVC(notification, environment: myAccount) else {
                        break notificationModal
                    }
                    window.rootViewController?.present(ModalNavigationViewController(rootViewController: newVC), animated: true, completion: nil)
                }
            }
        } else {
            window.rootViewController = UINavigationController(rootViewController: AddAccountIndexViewController())
        }
        self.windows.append(window)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let router = DefaultRouter(scheme: "imast")
        router.register([
            ("/callback/", { context in
                guard
                    let code: String = context[parameter: "code"],
                    let state: String = context[parameter: "state"]
                else {
                    return false
                }
                let nextVC = AddAccountSuccessViewController()
                let app = MastodonApp.initFromId(appId: state)
                asyncPromise {
                    let userToken = try await app.authorizeWithCode(code: code).wait()
                    _ = try await userToken.getUserInfo().wait()
                    try userToken.save()
                    userToken.use()
                    nextVC.userToken = userToken
                }.then(in: .main) { [weak scene] in
                    guard let scene = scene as? UIWindowScene else {
                        return
                    }
                    guard let window = scene.windows.first else {
                        return
                    }
                    window.rootViewController = nextVC
                }
                return true
            }),
            ("/from-backend/push/oauth-finished", { _ in
                NotificationCenter.default.post(name: .pushSettingsAccountReload, object: nil)
                return true
            }),
        ])
        for context in URLContexts {
            if router.openIfPossible(context.url, options: [:]) {
                return
            }
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let token = MastodonUserToken.getLatestUsed() else {
            return completionHandler(false)
        }
        guard let vc = windowScene.windows.first?.rootViewController else {
            return completionHandler(false)
        }
        let newVC = StoryboardScene.NewPost.initialScene.instantiate()
        newVC.userToken = token
        vc.present(ModalNavigationViewController(rootViewController: newVC), animated: true, completion: nil)
        print("animated")
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
}
