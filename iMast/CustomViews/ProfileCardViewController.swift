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
    var user: JSON!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getImage(url: user["header_static"].stringValue).then { (image) in
            self.backgroundImageView.image = image
        }
        getImage(url: user["avatar_static"].stringValue).then { (image) in
            self.iconView.image = image
        }
        let qr = CIFilter(name: "CIQRCodeGenerator", withInputParameters: [
            "inputMessage": user["url"].stringValue.data(using: .utf8),
            "inputCorrectionLevel": "H"
        ])
        let invertQr = CIFilter(name: "CIColorInvert", withInputParameters: [
            "inputImage": qr!.outputImage!
            ])
        let alphaInvertQr = CIFilter(name: "CIMaskToAlpha", withInputParameters: [
            "inputImage": invertQr!.outputImage!
        ])
        let alphaQr = CIFilter(name: "CIColorInvert", withInputParameters: [
            "inputImage": alphaInvertQr!.outputImage!
        ])
        userNameLabel.text = (((user["display_name"].string ?? "") != "" ? user["display_name"].string : user["username"].string ?? "") ?? "")
        userScreenNameLabel.text = "@" + user["username"].stringValue + "@" + MastodonUserToken.getLatestUsed()!.app.instance.hostName
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
