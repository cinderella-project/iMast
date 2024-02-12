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
import MediaPlayer
import iMastiOSCore

// YOU PROBABLY WANT TO ALSO MODIFY ShareNewPostViewController, which is subset of NewPostViewController.

class NewPostViewController: UIViewController, UITextViewDelegate {
    var contentView: NewPostView!

    @MainActor var media: [UploadableMedia] = [] {
        didSet {
            // TODO: なんかこれでもアニメーションしてしまうのを防ぐ
            UIView.performWithoutAnimation {
                contentView.imageSelectButton.setTitle(" \(media.count)", for: .normal)
            }
        }
    }
    var isNSFW: Bool = false {
        didSet {
            contentView.nsfwSwitchItem.image = isNSFW ? .init(systemName: "eye.slash") : .init(systemName: "eye")
        }
    }
    var scope = MastodonPostVisibility.public {
        didSet {
            contentView.scopeSelectItem.image = scope.uiImage
        }
    }
    var editPost: (post: MastodonPost, source: MastodonPostSource)?
//    var replyToPost: MastodonPost?
    
    var userToken: MastodonUserToken!
    
    init(userActivity: NSUserActivity) {
        super.init(nibName: nil, bundle: nil)
        self.userActivity = userActivity
        self.userToken = userActivity.mastodonUserToken()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        contentView = .init()
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // --- contentView への魂入れ
        contentView.textInput.delegate = self
        contentView.imageSelectButton.addTarget(self, action: #selector(imageSelectButtonTapped(_:)), for: .touchUpInside)
        contentView.imageSelectButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(openImagePickerDirectly(_:))))
        contentView.nsfwSwitchItem.target = self
        contentView.nsfwSwitchItem.action = #selector(nsfwButtonTapped(_:))
        contentView.nowPlayingItem.target = self
        contentView.nowPlayingItem.action = #selector(nowPlayingTapped(_:))
        contentView.scopeSelectItem.menu = UIMenu(title: "", children: MastodonPostVisibility.allCases.map { visibility in
            return UIAction(title: visibility.localizedName, image: visibility.uiImage, state: .off) { [weak self] _ in
                self?.scope = visibility
            }
        })
        
        contentView.currentAccountLabel.text = userToken.acct
        navigationItem.largeTitleDisplayMode = .never
        if let userActivity, let replyPostID = userActivity.newPostReplyPostID, let replyPostAcct = userActivity.newPostReplyPostAcct {
            let replyPostText = userActivity.newPostReplyPostText ?? ""
            contentView.currentAccountLabel.text! += "\n返信先: @\(replyPostAcct): \(replyPostText.toPlainText().replacingOccurrences(of: "\n", with: " "))"
            title = L10n.NewPost.reply
        } else {
            title = L10n.NewPost.title
        }

        if let scope = MastodonPostVisibility(rawValue: userActivity?.newPostVisibility ?? "") {
            self.scope = scope
        } else if Defaults.usingDefaultVisibility && editPost == nil {
            setVisibilityFromUserInfo()
        }

        if let editPost = editPost {
            title = L10n.NewPost.edit

            contentView.textInput.text = editPost.source.text
            contentView.cwInput.text = editPost.source.spoilerText

            // TODO: 添付メディアの編集にも対応する
            contentView.imageSelectButton.setTitle(" \(editPost.post.attachments.count)", for: .normal)
            contentView.imageSelectButton.isEnabled = false
            
            scope = editPost.post.visibility
            contentView.scopeSelectItem.isEnabled = false

            isNSFW = editPost.post.sensitive
        }

        contentView.textInput.becomeFirstResponder()

        if let userActivity {
            contentView.textInput.text = userActivity.newPostCurrentText ?? ""
            // メンションとかの後を選択する
            let nowCount = contentView.textInput.text.nsLength
            DispatchQueue.main.async {
                self.contentView.textInput.selectedRange.location = nowCount
            }
            contentView.textInput.text += userActivity.newPostSuffix ?? ""
        }

