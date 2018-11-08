//
//  AddAccountProgressViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/23.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import SwiftyJSON

class AddAccountProgressViewController: UIViewController {
    
    var hostName: String = ""
    var maxIndex: Int = 4
    @IBOutlet weak var nowText: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    var app: MastodonApp?
    var userToken: MastodonUserToken?
    var start3 = false
    var instance: MastodonInstance?
    var userRes: JSON?
    var isCallback: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startLogin()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setHost(_ host: String) {
        hostName = host
    }

    func nowStateSet(_ nowIndex: Int, _ nowText: String) {
        self.nowText.text = nowText
        progressView.progress = Float(nowIndex) / Float(maxIndex)
        progressLabel.text = String(nowIndex) + " / " + String(maxIndex)
    }
    
    func startLogin() {
        if isCallback || start3 {
            stage4()
        } else {
            stage1()
        }
    }
    func stage1() {
        nowStateSet(1, R.string.login.authStage1())
        instance = MastodonInstance(hostName: hostName)
        instance!.getInfo().then { _ in
            self.stage2()
        }.catch { (error) -> Void in
            do {
                throw error
            } catch {
                self.apiErrorWithPromise(error.localizedDescription, -2).then {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    func stage2() {
        nowStateSet(2, R.string.login.authStage2())
        let appName = Defaults[.newAccountVia]
        print(appName)
        let instance = MastodonInstance(hostName: hostName)
        instance.createApp(name: appName).then { app in
            self.app = app
            self.app!.save()
            self.stage3()
        }.catch { (error) -> Void in
                do {
                    throw error
                } catch {
                    self.apiErrorWithPromise(error.localizedDescription, -2).then {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
        }
    }
    func stage3() {
        nowStateSet(3, R.string.login.authStage3())
        performSegue(withIdentifier: "goSelectLoginMethod", sender: self)
    }
    
    func stage4() {
        if userToken == nil {
            error(errorMsg: "userTokenがnilです(AddAccountProgressViewController)")
            performSegue(withIdentifier: "errorBack", sender: self)
            return
        }
        nowStateSet(4, R.string.login.authStage4())
        userToken!.getUserInfo().then {json in
            self.userToken!.save()
            self.userToken!.use()
            if let error = json["error"].string {
                self.alert(title: "APIエラー", message: error+"\nアプリを再起動してやり直してみてください。")
                return
            }
            self.userRes = json
            self.performSegue(withIdentifier: "goSuccess", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goSelectLoginMethod" {
            let nextVC = segue.destination as! AddAccountSelectLoginMethodViewController
            nextVC.app = app
        }
        if segue.identifier == "goSuccess" {
            let nextVC = segue.destination as! AddAccountSuccessViewController
            nextVC.userToken = self.userToken
            nextVC.userRes = self.userRes
        }
    }
    
}
