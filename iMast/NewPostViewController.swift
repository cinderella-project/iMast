//
//  NewPostViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/28.
//  Copyright © 2017年 rinsuki. All rights reserved.
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
    @IBOutlet weak var cwInput: UITextField! {
        didSet {
            cwInput.isHidden = true
        }
    }
    @IBOutlet weak var backgroundImage: UIImageView!
    var image: UIImage? = nil {
        didSet {
            self.backgroundImage.image = image
        }
    }
    @IBOutlet weak var nowAccountLabel: UILabel!
    
    var nowKeyboardUpOrDown: Bool = false
    var isCW: Bool = false {
        didSet {
            self.CWButton.style = isCW ? UIBarButtonItemStyle.done : UIBarButtonItemStyle.plain
        }
    }
    var isNSFW: Bool = false {
        didSet {
            self.NSFWButton.style = isNSFW ? UIBarButtonItemStyle.done : UIBarButtonItemStyle.plain
        }
    }
    var scope = "public" {
        didSet {
            _ = VisibilityString.index(of: scope)! // 意図しないものが指定されたらクラッシュさせる
            scopeSelectButton.image = UIImage(named: "visibility-"+scope)
        }
    }
    var replyToPost: JSON?
    
    var isPNG = true
    @IBOutlet weak var CWButton: UIBarButtonItem!
    @IBOutlet weak var NSFWButton: UIBarButtonItem!
    @IBOutlet weak var scopeSelectButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureObserver()
        self.nowAccountLabel.text = (MastodonUserToken.getLatestUsed()?.screenName)! + "@" + (MastodonUserToken.getLatestUsed()?.app.instance.hostName)!
        if replyToPost != nil {
            self.nowAccountLabel.text! += "\n返信先: @\(replyToPost!["account"]["username"].stringValue): \(replyToPost!["content"].stringValue.pregReplace(pattern: "<.+?>", with: ""))"
            var replyAccounts = [replyToPost!["account"]["acct"].stringValue]
            replyToPost!["mentions"].arrayValue.forEach { mention in
                replyAccounts.append(mention["acct"].stringValue)
            }
            replyAccounts = replyAccounts.filter({ (acct) -> Bool in
                return acct != MastodonUserToken.getLatestUsed()?.screenName
            }).map({ (acct) -> String in
                return "@"+acct+" "
            })
            self.textInput.text = replyAccounts.joined()
            self.scope = replyToPost!["visibility"].stringValue
        }
        self.nowAccountLabel.sizeToFit()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func sendPost(_ sender: Any) {
        print(isNSFW)
        print(isCW)
        let alert = UIAlertController(title: "投稿中", message: "しばらくお待ちください", preferredStyle: UIAlertControllerStyle.alert)
        present(alert, animated: true, completion: nil)
        
        var uploadPromise: Promise<[JSON]>
        if image != nil {
            uploadPromise = MastodonUserToken.getLatestUsed()!.upload(file: getImage()!, mimetype: "image/png").then { (response) -> [JSON] in
                if response["_response_code"].intValue >= 400 {
                    alert.dismiss(animated: false, completion: {
                        self.apiError(response["error"].string, response["_response_code"].int)
                    })
                    throw APIError.alreadyError()
                }
                return response["id"].exists() ? [response] : []
            }
        } else {
            uploadPromise = Promise.init(resolved: [])
        }
        uploadPromise.then { (medias) -> Promise<JSON> in
            print(medias)
            var text = self.textInput.text ?? ""
            let mediaIds = medias.map({ (media) in
                return media["id"]
            })
            if UserDefaults.standard.bool(forKey: "append_mediaurl") {
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
                "media_ids":mediaIds,
                "sensitive": self.isNSFW,
                "spoiler_text": self.isCW ? self.cwInput.text ?? "" : "",
                "status": text,
                "visibility": self.scope
            ]
            if self.replyToPost != nil {
                params["in_reply_to_id"] = self.replyToPost!["id"]
            }
            return MastodonUserToken.getLatestUsed()!.post("statuses",params: params)
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
        }.catch { err in
            alert.dismiss(animated: false, completion: {
                self.alert(title: "謎のエラー", message: "謎のエラーが発生しました。")
            })
        }
    }
    func configureObserver() {
        let notification = NotificationCenter.default
        // notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeObserver() {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        bottomLayout.constant = (rect?.size.height ?? 0) - self.bottomLayoutGuide.length
        self.view.layoutIfNeeded()
        self.keyboardUpOrDown.image = UIImage(named: "ArrowDown")
        nowKeyboardUpOrDown = true
    }
    func keyboardWillHide(notification: Notification?) {
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
    @IBAction func cwButtonTapped(_ sender: Any) {
        isCW = !isCW
        cwInput.isHidden = !isCW
        if isCW {
            textInput.textContainerInset.top += 30
        } else {
            textInput.textContainerInset.top -= 30
        }
    }
    @IBAction func nowPlayingTapped(_ sender: Any) {
        let nowPlayingMusic = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem
        if nowPlayingMusic == nil {
            return
        }
        if nowPlayingMusic!.title == nil {
            return
        }
        var nowPlayingText = UserDefaults.standard.string(forKey: "nowplaying_format") ?? "#nowplaying {title} - {artist} ({albumTitle})"
        nowPlayingText = nowPlayingText.replace("{title}", nowPlayingMusic!.title ?? "")
        nowPlayingText = nowPlayingText.replace("{artist}", nowPlayingMusic!.artist ?? "")
        nowPlayingText = nowPlayingText.replace("{albumArtist}", nowPlayingMusic!.albumArtist ?? "")
        nowPlayingText = nowPlayingText.replace("{albumTitle}", nowPlayingMusic!.albumTitle ?? "")
        
        self.textInput.text = self.textInput.text + nowPlayingText
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
    func getImage() -> Data? { // 自動リサイズ設定を考慮したUIImageをPNGorJPEG化したDataを返す
        var image = self.image!
        let resultSize = UserDefaults.standard.exists(UserDefaultsName.autoResizeSize.rawValue) ? UserDefaults.standard.integer(forKey: UserDefaultsName.autoResizeSize.rawValue) : 0
        if resultSize != 0 {
            var width = image.size.width
            var height = image.size.height
            if image.size.width > image.size.height { // 横長
                if image.size.width > CGFloat(resultSize) { // リサイズする必要がある
                    height = height / (width / CGFloat(resultSize))
                    width = CGFloat(resultSize)
                }
            } else if image.size.width < image.size.height { // 縦長
                if image.size.width > CGFloat(resultSize) { // リサイズする必要がある
                    width = width / (height / CGFloat(resultSize))
                    height = CGFloat(resultSize)
                }
            } else { // 正方形
                width = CGFloat(resultSize)
                height = CGFloat(resultSize)
            }
            print(width, height)
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            image = newImage!
        }
        return (self.isPNG ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, 1.0))
    }
}

