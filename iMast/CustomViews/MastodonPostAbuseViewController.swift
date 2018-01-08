//
//  MastodonPostAbuseViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/08/04.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON

class MastodonPostAbuseViewController: UIViewController {

    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    var nowKeyboardUpOrDown = false
    var placeholder = ""
    var targetPost:JSON!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeholderLabel.text = self.placeholder

        configureObserver()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configureObserver() {
        let notification = NotificationCenter.default
        // notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeObserver() {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        bottomLayout.constant = (rect?.size.height ?? 0) - 100
        self.view.layoutIfNeeded()
        nowKeyboardUpOrDown = true
        placeholderLabel.alpha = 0
    }
    @objc func keyboardWillHide(notification: Notification?) {
        bottomLayout.constant = -50
        placeholderLabel.alpha = textView.text.count == 0 ? 1 : 0
        nowKeyboardUpOrDown = false
    }
    @IBAction func submitButtonTapped(_ sender: Any) {
        MastodonUserToken.getLatestUsed()!.post("reports", params: [
            "account_id": targetPost["account"]["id"],
            "comment": self.textView.text,
            "status_ids": [targetPost["id"]]
        ]).then { (res) in
            self.alertWithPromise(title: "送信完了", message: "通報が完了しました！").then {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
