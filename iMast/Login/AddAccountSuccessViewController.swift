//
//  AddAccountSuccessViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/25.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class AddAccountSuccessViewController: UIViewController {

    @IBOutlet weak var myIconImageView: UIImageView!
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    var userToken: MastodonUserToken?
    var userRes: JSON?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userRes == nil {
            error(errorMsg: "userResがありません(AddAccountSuccessViewController)")
            return
        }
        if userRes!["username"].string == nil {
            error(errorMsg: "userRes.usernameがありません(AddAccountSuccessViewController)")
            return
        }
        welcomeMessageLabel.text = welcomeMessageLabel.text?.replace("%", userRes!["username"].stringValue)
        self.myIconImageView.sd_setImage(with: URL(string: userRes!["avatar_static"].stringValue))
        self.myIconImageView.ignoreSmartInvert()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func goTimelineTapped(_ sender: Any) {
        changeRootVC(MainTabBarController(), animated: true)
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
