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
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let warnAttrString = NSMutableAttributedString()
        warnAttrString.append(NSAttributedString(string: "ログインすると、\n"))
        warnAttrString.append(NSAttributedString(string: "利用規約", attributes: [
            .link: "https://\(app?.instance.hostName ?? "mstdn.jp")/about/more",
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
        ]))
        warnAttrString.append(NSAttributedString(string: "及び"))
        warnAttrString.append(NSAttributedString(string: "プライバシーポリシー", attributes: [
            .link: "https://\(app?.instance.hostName ?? "mstdn.jp")/terms",
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
        ]))
        warnAttrString.append(NSAttributedString(string: "\nに同意したことになります。"))
        warnAttrString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: warnAttrString.length))

        warnView.attributedText = warnAttrString
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goMailAddressAndPasswordLogin" {
            let nextVC = segue.destination as! AddAccountLoginViewController
            nextVC.app = self.app
        }
    }
    
    private var loginSafari: LoginSafari?
    
    @IBAction func safariLoginButton(_ sender: Any) {
        let url = URL(string: self.app!.getAuthorizeUrl())!
        if #available(iOS 11.0, *) {
            self.loginSafari = LoginSafari11()
        } else {
            self.loginSafari = LoginSafariNormal()
        }
        self.loginSafari?.open(url: url, viewController: self)
    }
}



