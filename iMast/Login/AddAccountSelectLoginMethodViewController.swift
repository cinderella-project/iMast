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
        
        let warnAttrString = NSMutableAttributedString(string: R.string.login.loginMethodAcceptTermsTitle())
        let hostName = app?.instance.hostName ?? "mstdn.jp"
        if let r = warnAttrString.mutableString.range(of: "{tos}").optional {
            warnAttrString.replaceCharacters(in: r, with: NSAttributedString(string: R.string.login.loginMethodAcceptTermsTerms(), attributes: [
                .link: "https://\(hostName)/about/more",
                .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
            ]))
        }
        if let r = warnAttrString.mutableString.range(of: "{privacyPolicy}").optional {
            warnAttrString.replaceCharacters(in: r, with: NSAttributedString(string: R.string.login.loginMethodAcceptTermsPrivacyPolicy(), attributes: [
                .link: "https://\(hostName)/terms",
                .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
            ]))
        }
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



