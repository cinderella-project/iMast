//
//  ShareNewPostViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/08/01.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

import UIKit
import Mew
import iMastiOSCore
import Fuzi
import MobileCoreServices
import SDWebImage

class ShareNewPostViewController: UIViewController, Instantiatable, UITextViewDelegate {
    typealias Input = Void
    typealias Environment = MastodonUserToken

    var environment: MastodonUserToken
    
    required init(with input: Void, environment: MastodonUserToken) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var contentView: ShareNewPostView!

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
    
    var appendBottomString: String = ""
    
    override func loadView() {
        contentView = .init()
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // --- contentView への魂入れ
        contentView.textInput.delegate = self
        contentView.imageSelectButton.addTarget(self, action: #selector(imageSelectButtonTapped(_:)), for: .touchUpInside)
        contentView.nsfwSwitchItem.target = self
        contentView.nsfwSwitchItem.action = #selector(nsfwButtonTapped(_:))
        contentView.scopeSelectItem.menu = UIMenu(title: "", children: MastodonPostVisibility.allCases.map { visibility in
            return UIAction(title: visibility.localizedName, image: visibility.uiImage, state: .off) { [weak self] _ in
                self?.scope = visibility
            }
        })
        
        contentView.currentAccountLabel.text = environment.acct
        navigationItem.largeTitleDisplayMode = .never
        title = L10n.NewPost.title

        if Defaults.usingDefaultVisibility {
            setVisibilityFromUserInfo()
        }

        contentView.textInput.becomeFirstResponder()
        addKeyCommand(.init(title: "投稿", action: #selector(sendPost(_:)), input: "\r", modifierFlags: .command, discoverabilityTitle: "投稿を送信"))
        
        navigationItem.rightBarButtonItems = [
            .init(title: L10n.NewPost.send, style: .done, target: self, action: #selector(sendPost(_:))),
        ]
        
        additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 44, right: 0)
        configureObserver()
        
        contentView.imageSelectButton.isEnabled = false
        
        viewDidLoad_shareExtension()
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
        submitPost(alert)
    }
    
    func submitPost(_ alert: UIAlertController) {
        let baseMessage = L10n.NewPost.Alerts.Sending.pleaseWait+"\n"
        let text = contentView.textInput.text ?? ""
        let isSensitive = isNSFW || (contentView.cwInput.text != nil && contentView.cwInput.text != "")
        let spoilerText = contentView.cwInput.text ?? ""
        let scope = scope
        SDImageCache.shared.clearMemory() // 画像アップロードの処理の前にキャッシュをクリアしておく (メモリ不足回避のため)
        
        asyncPromise {
            var media: [MastodonAttachment] = []
            for (index, medium) in self.media.enumerated() {
                await MainActor.run {
                    alert.message = baseMessage + L10n.NewPost.Alerts.Sending.Steps.mediaUpload(index+1, self.media.count)
                }
                let response = try await MastodonEndpoint.UploadMediaV1(
                    file: medium.toUploadableData(),
                    mimeType: medium.getMimeType()
                ).request(with: self.environment)
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
                sensitive: isSensitive
            ).request(with: self.environment)
            await MainActor.run {
                alert.message = "\n" + L10n.NewPost.Alerts.Sending.Steps.done
            }
            try await Task.sleep(nanoseconds: 1 * 1000 * 1000)
        }.then(in: .main) {
            alert.dismiss(animated: false, completion: {
                self.extensionContext?.completeRequest(returningItems: nil)
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
    
    @objc func imageSelectButtonTapped(_ sender: UIButton) {
//        let contentVC = NewPostMediaListViewController(newPostVC: self)
//        contentVC.modalPresentationStyle = .popover
//        contentVC.preferredContentSize = CGSize(width: 500, height: 100)
//        contentVC.popoverPresentationController?.sourceView = contentView.imageSelectButton
//        contentVC.popoverPresentationController?.sourceRect = contentView.imageSelectButton.frame
//        contentVC.popoverPresentationController?.permittedArrowDirections = .down
//        contentVC.popoverPresentationController?.delegate = self
//        self.present(contentVC, animated: true, completion: nil)
    }
    
    func setVisibilityFromUserInfo() {
        Task { @MainActor in
            let res = try await self.environment.getUserInfo(cache: true)
            if let myScope = MastodonPostVisibility(rawValue: res.source?.privacy ?? "public") {
                self.scope = myScope
            }
        }
    }
    
    // Share Extension specific implementation
    var firstURLFinished = false
}

// Share Extension specific implementation
extension ShareNewPostViewController {
    func viewDidLoad_shareExtension() {
        let itemHandlers: [CFString: NSItemProvider.CompletionHandler] = [
            kUTTypeURL: self.processUrl,
            kUTTypeImage: self.processImage,
        ]

        for inputItem in self.extensionContext!.inputItems as! [NSExtensionItem] {
            #if DEBUG
            print("inputItem", inputItem)
            #endif
            if let text = inputItem.attributedContentText?.string {
                contentView.textInput.text = text
            }
            for itemProvider in inputItem.attachments ?? [] {
                #if DEBUG
                print("itemProvider", itemProvider)
                #endif
                for (uti, handler) in itemHandlers {
                    if itemProvider.hasItemConformingToTypeIdentifier(uti as String) {
                        itemProvider.loadItem(forTypeIdentifier: uti as String, options: nil, completionHandler: handler)
                    }
                }
            }
        }
    }
    
    func processUrl(item: NSSecureCoding?, error: Error?) {
        if let error = error {
            self.extensionContext!.cancelRequest(withError: error)
            return
        }
        guard var url = item as? NSURL else {
            return
        }
        if url.scheme == "file" {
            return
        }
        let query = urlComponentsToDict(url: url as URL)
        
        // Twitterトラッキングを蹴る
        if Defaults.shareNoTwitterTracking, url.host?.hasSuffix("twitter.com") ?? false {
            var urlComponents = URLComponents(string: url.absoluteString!)!
            urlComponents.queryItems = (urlComponents.queryItems ?? []).filter({$0.name != "ref_src" && $0.name != "s" && $0.name != "t"})
            if (urlComponents.queryItems ?? []).count == 0 {
                urlComponents.query = nil
            }
            let urlString = (urlComponents.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
            url = NSURL(string: urlString)!
        }
        if Defaults.shareNoSpotifySIParameter, url.host == "open.spotify.com" {
            var urlComponents = URLComponents(string: url.absoluteString!)!
            urlComponents.queryItems = (urlComponents.queryItems ?? []).filter({$0.name != "si"})
            if (urlComponents.queryItems ?? []).count == 0 {
                urlComponents.query = nil
            }
            let urlString = (urlComponents.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
            url = NSURL(string: urlString)!
        }
        var postUrl = url.absoluteString
        
        // Twitter共有の引き継ぎ
        if url.host == "twitter.com" && url.path == "/intent/tweet" {
            var twitterPostText: String = ""
            if let text = query["text"] {
                twitterPostText += text
            }
            if let url = query["url"] {
                twitterPostText += " " + url
            }
            if let hashtags = query["hashtags"] {
                hashtags.components(separatedBy: ",").forEach { hashtag in
                    twitterPostText += " #" + hashtag
                }
            }
            if let via = query["via"] {
                twitterPostText += " https://twitter.com/\(via) さんから"
            }
            postUrl = nil
            DispatchQueue.main.sync {
                firstURLFinished = true
                contentView.textInput.text = twitterPostText
            }
        }
        
        // なうぷれ対応
        processSpotifyURL(url: url)
        
        if let postUrl = postUrl {
            DispatchQueue.main.sync {
                guard !firstURLFinished else {
                    return
                }
                firstURLFinished = true
                contentView.textInput.text += "\n" + postUrl
            }
        }
    }

    func processSpotifyURL(url: NSURL) {
        if Defaults.usingNowplayingFormatInShareSpotifyUrl,
            url.scheme == "https", url.host == "open.spotify.com",
            let path = url.path, path.starts(with: "/track/"),
            let objectId = path.firstMatch(of: /^\/track\/(.+)$/)?.output.1,
            let previewUrl = URL(string: "https://open.spotify.com/embed/track/\(objectId)")
        {
            var request = URLRequest(url: previewUrl)
            request.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
            Task { [request] in
                let result = try await URLSession.shared.data(for: request)
                guard let doc = try? Fuzi.HTMLDocument.parse(data: result.0) else {
                    print("SpotifyNowPlayingError: Fuzi.HTMLDocumentでパースに失敗")
                    return
                }
                guard let trackElement = doc.xpath("//*[@id='resource']").first else {
                    print("SpotifyNowPlayingError: script#resourceがなかった")
                    return
                }
                
                struct SpotifyArtist: Codable {
                    var name: String
                }
                
                struct SpotifyAlbum: Codable {
                    var name: String
                    var artists: [SpotifyArtist]
                }
                
                struct SpotifyTrack: Codable {
                    var name: String
                    var album: SpotifyAlbum
                    var artists: [SpotifyArtist]
                }
                
                let decoder = JSONDecoder()
                let track = try decoder.decode(SpotifyTrack.self, from: trackElement.stringValue.data(using: .utf8)!)

                let nowPlayingText = Defaults.nowplayingFormat
                    .replacingOccurrences(of: "{title}", with: track.name)
                    .replacingOccurrences(of: "{artist}", with: track.artists.map { $0.name }.joined(separator: ", "))
                    .replacingOccurrences(of: "{albumTitle}", with: track.album.name)
                    .replacingOccurrences(of: "{albumArtist}", with: track.album.artists.map { $0.name }.joined(separator: ", "))
                await MainActor.run {
                    self.contentView.textInput.text = nowPlayingText
                }
            }
        }
    }
    
    func processImage(item: NSSecureCoding?, error: Error?) {
        if let error = error {
            self.extensionContext!.cancelRequest(withError: error)
            return
        }
        let media: UploadableMedia?
        if let imageData = item as? Data {
            media = UploadableMedia(format: .png, data: imageData, url: nil, thumbnailImage: UIImage(data: imageData)!)
        } else if let imageUrl = item as? NSURL {
            print(imageUrl)
            if imageUrl.isFileURL, let data = try? Data(contentsOf: imageUrl as URL) {
                media = UploadableMedia(format: (imageUrl.pathExtension ?? "").lowercased() == "png" ? .png : .jpeg, data: data, url: nil, thumbnailImage: UIImage(data: data)!)
            } else {
                media = nil
            }
        } else if let image = item as? UIImage {
            media = UploadableMedia(format: .png, data: image.pngData()!, url: nil, thumbnailImage: image)
        } else {
            media = nil
        }
        if let media {
            DispatchQueue.main.async {
                self.media.append(media)
            }
        }
    }
}
