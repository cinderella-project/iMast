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
import Alamofire
import iMastiOSCore

class NewPostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textInput: UITextView! {
        didSet {
            textInput.delegate = self
        }
    }
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var keyboardUpOrDown: UIBarButtonItem!
    @IBOutlet weak var cwInput: UITextField!
    var media: [UploadableMedia] = []
    
    @IBOutlet weak var nowAccountLabel: UILabel!
    @IBOutlet weak var exactOnepixelConstraint: NSLayoutConstraint!
    
    var nowKeyboardUpOrDown: Bool = false
    var isNSFW: Bool = false {
        didSet {
            self.NSFWButton.style = isNSFW ? UIBarButtonItem.Style.done : UIBarButtonItem.Style.plain
        }
    }
    var scope = MastodonPostVisibility.public {
        didSet {
            scopeSelectButton.image = scope.uiImage
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
        navigationItem.largeTitleDisplayMode = .never
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
        if Defaults.usingDefaultVisibility && replyToPost == nil {
            asyncPromise { try await self.userToken.getUserInfo(cache: true) }.then { res in
                if let myScope = MastodonPostVisibility(rawValue: res["source"]["privacy"].string ?? "public") {
                    self.scope = myScope
                }
            }
        }
        self.textInput.becomeFirstResponder()
        let nowCount = self.textInput.text.nsLength
        DispatchQueue.main.async {
            self.textInput.selectedRange.location = nowCount
        }
        self.textInput.text += appendBottomString
        exactOnepixelConstraint.constant = 1 /  UIScreen.main.scale
        addKeyCommand(.init(title: "投稿", action: #selector(sendPost(_:)), input: "\r", modifierFlags: .command, discoverabilityTitle: "投稿を送信"))
        // localize
        cwInput.placeholder = L10n.NewPost.Placeholders.cwWarningText
        scopeSelectButton.menu = UIMenu(title: "", children: MastodonPostVisibility.allCases.map { visibility in
            return UIAction(title: visibility.localizedName, image: visibility.uiImage, state: .off) { [weak self] _ in
                self?.scope = visibility
            }
        })
        
        additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 44, right: 0)
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
        let alert = UIAlertController(
            title: L10n.NewPost.Alerts.Sending.title,
            message: baseMessage + "準備中",
            preferredStyle: UIAlertController.Style.alert
        )
        present(alert, animated: true, completion: nil)
        
        let text = textInput.text ?? ""
        let isSensitive = isNSFW || (cwInput.text != nil && cwInput.text != "")
        let spoilerText = cwInput.text ?? ""
        let scope = scope
        
        asyncPromise {
            var media: [JSON] = []
            for (index, medium) in self.media.enumerated() {
                await MainActor.run {
                    alert.message = baseMessage + L10n.NewPost.Alerts.Sending.Steps.mediaUpload(index+1, self.media.count)
                }
                let response = try await self.userToken.upload(file: medium.toUploadableData(), mimetype: medium.getMimeType()).wait()
                if response["_response_code"].intValue >= 400 {
                    throw APIError.errorReturned(
                        errorMessage: response["error"].stringValue,
                        errorHttpCode: response["_response_code"].intValue
                    )
                }
                if !response["id"].exists() {
                    throw APIError.nil("id")
                }
                media.append(response)
            }
            await MainActor.run {
                alert.message = baseMessage + L10n.NewPost.Alerts.Sending.Steps.send
            }
            print(media)
            let res = try await MastodonEndpoint.CreatePost(
                status: text,
                visibility: scope,
                mediaIds: media.map { .init(string: $0["id"].stringValue) },
                spoiler: spoilerText,
                sensitive: isSensitive,
                inReplyToPost: self.replyToPost
            ).request(with: self.userToken)
        }.then(in: .main) {
            self.clearContent()
            alert.dismiss(animated: false, completion: {
                if self.navigationController is ModalNavigationViewController {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }.catch(in: .main) { err in
            alert.dismiss(animated: false) {
                self.alert(title: L10n.Localizable.Error.title, message: "エラーが発生しました。\(err)")
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
        self.view.layoutIfNeeded()
        self.keyboardUpOrDown.image = UIImage(systemName: "chevron.down")
        nowKeyboardUpOrDown = true
        guard let rect = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        guard let window = view.window else {
            return
        }
        let globalRect = view.convert(view.bounds, to: window)
        let safeAreaBottom = view.safeAreaInsets.bottom - additionalSafeAreaInsets.bottom
        let modalBottom = window.bounds.maxY - globalRect.maxY
        let windowBottom = (window.screen.bounds.height - window.bounds.height) / 2
        let bottom = safeAreaBottom + modalBottom + windowBottom
        additionalSafeAreaInsets.bottom = (rect.size.height - bottom) + 44
    }
    @objc func keyboardWillHide(notification: Notification?) {
        additionalSafeAreaInsets.bottom = 44
        self.keyboardUpOrDown.image = UIImage(systemName: "chevron.up")
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
        switch MPMediaLibrary.authorizationStatus() {
        case .denied:
            self.alert(
                title: L10n.Localizable.Error.title,
                message: L10n.NewPost.Errors.declineAppleMusicPermission
            )
            return
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { [weak self, sender] status in
                DispatchQueue.main.async {
                    self?.nowPlayingTapped(sender)
                }
            }
            return
        case .restricted:
            self.alert(title: "よくわからん事になりました", message: "もしよければ、このアラートがどのような条件で出たか、以下のコードを添えて @imast_ios@mstdn.rinsuki.net までお知らせください。\ncode: MPMediaLibraryAuthorizationStatus is restricted")
            return
        case .authorized:
            break
        @unknown default:
            self.alert(title: "よくわからん事になりました", message: "もしよければ、このアラートがどのような条件で出たか、以下のコードを添えて @imast_ios@mstdn.rinsuki.net までお知らせください。\ncode: MPMediaLibraryAuthorizationStatus is unknown value")
            return
        }
        guard let nowPlayingMusic = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else { return }
        if nowPlayingMusic.title == nil {
            return
        }
        var nowPlayingText = Defaults.nowplayingFormat
        nowPlayingText = nowPlayingText.replacingOccurrences(of: "{title}", with: nowPlayingMusic.title ?? "")
        nowPlayingText = nowPlayingText.replacingOccurrences(of: "{artist}", with: nowPlayingMusic.artist ?? "")
        nowPlayingText = nowPlayingText.replacingOccurrences(of: "{albumArtist}", with: nowPlayingMusic.albumArtist ?? "")
        nowPlayingText = nowPlayingText.replacingOccurrences(of: "{albumTitle}", with: nowPlayingMusic.albumTitle ?? "")
        
        func finished(_ text: String) {
            self.textInput.insertText(text)
        }

        func checkAppleMusic() -> Bool {
            guard Defaults.nowplayingAddAppleMusicUrl else { return false }
            let storeId = nowPlayingMusic.playbackStoreID
            guard storeId != "0" else { return false }
            let region = Locale.current.regionCode ?? "jp"
            var request = URLRequest(url: URL(string: "https://itunes.apple.com/lookup?id=\(storeId)&country=\(region)&media=music")!)
            request.timeoutInterval = 1.5
            request.addValue(UserAgentString, forHTTPHeaderField: "User-Agent")
            Alamofire.request(request).responseData { [finished] res in
                var text = nowPlayingText
                do {
                    switch res.result {
                    case .success(let data):
                        let json = try JSON(data: data)
                        if let url = json["results"][0]["trackViewUrl"].string {
                            text += " " + url + " "
                        }
                    case .failure(let error):
                        throw error
                    }
                } catch {
                    print(error)
                }
                finished(text)
            }
            return true
        }
        if !checkAppleMusic() {
            finished(nowPlayingText)
        }
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
    
    func clearContent() {
        cwInput.text = ""
        textInput.text = ""
        media = []
        imageSelectButton.setTitle(" 0", for: .normal)
        isNSFW = false
        if Defaults.usingDefaultVisibility && replyToPost == nil {
            asyncPromise { try await self.userToken.getUserInfo(cache: true) }.then { res in
                if let myScope = MastodonPostVisibility(rawValue: res["source"]["privacy"].string ?? "public") {
                    self.scope = myScope
                }
            }
        } else {
            scope = .public
        }
    }
}

extension NewPostViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
