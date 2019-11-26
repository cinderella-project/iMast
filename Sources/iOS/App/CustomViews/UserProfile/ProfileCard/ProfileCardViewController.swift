//
//  ProfileCardViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/10/23.
//  
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2019 rinsuki and other contributors.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import CoreImage
import SwiftyJSON
import iMastiOSCore

class ProfileCardViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var barcodeImageView: UIImageView!
    var user: MastodonAccount!
    var userToken: MastodonUserToken!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.ignoreSmartInvert()
        
        // Do any additional setup after loading the view.
        self.backgroundImageView.sd_setImage(with: URL(string: user.headerUrl))
        self.iconView.sd_setImage(with: URL(string: user.avatarUrl))

        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: [
            "inputMessage": user.url.data(using: .utf8),
            "inputCorrectionLevel": "H",
        ])
        let invertQr = CIFilter(name: "CIColorInvert", parameters: [
            "inputImage": qr!.outputImage!,
            ])
        let alphaInvertQr = CIFilter(name: "CIMaskToAlpha", parameters: [
            "inputImage": invertQr!.outputImage!,
        ])
        let alphaQr = CIFilter(name: "CIColorInvert", parameters: [
            "inputImage": alphaInvertQr!.outputImage!,
        ])
        userNameLabel.text = user.name != "" ? user.name : user.screenName
        userScreenNameLabel.text = "@" + user.acct
        barcodeImageView.image = UIImage(ciImage: alphaQr!.outputImage!.transformed(by: CGAffineTransform(scaleX: 10, y: 10)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openBarcodeReader(_ sender: Any) {
        let vc = ProfileCardBarcodeReaderViewController.instantiate(environment: userToken)
        show(vc, sender: self)
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
