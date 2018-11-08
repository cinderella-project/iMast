//
//  AddAccountLoginViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import OnePasswordExtension

class AddAccountLoginViewController: UIViewController {

    @IBOutlet weak var mailAddressInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var callPasswordManagerButton: UIButton!
    var app: MastodonApp?
    var userToken: MastodonUserToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.callPasswordManagerButton.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()
        
        let onePassBundle = Bundle(for: OnePasswordExtension.self)
        let onePassResourceBundle = Bundle(path: onePassBundle.bundlePath + "/OnePasswordExtensionResources.bundle")
        let buttonImage = UIImage(named: "onepassword-button", in: onePassResourceBundle!, compatibleWith: nil)
        self.callPasswordManagerButton.setImage(buttonImage?.withRenderingMode(.alwaysTemplate), for: .normal)
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
    @IBAction func loginButtonTapped(_ sender: Any) {
        if mailAddressInput.text == nil {
            alert(title: "エラー", message: "メールアドレスを入力してください")
            return
        }
        if passwordInput.text == nil {
            alert(title: "エラー", message: "パスワードを入力してください")
            return
        }
        if app == nil {
            error(errorMsg: "appがnilです(AddAccountLoginViewController)")
            return
        }
        app!.authorizeWithPassword(email: mailAddressInput.text!, password: passwordInput.text!).then { userToken in
            self.userToken = userToken
            self.performSegue(withIdentifier: "backToProgress", sender: self)
        }.catch { (error) -> Void in
            print(error)
            do {
                throw error
            } catch APIError.errorReturned (let e) {
                self.apiError(e.errorMessage, e.errorHttpCode)
            } catch APIError.unknownResponse (let e) {
                self.apiError(nil, e)
            } catch {
                self.apiError(nil, nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToProgress" {
            let nextVC = segue.destination as! AddAccountProgressViewController
            nextVC.app = app
            nextVC.userToken = userToken
            nextVC.start3 = true
        }
    }
    @IBAction func callPasswordManager(_ sender: Any) {
        OnePasswordExtension.shared().findLogin(forURLString: "https://" + self.app!.instance.hostName, for: self, sender: sender) { (dict, error) in
            if let error = error {
                print(error)
                return
            }
            guard let dict = dict else { return }
            if let mailAddress = dict[AppExtensionUsernameKey] as? String {
                self.mailAddressInput.text = mailAddress
            }
            if let password = dict[AppExtensionPasswordKey] as? String {
                self.passwordInput.text = password
            }
        }
    }
}
