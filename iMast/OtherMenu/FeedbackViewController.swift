//
//  FeedbackViewController.swift
//  iMast
//
//  Created by user on 2018/10/10.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import UIKit
import Eureka
import Alamofire

class FeedbackViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let versionString = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)+"(\((Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)))"
        let tar = TextAreaRow { row in
            row.placeholder = "Feedbackの内容をお書きください"
            row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
        }
        self.form +++ Section()
            <<< tar
        self.form +++ Section("Feedbackを送信すると、以下の情報も一緒に送信され、iMastの改善に役立てられます。")
            <<< LabelRow {
                $0.title = "iMastのバージョン"
                $0.value = versionString
            }
            <<< LabelRow {
                $0.title = "iOSのバージョン"
                $0.value = UIDevice.current.systemVersion
            }
            <<< LabelRow {
                $0.title = "端末名"
                $0.value = UIDevice.current.platform
        }
        self.form +++ Section()
            <<< ButtonRow {
                $0.title = "送信"
                }.onCellSelection({ (cell, row) in
                    if (tar.value ?? "") == "" {
                        self.alert(title: "エラー", message: "Feedbackの内容を入力してください")
                        return
                    }
                    let postBody = [
                        "body": tar.value ?? "",
                        "app_version": versionString,
                        "ios_version": UIDevice.current.systemVersion,
                        "device_name": UIDevice.current.platform,
                    ]
                    Alamofire.request("https://imast-backend.rinsuki.net/old-api/feedback", method: .post, parameters: postBody).responseJSON { request in
                        if (request.response?.statusCode ?? 0) >= 400 {
                            self.alert(title: "通信エラー", message: "通信に失敗しました。(HTTP-\((request.response?.statusCode ?? 599)))\nしばらく待ってから、もう一度送信してみてください。\nFeedbackは@imast_ios@imastodon.netへのリプライでも受け付けています。")
                        }
                        if request.error != nil {
                            self.alert(title: "通信エラー", message: "通信に失敗しました。\nしばらく待ってから、もう一度送信してみてください。\nFeedbackは@imast_ios@imastodon.netへのリプライでも受け付けています。")
                            return
                        }
                        self.navigationController?.popViewController(animated: true)
                        self.alert(title: "送信しました!", message: "Feedbackありがとうございました。")
                    }
                })
        self.title = "Feedback"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
