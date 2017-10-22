//
//  AddAccountSelectLoginMethodViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/23.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SafariServices

class AddAccountSelectLoginMethodViewController: UIViewController, UITextViewDelegate{
    
    var app: MastodonApp?
    @IBOutlet weak var warnView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        warnView.attributedText = "ログインすると、<br><a href=\"https://\(app?.instance.hostName ?? "mstdn.jp")/about/more\">利用規約</a>及び<a href=\"https://\(app?.instance.hostName ?? "mstdn.jp")/terms\">プライバシーポリシー</a><br>に同意したことになります。<style>*{text-align:center;}</style>".parseText2HTML()
        warnView.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let safari = SFSafariViewController(url: URL)
        self.present(safari, animated: true, completion: nil)
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedRange.length != 0 {
            textView.selectedRange = NSRange()
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

    @IBAction func clickLoginHelpButton(_ sender: Any) {
        alert(
            title: "ログイン方法について",
            message: "通常は「Safariでログインする」を選択してください。\nSafariではうまくログインできない場合は「IDとパスワードでログインする」を選択してください。\n「IDとパスワードでログインする」はごく一部のインスタンスでは使えないことがあります。"
        )
    }
    @IBAction func safariLoginButton(_ sender: Any) {
        let safariVC = SFSafariViewController(url: URL(string: self.app!.getAuthorizeUrl())!)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goMailAddressAndPasswordLogin" {
            let nextVC = segue.destination as! AddAccountLoginViewController
            nextVC.app = self.app
        }
    }
}