        addKeyCommand(.init(title: "投稿", action: #selector(sendPost(_:)), input: "\r", modifierFlags: .command, discoverabilityTitle: "投稿を送信"))
        
        navigationItem.rightBarButtonItems = [
            .init(title: L10n.NewPost.send, style: .done, target: self, action: #selector(sendPost(_:))),
        ]
        
        additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 44, right: 0)
        configureObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func sendPost(_ sender: Any) {
        print(isNSFW)
        let baseMessage = L10n.NewPost.Alerts.Sending.pleaseWait+"\n"
        let alert = UIAlertController(
            title: L10n.NewPost.Alerts.Sending.title,
            message: baseMessage + "準備中",
            preferredStyle: UIAlertController.Style.alert
        )
        present(alert, animated: true, completion: nil)
        if editPost != nil {
            submitEdit(alert)
        } else {
            submitPost(alert)
        }
    }
    
    func submitEdit(_ alert: UIAlertController) {
        let baseMessage = L10n.NewPost.Alerts.Sending.pleaseWait+"\n"
        guard let editPost else {
            preconditionFailure()
        }
        let text = contentView.textInput.text ?? ""
        let isSensitive = isNSFW || (contentView.cwInput.text != nil && contentView.cwInput.text != "")
        let spoilerText = contentView.cwInput.text ?? ""

        Task {
            do {
                let request = MastodonEndpoint.EditPost(
                    postID: editPost.post.id,
                    status: text,
                    mediaIds: editPost.post.attachments.map { $0.id },
                    sensitive: isSensitive,
                    spoiler: spoilerText
                )
                await MainActor.run {
                    alert.message = baseMessage + L10n.NewPost.Alerts.Sending.Steps.send
                }
                let response = try await request.request(with: userToken)
                try await MainActor.run {
                    try userToken.memoryStore.post.change(obj: response)
                    alert.dismiss(animated: false, completion: {
                        if let modalNVC = self.navigationController as? ModalNavigationViewController {
                            modalNVC.closeAsCommit()
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            } catch {
                await MainActor.run {
                    alert.dismiss(animated: false) {
                        self.errorReport(error: error)
                    }
                }
            }
        }
    }
    
    func submitPost(_ alert: UIAlertController) {
        let baseMessage = L10n.NewPost.Alerts.Sending.pleaseWait+"\n"
        let text = contentView.textInput.text ?? ""
        let isSensitive = isNSFW || (contentView.cwInput.text != nil && contentView.cwInput.text != "")
        let spoilerText = contentView.cwInput.text ?? ""
        let scope = scope
        
        asyncPromise {
            var media: [MastodonAttachment] = []
            for (index, medium) in self.media.enumerated() {
                await MainActor.run {
                    alert.message = baseMessage + L10n.NewPost.Alerts.Sending.Steps.mediaUpload(index+1, self.media.count)
                }
                let response = try await MastodonEndpoint.UploadMediaV1(file: medium.toUploadableData(), mimeType: medium.getMimeType()).request(with: self.userToken)
                media.append(response)
            }
            await MainActor.run {
                alert.message = baseMessage + L10n.NewPost.Alerts.Sending.Steps.send
            }
            print(media)
            let res = try await MastodonEndpoint.CreatePost(
                status: text,
                visibility: scope,
                mediaIds: media.map { $0.id },
                spoiler: spoilerText,
                sensitive: isSensitive,
                inReplyToPostID: self.userActivity.flatMap { $0.newPostReplyPostID }
            ).request(with: self.userToken)
        }.then(in: .main) {
            self.clearContent()
            alert.dismiss(animated: false, completion: {
                if let modalNVC = self.navigationController as? ModalNavigationViewController {
                    modalNVC.closeAsCommit()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }.catch(in: .main) { err in
            alert.dismiss(animated: false) {
                self.errorReport(error: err)
            }
        }
    }
    func configureObserver() {
        let notification = NotificationCenter.default
        // notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        #if !os(visionOS)
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        #endif
    }
    
    #if !os(visionOS)
    @objc func keyboardWillShow(notification: Notification?) {
        self.view.layoutIfNeeded()
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
        additionalSafeAreaInsets.bottom = max(rect.size.height - bottom, 0) + 44
    }
    @objc func keyboardWillHide(notification: Notification?) {
        additionalSafeAreaInsets.bottom = 44
    }
    #endif

    @objc func nsfwButtonTapped(_ sender: Any) {
        isNSFW = !isNSFW
    }
    @objc func nowPlayingTapped(_ sender: Any) {
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
            contentView.textInput.insertText(text)
        }

        func checkAppleMusic() -> Bool {
            guard Defaults.nowplayingAddAppleMusicUrl else { return false }
            let storeId = nowPlayingMusic.playbackStoreID
            guard storeId != "0" else { return false }
            let region = Locale.current.regionCode ?? "jp"
            var request = URLRequest(url: URL(string: "https://itunes.apple.com/lookup?id=\(storeId)&country=\(region)&media=music")!)
            request.timeoutInterval = 1.5
            request.addValue(UserAgentString, forHTTPHeaderField: "User-Agent")
            Task { @MainActor in
                var text = nowPlayingText
                do {
                    let (data, res) = try await URLSession.shared.data(for: request)
                    struct SearchResultWrapper: Codable {
                        let results: [SearchResult]
                    }
                    struct SearchResult: Codable {
                        let trackViewUrl: URL
                    }
                    let result = try JSONDecoder().decode(SearchResultWrapper.self, from: data)
                    if let url = result.results.first?.trackViewUrl {
                        text += " " + url.absoluteString + " "
                    }
                } catch {
                    // nothing
                }
                finished(text)
            }
            return true
        }
        if !checkAppleMusic() {
            finished(nowPlayingText)
        }
    }
    
    @objc func imageSelectButtonTapped(_ sender: UIButton) {
        let contentVC = NewPostMediaListViewController(newPostVC: self)
        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = CGSize(width: 500, height: 100)
        contentVC.popoverPresentationController?.sourceView = contentView.imageSelectButton
        contentVC.popoverPresentationController?.sourceRect = contentView.imageSelectButton.frame
        contentVC.popoverPresentationController?.permittedArrowDirections = .down
        contentVC.popoverPresentationController?.delegate = self
        self.present(contentVC, animated: true, completion: nil)
    }
    
    @objc func openImagePickerDirectly(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let contentVC = NewPostMediaListViewController(newPostVC: self)
        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = CGSize(width: 500, height: 100)
        contentVC.popoverPresentationController?.sourceView = contentView.imageSelectButton
        contentVC.popoverPresentationController?.sourceRect = contentView.imageSelectButton.frame
        contentVC.popoverPresentationController?.permittedArrowDirections = .down
        contentVC.popoverPresentationController?.delegate = self
        self.present(contentVC, animated: false) {
            contentVC.addFromPhotoLibrary()
        }
    }
    
    func clearContent() {
        contentView.cwInput.text = ""
        contentView.textInput.text = ""
        media = []
        isNSFW = false
        if Defaults.usingDefaultVisibility {
            setVisibilityFromUserInfo()
        } else {
            scope = .public
        }
    }
    
    func setVisibilityFromUserInfo() {
        Task { @MainActor in
            let res = try await self.userToken.getUserInfo(cache: true)
            if let myScope = MastodonPostVisibility(rawValue: res.source?.privacy ?? "public") {
                self.scope = myScope
            }
        }
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        if activity.activityType == NSUserActivity.activityTypeNewPost {
            print("TODO: restoration")
        }
    }
}

extension NewPostViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
