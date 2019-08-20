//
//  NewPostViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/28.
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
import Hydra
import SwiftyJSON
import MediaPlayer

class NewPostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textInput: UITextView! {
        didSet {
            textInput.delegate = self
        }
    }
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    @IBOutlet weak var keyboardUpOrDown: UIBarButtonItem!
    @IBOutlet weak var cwInput: UITextField!
    var media: [UploadableMedia] = []
    
    @IBOutlet weak var nowAccountLabel: UILabel!
    
    var nowKeyboardUpOrDown: Bool = false
    var isNSFW: Bool = false {
        didSet {
            self.NSFWButton.style = isNSFW ? UIBarButtonItem.Style.done : UIBarButtonItem.Style.plain
        }
    }
    var scope = "public" {
        didSet {
            _ = VisibilityString.firstIndex(of: scope)! // 意図しないものが指定されたらクラッシュさせる
            scopeSelectButton.image = UIImage(named: "visibility-"+scope)
        }
    }
    var replyToPost: MastodonPost?
    
    var isPNG = true
    var isModal = false
    @IBOutlet weak var NSFWButton: UIBarButtonItem!
    @IBOutlet weak var scopeSelectButton: UIBarButtonItem!
    var userToken: MastodonUserToken!
    
    var appendBottomString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nowAccountLabel.text = userToken.acct
        if let replyToPost = replyToPost {
            self.nowAccountLabel.text! += "\n返信先: @\(replyToPost.account.acct): \(replyToPost.status.pregReplace(pattern: "<.+?>", with: ""))"
            var replyAccounts = [replyToPost.account.acct]
            replyToPost.mentions.forEach { mention in
                replyAccounts.append(mention.acct)
            }
            replyAccounts = replyAccounts.filter({ (acct) -> Bool in
                return acct != userToken.screenName
            }).map({ (acct) -> String in
                return "@\(acct) "
            })
            self.textInput.text = replyAccounts.joined()
            self.scope = replyToPost.visibility
        }
        if Defaults[.usingDefaultVisibility] && replyToPost == nil {
            userToken.getUserInfo(cache: true).then { res in
                let myScope = res["source"]["privacy"].string ?? "public"
                self.scope = myScope
            }
        }
        self.textInput.becomeFirstResponder()
        let nowCount = self.textInput.text.count
        DispatchQueue.main.async {
            self.textInput.selectedRange.location = nowCount
        }
        self.textInput.text += appendBottomString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureObserver()
        self.nowAccountLabel.sizeToFit()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func sendPost(_ sender: Any) {
        print(isNSFW)
        let baseMessage = "しばらくお待ちください\n"
        let alert = UIAlertController(title: "投稿中", message: baseMessage + "準備中", preferredStyle: UIAlertController.Style.alert)
        present(alert, animated: true, completion: nil)
        
        let uploadPromise = async { _ -> [JSON] in
            var imageJSONs: [JSON] = []
            for (index, medium) in self.media.enumerated() {
                DispatchQueue.main.async {
                    alert.message = baseMessage + "画像アップロード中(\(index+1)/\(self.media.count))"
                }
                let response = try await(self.userToken.upload(file: medium.toUploadableData(), mimetype: medium.getMimeType()))
                if response["_response_code"].intValue >= 400 {
                    throw APIError.errorReturned(errorMessage: response["error"].stringValue, errorHttpCode:  response["_response_code"].intValue)
                }
                if !response["id"].exists() {
                    throw APIError.nil("id")
                }

                imageJSONs.append(response)
            }
            return imageJSONs
        }
        
        uploadPromise.then { (medias) -> Promise<JSON> in
            DispatchQueue.main.async {
                alert.message = baseMessage + "送信中"
            }
            print(medias)
            var text = self.textInput.text ?? ""
            let mediaIds = medias.map({ (media) in
                return media["id"]
            })
            if Defaults[.appendMediaUrl] {
                var mediaUrls = ""
                medias.filter({ (media) -> Bool in
                    return media["text_url"].string != nil
                }).forEach({ (media) in
                    mediaUrls += " " + media["text_url"].stringValue
                })
                if (text.count + mediaUrls.count) <= 500 {
                    text += mediaUrls
                }
            }
            var params: [String: Any] = [
                "media_ids": mediaIds,
                "sensitive": self.isNSFW || (self.cwInput.text != nil && self.cwInput.text != ""),
                "spoiler_text": self.cwInput.text ?? "",
                "status": text,
                "visibility": self.scope,
            ]
            if let replyToPost = self.replyToPost {
                params["in_reply_to_id"] = replyToPost.id.raw
            }
            return self.userToken.post("statuses", params: params)
        }.then { res in
            if res["_response_code"].intValue >= 400 {
                alert.dismiss(animated: false, completion: {
                    self.apiError(res["error"].string, res["_response_code"].int)
                })
                return
            }
            self.textInput.text = ""
            alert.dismiss(animated: false, completion: {
                self.navigationController?.popViewController(animated: true)
            })
            if self.isModal {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }.catch { err in
            DispatchQueue.main.async {
                alert.dismiss(animated: false, completion: {
                    self.alert(title: "エラー", message: "エラーが発生しました。\(err)")
                })
            }
        }
    }
    func configureObserver() {
        let notification = NotificationCenter.default
        // notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObserver() {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        bottomLayout.constant = (rect?.size.height ?? 0) - self.bottomLayoutGuide.length
        self.view.layoutIfNeeded()
        self.keyboardUpOrDown.image = UIImage(named: "ArrowDown")
        nowKeyboardUpOrDown = true
    }
    @objc func keyboardWillHide(notification: Notification?) {
        bottomLayout.constant = 0.0
        self.keyboardUpOrDown.image = UIImage(named: "ArrowUp")
        nowKeyboardUpOrDown = false
    }
    @IBAction func keyboardUpOrDownTapped(_ sender: Any) {
        if !nowKeyboardUpOrDown {
            self.textInput.becomeFirstResponder()
        } else {
            self.textInput.resignFirstResponder()
        }
    }
    @IBAction func nsfwButtonTapped(_ sender: Any) {
        isNSFW = !isNSFW
    }
    @IBAction func nowPlayingTapped(_ sender: Any) {
        let nowPlayingMusic = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        if nowPlayingMusic == nil {
            return
        }
        if nowPlayingMusic!.title == nil {
            return
        }
        var nowPlayingText = Defaults[.nowplayingFormat]
        nowPlayingText = nowPlayingText.replace("{title}", nowPlayingMusic!.title ?? "")
        nowPlayingText = nowPlayingText.replace("{artist}", nowPlayingMusic!.artist ?? "")
        nowPlayingText = nowPlayingText.replace("{albumArtist}", nowPlayingMusic!.albumArtist ?? "")
        nowPlayingText = nowPlayingText.replace("{albumTitle}", nowPlayingMusic!.albumTitle ?? "")
        
        self.textInput.text += nowPlayingText
    }
    @IBAction func scopeSelectButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "公開範囲", message: "公開範囲を選択してください。", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = self.scopeSelectButton
        for i in 0..<VisibilityString.count {
            alert.addAction(UIAlertAction(title: VisibilityLocalizedString[i], style: .default, handler: { (action) in
                self.scope = VisibilityString[i]
            }))
        }
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var imageSelectButton: UIButton!
    @IBAction func imageSelectButtonTapped(_ sender: UIButton) {
        let contentVC = NewPostMediaListViewController(newPostVC: self)
        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = CGSize(width: 500, height: 100)
        contentVC.popoverPresentationController?.sourceView = imageSelectButton
        contentVC.popoverPresentationController?.sourceRect = imageSelectButton.frame
        contentVC.popoverPresentationController?.permittedArrowDirections = .down
        contentVC.popoverPresentationController?.delegate = self
        self.present(contentVC, animated: true, completion: nil)
    }
}

extension NewPostViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
