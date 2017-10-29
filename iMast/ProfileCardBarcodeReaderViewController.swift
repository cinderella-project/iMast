//
//  ProfileCardBarcodeReaderViewController.swift
//  iMast
//
//  Created by user on 2017/10/26.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import AVFoundation

class ProfileCardBarcodeReaderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        do {
            let captureSession = AVCaptureSession()
            let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let captureInput = try AVCaptureDeviceInput.init(device: captureDevice)
            captureSession.addInput(captureInput)
            
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)!
            previewLayer.frame = self.view.bounds
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            self.view.layer.addSublayer(previewLayer)
            captureSession.startRunning()
        } catch {
            self.navigationController?.popViewController(animated: true)
            self.alert(title: "カメラエラー", message: "メッセージ: "+error.localizedDescription+"\n\n他のアプリでカメラが利用できるか確認してください。\niOSの設定→iMastから、カメラの利用を許可しているか確認してください。")
        }
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
