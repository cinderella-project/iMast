//
//  ProfileCardViewController.swift
//  iMast
//
//  Created by user on 2017/10/23.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import CoreImage
import SwiftyJSON

class ProfileCardViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var barcodeImageView: UIImageView!
    var user: MastodonAccount!
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
