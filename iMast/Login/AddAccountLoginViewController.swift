//
//  AddAccountLoginViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit

class AddAccountLoginViewController: UIViewController {

    @IBOutlet weak var mailAddressInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    var app: MastodonApp?
    var userToken: MastodonUserToken?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        }.catch { (error) -> (Void) in
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
}
