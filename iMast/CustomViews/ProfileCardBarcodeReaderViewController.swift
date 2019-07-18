//
//  ProfileCardBarcodeReaderViewController.swift
//  iMast
//
//  Created by user on 2017/10/26.
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
import AVFoundation
import SafariServices

class ProfileCardBarcodeReaderViewController: UIViewController {

    let ui2videoOrientation = [
        UIInterfaceOrientation.portrait: AVCaptureVideoOrientation.portrait,
        UIInterfaceOrientation.portraitUpsideDown: AVCaptureVideoOrientation.portraitUpsideDown,
        UIInterfaceOrientation.landscapeLeft: AVCaptureVideoOrientation.landscapeLeft,
        UIInterfaceOrientation.landscapeRight: AVCaptureVideoOrientation.landscapeRight,
    ]
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        do {
            let captureSession = AVCaptureSession()
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            let captureInput = try AVCaptureDeviceInput.init(device: captureDevice!)
            captureSession.addInput(captureInput)
            
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = [
                AVMetadataObject.ObjectType.qr,
            ]
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = self.view.bounds
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if let orientation = ui2videoOrientation[UIApplication.shared.statusBarOrientation] {
                previewLayer.connection?.videoOrientation = orientation
            }
            
            self.view.layer.addSublayer(previewLayer)
            captureSession.startRunning()
        } catch {
            self.navigationController?.popViewController(animated: true)
            self.alert(title: "カメラエラー", message: "メッセージ: \(error.localizedDescription)\n\n他のアプリでカメラが利用できるか確認してください。\niOSの設定→iMastから、カメラの利用を許可しているか確認してください。")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: nil, animation: nil) { _ in
            if let orientation = self.ui2videoOrientation[UIApplication.shared.statusBarOrientation] {
                self.previewLayer.connection?.videoOrientation = orientation
                self.previewLayer.frame = self.view.bounds
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

extension ProfileCardBarcodeReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if self.presentedViewController != nil || self.navigationController?.topViewController != self {
            return
        }
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            print(metadata.type)
            if metadata.type != AVMetadataObject.ObjectType.qr {
                continue
            }
            if metadata.stringValue == nil {
                continue
            }
            let alert = UIAlertController(title: "検知", message: metadata.stringValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "プロフィールを表示", style: .default, handler: { action in
                guard let urlencoded = metadata.stringValue/* ?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) */ else {
                    return
                }
                print(urlencoded)
                let loadingAlert = UIAlertController(title: "取得中", message: "取得中です...", preferredStyle: .alert)
                self.present(loadingAlert, animated: true, completion: nil)
                MastodonUserToken.getLatestUsed()!.search(q: urlencoded, resolve: true).then { res in
                    print(res)
                    if res.accounts.count == 0 {
                        loadingAlert.dismiss(animated: false) {
                            self.alert(title: "エラー", message: "指定されたアカウントが見つかりませんでした。\nユーザーが存在しない、ユーザーのアカウントがあるインスタンスがあなたのインスタンスと鎖国状態にある、ユーザーのアカウントがあるインスタンスがダウンしているなどが考えられます。")
                        }
                    }
                    if res.accounts.count == 1 {
                        let newVC = openUserProfile(user: res.accounts[0])
                        loadingAlert.dismiss(animated: false) {
                            self.navigationController?.pushViewController(newVC, animated: true)
                        }
                    }
                    if res.accounts.count >= 2 {
                        loadingAlert.dismiss(animated: false) {
                            let alert = UIAlertController(title: "選択", message: "複数のユーザーが見つかりました。どのユーザーを表示しますか?", preferredStyle: .alert)
                            for account in res.accounts {
                                alert.addAction(UIAlertAction(title: "@"+account.acct, style: .default, handler: { action in
                                    let newVC = openUserProfile(user: account)
                                    self.navigationController?.pushViewController(newVC, animated: true)
                                }))
                            }
                            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { action in
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }))
            if (metadata.stringValue?.hasPrefix("http://"))! || (metadata.stringValue?.hasPrefix("https://"))! {
                alert.addAction(UIAlertAction(title: "Safariで表示", style: .default, handler: { action in
                    let url = URL(string: metadata.stringValue!)
                    if url == nil {
                        return
                    }
                    let safari = SFSafariViewController(url: url!)
                    self.present(safari, animated: true, completion: nil)
                }))
            }
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { action in
                // なんもせえへん
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
