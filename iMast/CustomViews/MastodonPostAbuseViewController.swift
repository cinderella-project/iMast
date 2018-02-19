//
//  MastodonPostAbuseViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/08/04.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Eureka
import ActionClosurable

class MastodonPostAbuseViewController: FormViewController {

    var placeholder = ""
    var targetPost:MastodonPost!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "通報"
        
        self.form +++ Section()
            <<< TextAreaRow() {
                $0.tag = "text"
                $0.placeholder = self.placeholder
                $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
        }
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "送信", style: .done) { _ in
                let text = (self.form.rowBy(tag: "text") as? TextAreaRow)?.value ?? ""
                self.submitButtonTapped(text: text)
            }
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitButtonTapped(text: String) {
        MastodonUserToken.getLatestUsed()!.reports(account: self.targetPost.account, comment: text, posts: [targetPost]).then { (res) in
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
