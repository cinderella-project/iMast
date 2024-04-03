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
import SwiftUI
import Combine
import Hydra
import MediaPlayer
import iMastiOSCore

// YOU PROBABLY WANT TO ALSO MODIFY ShareNewPostViewController, which is subset of NewPostViewController.

class NewPostViewController: UIViewController, UITextViewDelegate, ObservableObject {
    var contentView: NewPostView!
    var viewModel: NewPostViewModel
    var cancellables = Set<AnyCancellable>()
    var mediaVC: NewPostMediaListViewController?

    var editPost: (post: MastodonPost, source: MastodonPostSource)?
//    var replyToPost: MastodonPost?
    
    var userToken: MastodonUserToken!
    
    init(userActivity: NSUserActivity) {
        viewModel = .init()
        super.init(nibName: nil, bundle: nil)
        viewModel.alertPresenter = self
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
        contentView.nowPlayingItem.target = viewModel
        contentView.nowPlayingItem.action = #selector(viewModel.insertNowPlayingInfo)
        contentView.scopeSelectItem.menu = UIMenu(title: "", children: MastodonPostVisibility.allCases.map { visibility in
            return UIAction(title: visibility.localizedName, image: visibility.uiImage, state: .off) { [weak self] _ in
                self?.viewModel.visibility = visibility
            }
        })

        viewModel.$visibility
            .prepend(viewModel.visibility)
            .receive(on: DispatchQueue.main)
            .sink { [weak contentView] scope in
                contentView?.scopeSelectItem.image = scope.uiImage
            }
            .store(in: &cancellables)

        viewModel.$isNSFW
            .prepend(viewModel.isNSFW)
            .receive(on: DispatchQueue.main)
            .sink { [weak contentView] isNSFW in
                contentView?.nsfwSwitchItem.image = .init(systemName: isNSFW ? "eye.slash" : "eye")
            }
            .store(in: &cancellables)
        
        viewModel.$media
            .prepend(viewModel.media)
            .receive(on: DispatchQueue.main)
            .sink { [weak contentView] media in
                // TODO: なんかこれでもアニメーションしてしまうのを防ぐ
                UIView.performWithoutAnimation {
                    contentView?.imageSelectButton.setTitle(" \(media.count)", for: .normal)
                }
            }
            .store(in: &cancellables)
        
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
            viewModel.visibility = scope
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
            
            viewModel.visibility = editPost.post.visibility
            contentView.scopeSelectItem.isEnabled = false

            viewModel.isNSFW = editPost.post.sensitive
        }

        contentView.textInput.becomeFirstResponder()

        if let userActivity {
            if let newPostCurrentText = userActivity.newPostCurrentText {
                contentView.textInput.text = newPostCurrentText
            }
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
        
        #if os(visionOS)
        let mediaVC = NewPostMediaListViewController(viewModel: viewModel, inline: true)
        contentView.stackView.addArrangedSubview(mediaVC.view)
        addChild(mediaVC)
        self.mediaVC = mediaVC
        viewModel.$media
            .prepend(viewModel.media)
            .receive(on: DispatchQueue.main)
            .sink {
                mediaVC.view.isHidden = $0.count == 0
            }
            .store(in: &cancellables)
        
        struct OrnamentView: View {
            @StateObject var viewModel: NewPostViewModel
            
            var body: some View {
                HStack {
                    Button {
                        viewModel.alertPresenter?.mediaVC?.addFromPhotoLibrary()
                    } label: {
                        Image(systemName: "photo")
                        Text("\(viewModel.media.count)")
                    }

                    
                    Toggle(isOn: $viewModel.isNSFW) {
                        Image(systemName: viewModel.isNSFW ? "eye.slash" : "eye" )
                    }
                    .toggleStyle(.button)
                    .help("NSFW (Current: \(viewModel.isNSFW ? "ON" : "OFF"))")

                    Menu {
                        ForEach(MastodonPostVisibility.allCases) { v in
                            Button {
                                viewModel.visibility = v
                            } label: {
                                Label {
                                    Text(v.localizedName)
                                } icon: {
                                    Image(systemName: v.sfSymbolsName)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.visibility.sfSymbolsName)
                            .aspectRatio(1, contentMode: .fit)
                    }
                    .menuStyle(.borderlessButton)
                    .help("Visibility (Current: \(viewModel.visibility.localizedName))")

                    Divider()

                    Button {
                        viewModel.insertNowPlayingInfo()
                    } label: {
                        Image(systemName: "music.note")
                    }
                    .help("Insert NowPlaying")
                }
                .padding()
                .buttonStyle(.borderless)
                .glassBackgroundEffect()
            }
        }
        
        let ornament = UIHostingOrnament(sceneAnchor: .bottom, contentAlignment: .center) {
            OrnamentView(viewModel: self.viewModel)
        }
        
        ornaments = [ornament]
        
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func sendPost(_ sender: Any) {
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
        let isSensitive = viewModel.isNSFW || (contentView.cwInput.text != nil && contentView.cwInput.text != "")
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
        let isSensitive = viewModel.isNSFW || (contentView.cwInput.text != nil && contentView.cwInput.text != "")
        let spoilerText = contentView.cwInput.text ?? ""
        let scope = viewModel.visibility
        
        asyncPromise {
            var media: [MastodonAttachment] = []
            for (index, medium) in self.viewModel.media.enumerated() {
                await MainActor.run {
                    alert.message = baseMessage + L10n.NewPost.Alerts.Sending.Steps.mediaUpload(index+1, self.viewModel.media.count)
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
        viewModel.isNSFW.toggle()
    }
    
    @objc func imageSelectButtonTapped(_ sender: UIButton) {
        let contentVC = NewPostMediaListViewController(viewModel: viewModel, inline: false)
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
        
        let contentVC = NewPostMediaListViewController(viewModel: viewModel, inline: false)
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
        viewModel.media = []
        viewModel.isNSFW = false
        if Defaults.usingDefaultVisibility {
            setVisibilityFromUserInfo()
        } else {
            viewModel.visibility = .public
        }
    }
    
    func setVisibilityFromUserInfo() {
        Task { @MainActor in
            let res = try await self.userToken.getUserInfo(cache: true)
            if let myScope = MastodonPostVisibility(rawValue: res.source?.privacy ?? "public") {
                viewModel.visibility = myScope
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
