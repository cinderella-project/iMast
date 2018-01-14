//
//  AppDelegate.swift
//  iMast
//
//  Created by rinsuki on 2017/04/22.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import Compass

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? {
        didSet {
            allDisconnectWebSocket()
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        self.registerDefaultsFromSettingsBundle()
        self.migrateUserDefaultsToAppGroup()
        initDatabase()
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        var isLogged = false
        let myAccount = MastodonUserToken.getLatestUsed()
        if let myAccount = myAccount {
            isLogged = true
            myAccount.getUserInfo().then { json in
                if json["error"].string != nil && json["_response_code"].number == 401 {
                    myAccount.delete()
                    self.window = UIWindow()
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let initialVC = storyboard.instantiateViewController(withIdentifier: "logintop")
                    self.window?.rootViewController = initialVC
                    self.window?.makeKeyAndVisible()
                }
            }
        }
        if !isLogged {
            self.window = UIWindow()
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let initialVC = storyboard.instantiateViewController(withIdentifier: "logintop")
            self.window?.rootViewController = initialVC
            self.window?.makeKeyAndVisible()
        }
        Navigator.scheme="imast"
        Navigator.routes=["callback"]
        /*
        // DARK THEME
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName:UIColor.white
        ]
        UITabBar.appearance().barTintColor = .black
        UITableView.appearance().backgroundColor = .darkGray
        UIView.appearance(whenContainedInInstancesOf: [UITableViewController.self]).backgroundColor = .black
        UITableViewCell.appearance().backgroundColor = .black
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = .white
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).backgroundColor = .black
        UITextView.appearance().backgroundColor = .black
        UITextView.appearance().textColor = .white
        */
        
        return true
    }
    
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let location = Navigator.parse(url: url) else {
            return false
        }
        
        let arguments = location.arguments
        let params = urlComponentsToDict(url: url)
        
        switch location.path { // Nintendo Switch
            case "callback":
                if params["code"] == nil {
                    break
                }
                self.window = UIWindow()
                let nextVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "progress") as! AddAccountProgressViewController
                nextVC.isCallback = true
                nextVC.app = MastodonApp.initFromId(appId: params["state"]!)
                nextVC.instance = nextVC.app?.instance
                nextVC.app?.authorizeWithCode(code: params["code"]!).then { usertoken in
                    nextVC.userToken = usertoken
                    self.window?.makeKeyAndVisible()
                }
                self.window?.rootViewController = nextVC
            default:break
        }
        return true
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
    func registerDefaultsFromSettingsBundle(){
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
            print("migrating:",key)
        }
        UserDefaultsAppGroup.set(true, forKey: migrateKeyName)
        UserDefaultsAppGroup.synchronize()
        print("UserDefaults migrated!")
    }

}


func openVLC(_ url: String) -> Bool{
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
