//
//  CreateSiriShortcutsViewController.swift
//  iMast
//
//  Created by user on 2018/12/10.
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
import Eureka
import IntentsUI

@available(iOS 12.0, *)
class CreateSiriShortcutsViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let mainSection = Section()
        mainSection <<< PushRow<MastodonUserToken>("account") { row in
            row.title = "投稿するアカウント"
            row.options = MastodonUserToken.getAllUserTokens()
            row.displayValueFor = { userToken in
                guard let userToken = userToken else {
                    return nil
                }
                return "\(userToken.acct) (\(userToken.app.name))"
            }
            row.value = row.options?.first
        }.onPresent { (form, vc) in
            vc.selectableRowSetup = { row in
                row.tag = row.selectableValue!.id
                row.cellStyle = .subtitle
            }
            vc.selectableRowCellUpdate = { cell, row in
                guard let userToken = row.selectableValue else {
                    return
                }
                cell.textLabel?.text = userToken.name
                cell.detailTextLabel?.text = "\(userToken.acct) (\(userToken.app.name))"
                if let url = URL(string: userToken.avatarUrl ?? "") {
                    cell.imageView?.sd_setImage(with: url, completed: { (_, _, _, _) in
                        cell.setNeedsLayout()
                    })
                }
            }
        }
        mainSection <<< TextAreaRow("text") { row in
            row.placeholder = "投稿内容を入力"
            row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
        }

        self.form +++ mainSection
        
        self.form +++ Section() <<< ButtonRow { row in
            row.title = "Add to Siri"
        }.onCellSelection { cell, row in
            let intent = TootIntent()
            guard let userToken = (self.form.rowBy(tag: "account") as? PushRow<MastodonUserToken>)?.value else {
                self.alert(title: "エラー", message: "投稿するアカウントを選択してください")
                return
            }
            guard let text = (self.form.rowBy(tag: "text") as? TextAreaRow)?.value else {
                self.alert(title: "エラー", message: "テキストを入力してください")
                return
            }
            intent.accountId = userToken.id
            intent.accountScreenName = userToken.screenName
            intent.accountHostName = userToken.app.instance.hostName
            intent.text = text
            if let shortcut = INShortcut(intent: intent) {
                let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                viewController.modalPresentationStyle = .formSheet
                viewController.delegate = self
                self.present(viewController, animated: true, completion: nil)
            }
        }
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

@available(iOS 12.0, *)
extension CreateSiriShortcutsViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
