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
import UserNotifications
import Hydra
import iMastiOSCore
import SDWebImage

#if DEBUG
public extension NSObject {
    @objc func _imast_scaleFactor() -> Double {
        return 1.0
    }
}

var _scaleFactorSwizzling = false
func _doScaleFactorSwizzlingIfNot() {
    guard ProcessInfo.processInfo.isiOSAppOnMac else {
        return
    }
    guard !_scaleFactorSwizzling else {
        return
    }
    _scaleFactorSwizzling = true
    let uinsSceneViewClass = NSClassFromString("UINSSceneView")
    let uinsSceneContainerViewClass = NSClassFromString("UINSSceneContainerView")
    let method = class_getClassMethod(NSObject.self, #selector(NSObject._imast_scaleFactor))!
    method_setImplementation(class_getInstanceMethod(uinsSceneViewClass, "sceneToSceneViewScaleFactor")!, method_getImplementation(method))
    method_setImplementation(class_getInstanceMethod(uinsSceneViewClass, "fixedSceneToSceneViewScaleFactor")!, method_getImplementation(method))
    method_setImplementation(class_getInstanceMethod(uinsSceneContainerViewClass, "sceneToSceneViewScaleForLayout")!, method_getImplementation(method))
}

#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // とりあえずもろもろ初期化
        #if DEBUG
        _doScaleFactorSwizzlingIfNot()
        #endif
        UserDefaults.standard.register(defaults: [
            // disable floating tab bar due to https://developer.apple.com/forums/thread/763446
            // TODO: check after next patch release, and think it about adopt to iPadOS 18's new floating tab bar
            "UseFloatingTabBar": false, // why everyone trying to overriding trait for disable floating tab bar
        ])
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0)
        SDWebImageDownloader.shared.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
        self.registerDefaultsFromSettingsBundle()
        self.migrateUserDefaultsToAppGroup()
        initDatabase()
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
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

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        for session in sceneSessions {
            print("deleting session \(session.persistentIdentifier)")
            _ = try? dbQueue.inDatabase { db in
                try MastodonStateRestoration.deleteOne(db, key: [
                    MastodonStateRestoration.CodingKeys.systemPersistentIdentifier.rawValue: session.persistentIdentifier,
                ])
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushService.updateDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if options.userActivities.contains(where: { $0.activityType == NSUserActivity.activityTypeNewPost }) {
            return UISceneConfiguration(name: "NewPost", sessionRole: connectingSceneSession.role)
        }
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print(userInfo)
        if let urlString = userInfo["informationUrl"] as? String, let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        
        guard let receiveUser = userInfo["receiveUser"] as? [String] else {
            completionHandler()
            return
        }
        
        guard let currentScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).min(by: {
            let aScore: Int
            switch $0.activationState {
            case .unattached:
                aScore = 0
            case .foregroundActive:
                aScore = 10
            case .foregroundInactive:
                aScore = 9
            case .background:
                aScore = 5
            }
            let bScore: Int
            switch $1.activationState {
            case .unattached:
                bScore = 0
            case .foregroundActive:
                bScore = 10
            case .foregroundInactive:
                bScore = 9
            case .background:
                bScore = 5
            }
            return aScore > bScore
        }) else {
            return
        }
        
        var viewController: UIViewController? = currentScene.windows.first?.rootViewController
        
        guard let receivedUserToken = try? MastodonUserToken.findUserToken(userName: receiveUser[0], instance: receiveUser[1]) else {
            viewController?.alert(
                title: L10n.Localizable.Error.title,
                message: "選択した通知のアカウント「\(receiveUser.joined(separator: "@"))」が見つかりませんでした。"
            )
            completionHandler()
            return
        }
        
        guard let currentUserToken = currentScene.session.mastodonStateRestoration.userToken ?? MastodonUserToken.getLatestUsed() else {
            completionHandler()
            return
        }
        
        if receivedUserToken.id != currentUserToken.id && type(of: viewController!) != TopViewController.self {
            receivedUserToken.use()
            let vc = MainTabBarController.instantiate(environment: receivedUserToken)
            viewController = vc
            currentScene.windows.first!.rootViewController?.changeRootVC(vc)
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
        
        guard let newVC = NotificationTableViewController.getNotifyVC(notification, environment: receivedUserToken) else {
            completionHandler()
            return
        }
        
        viewController?.present(ModalNavigationViewController(rootViewController: newVC), animated: true, completion: nil)
        completionHandler()
    }
}

func openVLC(_ url: String) -> Bool {
    if !Defaults.webmVlcOpen {
        return false
    }
    let vlcOpenUrl = URL(string: "vlc-x-callback://x-callback-url/stream?url=\(url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)")!
    if UIApplication.shared.canOpenURL(vlcOpenUrl) {
        UIApplication.shared.open(vlcOpenUrl)
        return true
    }
    return false
}

extension UIViewController {
    func changeRootVC(_ viewController: UIViewController, reversed: Bool = false) {
        guard let window = self.view.window else {
            fatalError("windowないが")
        }
        window.changeRootVC(viewController, reversed: reversed)
    }
}

extension UIWindow {
    func changeRootVC(_ viewController: UIViewController, reversed: Bool = false) {
        UIView.transition(with: self, duration: 0.5, options: reversed ? .transitionFlipFromLeft : .transitionFlipFromRight, animations: {
            self.rootViewController = viewController
        }, completion: { _ in
            DispatchQueue.main.async {
                allWebSocketDisconnect()
            }
        })
    }
}
