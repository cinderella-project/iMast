//
//  AppDelegate.swift
//  iMast
//
//  Created by rinsuki on 2017/04/22.
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
import Crossroad
import ActionClosurable
import UserNotifications
import SVProgressHUD
import Notifwift
import SafariServices
import Hydra

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // とりあえずもろもろ初期化
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        self.registerDefaultsFromSettingsBundle()
        self.migrateUserDefaultsToAppGroup()
        initDatabase()
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        let myAccount = MastodonUserToken.getLatestUsed()
        if let myAccount = myAccount {
            changeRootVC(MainTabBarController(), animated: false)
            myAccount.getUserInfo().then { json in
                if json["error"].string != nil && json["_response_code"].number == 401 {
                    myAccount.delete()
                    changeRootVC(UINavigationController(rootViewController: AddAccountIndexViewController()), animated: false)
                }
            }
        } else {
            changeRootVC(UINavigationController(rootViewController: AddAccountIndexViewController()), animated: false)
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
            // アップデートしろや
        }
        
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setDefaultMaskType(.black)
        
        // AppGroup/imageCacheを消す
        do {
            let imageCacheUrl = appGroupFileUrl.appendingPathComponent("imageCache")
            if FileManager.default.fileExists(atPath: imageCacheUrl.path) {
                print("start imageCache removing...")
                for path in try FileManager.default.contentsOfDirectory(at: imageCacheUrl, includingPropertiesForKeys: nil, options: []) {
                    try FileManager.default.removeItem(at: path)
                    print("removed imageCache", path)
                }
                try FileManager.default.removeItem(at: imageCacheUrl)
                print("finish!")
            }
        } catch {
            print("remove failed...", error)
        }
        do {
            print("tmp files deleting...")
            for path in try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
                var isDir: ObjCBool = false
                guard FileManager.default.fileExists(atPath: NSTemporaryDirectory() + "/" + path, isDirectory: &isDir) else {
                    continue
                }
                guard isDir.boolValue == false else {
                    continue
                }
                print(path)
                try FileManager.default.removeItem(atPath: NSTemporaryDirectory() + "/" + path)
            }
            print("tmp files delete succuessful!")
        } catch {
            print("tmp remove failed...", error)
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let router = DefaultRouter(scheme: "imast")
        router.register([
            ("callback/", { context in
                guard
                    let code: String = context.parameter(for: "code"),
                    let state: String = context.parameter(for: "state")
                else {
                    return false
                }
                let nextVC = AddAccountSuccessViewController()
                let app = MastodonApp.initFromId(appId: state)
                async { _ in
                    let userToken = try await(app.authorizeWithCode(code: code))
                    _ = try await(userToken.getUserInfo())
                    userToken.save()
                    userToken.use()
                    nextVC.userToken = userToken
                }.then(in: .main) {
                    changeRootVC(nextVC, animated: false)
                }
                return true
            }),
            ("from-backend/push/oauth-finished", { _ in
                Notifwift.post(.pushSettingsAccountReload)
                return true
            })
        ])
        return router.openIfPossible(url, options: options)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if MastodonUserToken.getLatestUsed() != nil {
            if let vc = application.viewController {
                let newVC = UIStoryboard(name: "NewPost", bundle: nil).instantiateInitialViewController()!
                let wrapVC = UINavigationController(rootViewController: newVC)
                newVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: R.string.localizable.cancel(), style: .plain) { _ in
                    wrapVC.dismiss(animated: true, completion: nil)
                }
                vc.present(wrapVC, animated: true, completion: nil)
                print("animated")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let authHeader = try? PushService.getAuthorizationHeader() {
            PushService.updateDeviceToken(deviceToken: deviceToken)
        }
//        print("DeviceToken",deviceToken.reduce("") { $0 + String(format: "%.2hhx", $1)})
//        print("isDebugBuild", isDebugBuild)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func registerDefaultsFromSettingsBundle() {
        // UserDefaultsAppGroup.register(defaults: defaultValues)
    }
    
    func migrateUserDefaultsToAppGroup() {
        let migrateKeyName = "migrated_to_appgroup"
        if UserDefaultsAppGroup.bool(forKey: migrateKeyName) { // already migrated
            print("UserDefaults is already migrated!")
            return
        }
        let oldUserDefaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
        print("MIGRATE: UserDefaults -> AppGroup User Defaults")
        for key in oldUserDefaultsDictionary.keys {
            UserDefaultsAppGroup.set(oldUserDefaultsDictionary[key], forKey: key)
            print("migrating:", key)
        }
        UserDefaultsAppGroup.set(true, forKey: migrateKeyName)
        UserDefaultsAppGroup.synchronize()
        print("UserDefaults migrated!")
    }

}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print(userInfo)
        if let urlString = userInfo["informationUrl"] as? String, let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            UIApplication.shared.keyWindow?.rootViewController?.present(safariVC, animated: true, completion: nil)
            return
        }
        
        guard let receiveUser = userInfo["receiveUser"] as? [String] else {
            completionHandler()
            return
        }
        guard let userToken = try! MastodonUserToken.findUserToken(userName: receiveUser[0], instance: receiveUser[1]) else {
            UIApplication.shared.viewController?.alert(title: R.string.localizable.errorTitle(), message: "選択した通知のアカウント「\(receiveUser.joined(separator: "@"))」が見つかりませんでした。")
            completionHandler()
            return
        }
        if userToken.id != MastodonUserToken.getLatestUsed()?.id {
            userToken.use()
            changeRootVC(MainTabBarController(), animated: true)
        }
        
        guard let topVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {
            print("failed topVC", UIApplication.shared.keyWindow?.rootViewController)
            completionHandler()
            return
        }
        
        topVC.selectedIndex = 1
        
        guard let notifyTabVC = (topVC.viewControllers?[1] as? UINavigationController)?.viewControllers.first as? NotificationTableViewController else {
            print("this is not NotificationTVC")
            completionHandler()
            return
        }
        
        if let vcs = notifyTabVC.navigationController?.viewControllers {
            let count = vcs.count - 2
            if count >= 0 {
                for _ in 0...count {
                    notifyTabVC.navigationController?.popViewController(animated: false)
                }
            }
        }

        guard let notificationJson = userInfo["upstreamObject"] as? String else {
            print("notify object not found")
            completionHandler()
            return
        }
        
        let decoder = JSONDecoder()
        guard let notification = try? decoder.decode(MastodonNotification.self, from: notificationJson.data(using: .utf8)!) else {
            print("decode failed")
            completionHandler()
            return
        }
        
        notifyTabVC.openNotify(notification, animated: false)
        completionHandler()
    }
}

func openVLC(_ url: String) -> Bool {
    if !UserDefaults.standard.bool(forKey: "webm_vlc_open") {
        return false
    }
    let vlcOpenUrl = URL(string: "vlc-x-callback://x-callback-url/stream?url=\(url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)")!
    if UIApplication.shared.canOpenURL(vlcOpenUrl) {
        UIApplication.shared.openURL(vlcOpenUrl)
        return true
    }
    return false
}

func changeRootVC(_ viewController: UIViewController, animated: Bool) {
    guard let window = UIApplication.shared.keyWindow else {
        // windowがないなら、作ってkeyWindowにする
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        (UIApplication.shared.delegate as! AppDelegate).window = window
        return
    }
    if animated {
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
            changeRootVC(viewController, animated: false)
        }, completion: nil)
    } else {
        allWebSocketDisconnect()
        window.rootViewController = viewController
    }
}
