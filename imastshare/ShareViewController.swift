//
//  ShareViewController.swift
//  iMastShare
//
//  Created by rinsuki on 2017/06/07.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import Social
import Hydra
import SwiftyJSON

class ShareViewController: SLComposeServiceViewController {
    
    var isMastodonLogged = false
    var userToken = MastodonUserToken.getLatestUsed() {
        didSet {
            accountConfig.value = self.userToken!.screenName!+"@"+self.userToken!.app.instance.hostName
        }
    }
    var accountConfig = SLComposeSheetConfigurationItem()!
    var visibilityConfig = SLComposeSheetConfigurationItem()!
    var postUrl = ""
    var visibility = "public" {
        didSet {
            visibilityConfig.value = VisibilityLocalizedString[VisibilityString.index(of: visibility) ?? 0]
        }
    }
    var postImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Mastodonで共有"
        self.isMastodonLogged = self.userToken != nil
        if !self.isMastodonLogged {
            alertWithPromise(title: "エラー", message: "iMastにMastodonのアカウントが設定されていません。\niMastを起動してアカウントを登録してください。").then {
                self.cancel()
            }
            return
        }
        accountConfig.title = "アカウント"
        accountConfig.value = self.userToken!.screenName!+"@"+self.userToken!.app.instance.hostName
        accountConfig.tapHandler = {
            let VC = ShareAccountSelectorTableViewController()
            VC.nowUserTokenId = self.userToken!.id!
            VC.parentVC = self
            self.pushConfigurationViewController(VC)
        }
        visibilityConfig.title = "公開範囲"
        visibilityConfig.value = "公開"
        visibilityConfig.tapHandler = {
            let VC = ShareVisibilityTableViewController()
            VC.parentVC = self
            self.pushConfigurationViewController(VC)
        }
        (self.extensionContext!.inputItems[0] as! NSExtensionItem).attachments!.forEach({ (ip) in
            let itemProvider = ip as! NSItemProvider
            //
            print(itemProvider)
            if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (urlItem, error) in
                    if error != nil {
                        self.extensionContext!.cancelRequest(withError: error)
                        return
                    }
                    guard var url = urlItem as? NSURL else {
                        return
                    }
                    if url.scheme == "file" {
                        return
                    }
                    if Defaults[.shareNoTwitterTracking] && url.host?.hasSuffix("twitter.com") ?? false {
                        var urlComponents = URLComponents(string: url.absoluteString!)!
                        urlComponents.queryItems = (urlComponents.queryItems ?? []).filter({$0.name != "ref_src"})
                        if (urlComponents.queryItems ?? []).count == 0 {
                            urlComponents.query = nil
                        }
                        let urlString = (urlComponents.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                        url = NSURL(string: urlString)!
                    }
                    self.postUrl = url.absoluteString == nil ? "" : " "+url.absoluteString!
                    if url.host == "twitter.com" && url.path == "/intent/tweet" { // Twitter共有の引き継ぎ
                        let query = urlComponentsToDict(url: URL(string: url.absoluteString!)!)
                        var twitterPostText: String = ""
                        if query["text"] != nil {
                            twitterPostText += query["text"]!
                        }
                        if query["url"] != nil {
                            twitterPostText += " " + query["url"]!
                        }
                        if query["hashtags"] != nil {
                            query["hashtags"]!.components(separatedBy: ",").forEach { hashtag in
                                twitterPostText += " #" + hashtag
                            }
                        }
                        if query["via"] != nil {
                            twitterPostText += " https://twitter.com/\(query["via"]!)さんから"
                        }
                        DispatchQueue.main.sync() {
                            self.textView.text = twitterPostText
                            self.postUrl = ""
                        }
                    }
                }
            }
            if itemProvider.hasItemConformingToTypeIdentifier("public.image") {
                itemProvider.loadItem(forTypeIdentifier: "public.image", options: nil, completionHandler: { (imageItem, error) in
                    if error != nil {
                        self.extensionContext!.cancelRequest(withError: error)
                        return
                    }
                    if let image = imageItem as? UIImage {
                        self.postImage = image
                    }
                    if let imageUrl = imageItem as? NSURL {
                        print(imageUrl)
                        if(imageUrl.isFileURL) {
                            self.postImage = UIImage(contentsOfFile: imageUrl.path!)
                        }
                    }
                    if let imageData = imageItem as? Data {
                        self.postImage = UIImage(data: imageData)
                    }
                })
            }

        })
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        self.charactersRemaining = 500 - self.contentText.count - self.postUrl.count as NSNumber
        return Int(self.charactersRemaining) >= 0 && self.isMastodonLogged
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        let alert = UIAlertController(title: "投稿中", message: "しばらくお待ちください", preferredStyle: UIAlertControllerStyle.alert)
        present(alert, animated: true, completion: nil)
        var promise:Promise<[JSON]> = Promise.init(resolved: [])
        if self.postImage != nil {
            promise = userToken!.upload(file: UIImagePNGRepresentation(self.postImage!)!, mimetype: "image/png").then { (response) -> [JSON] in
                if response["_response_code"].intValue >= 400 {
                    throw APIError.errorReturned(errorMessage: response["error"].stringValue, errorHttpCode: response["_response_code"].intValue)
                }
                return response["id"].exists() ? [response] : []
            }
        }
        promise.then { images in
            self.userToken!.post("statuses",params: [
                "status": self.contentText + self.postUrl,
                "visibility": self.visibility,
                "media_ids": images.map({ (media) -> JSON in
                    return media["id"]
                })
            ]).then { res in
                alert.dismiss(animated: true)
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }
        }.catch { (error) -> (Void) in
            alert.dismiss(animated: false)
            var promise: Promise<Void>!
            do {
                throw error
            } catch APIError.errorReturned(let errorMessage, let errorHttpCode) {
                promise = self.apiErrorWithPromise(errorMessage, errorHttpCode)
            } catch {
                promise = self.apiErrorWithPromise("未知のエラーが発生しました。\n\(error.localizedDescription)", -1001)
            }
            promise.then {
                self.extensionContext!.cancelRequest(withError: error)
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [
            accountConfig,
            visibilityConfig
        ]
    }
}
