//
//  AddAccountSelectLoginMethodViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/23.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SafariServices
import Eureka

class AddAccountSelectLoginMethodViewController: FormViewController {
    
    var app: MastodonApp!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "認証"
        
        let methodsSection = Section()
        methodsSection <<< ButtonRow { row in
            row.title = "Safariでログインする (推奨)"
            row.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = nil
            }
            row.onCellSelection { cell, row in
                self.safariLoginButton()
            }
        }
        methodsSection <<< ButtonRow { row in
            row.title = "メールアドレスとパスワードでログインする"
            row.presentationMode = .show(controllerProvider: .callback(builder: {
                let vc = AddAccountLoginViewController()
                vc.title = row.title
                vc.app = self.app
                return vc
            }), onDismiss: nil)
        }
        
        let tosSection = Section("ログインすると、このインスタンスの以下の規約に同意したことになります。")
        tosSection <<< ButtonRow { row in
            row.title = "利用規約"
            row.cellStyle = .subtitle
            let url = "https://\(self.app.instance.hostName)/about/more"
            row.cellUpdate { cell, row in
                cell.detailTextLabel?.text = url
            }
            row.presentationMode = .presentModally(controllerProvider: .callback(builder: { SFSafariViewController(url: URL(string: url)!) }), onDismiss: nil)
        }
        tosSection <<< ButtonRow { row in
            row.title = "プライバシーポリシー"
            row.cellStyle = .subtitle
            let url = "https://\(self.app.instance.hostName)/terms"
            row.cellUpdate { cell, row in
                cell.detailTextLabel?.text = url
            }
            row.presentationMode = .presentModally(controllerProvider: .callback(builder: { SFSafariViewController(url: URL(string: url)!) }), onDismiss: nil)
        }
        
        self.form += [
            methodsSection,
            tosSection,
        ]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickLoginHelpButton(_ sender: Any) {
        alert(
            title: R.string.login.loginMethodHelpTitle(),
            message: R.string.login.loginMethodHelpMessage()
        )
    }
    
    private var loginSafari: LoginSafari?
    
    func safariLoginButton() {
        let url = URL(string: self.app!.getAuthorizeUrl())!
        if #available(iOS 11.0, *) {
            self.loginSafari = LoginSafari11()
        } else {
            self.loginSafari = LoginSafariNormal()
        }
        self.loginSafari?.open(url: url, viewController: self)
    }
}
