//
//  MastodonPostView.swift
//  iMast
//
//  Created by rinsuki on 2017/05/21.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import SafariServices

class MastodonPostCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var userView: UILabel!
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageThumbnailStackView: UIStackView!
    @IBOutlet weak var boostedUserIcon: UIImageView!
    @IBOutlet weak var tootInfoView: UIView!
    var json: JSON?
    
    func viewDidLayoutSubviews() {
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func load(post json_: JSON) {
        var json = json_
        if !json["reblog"].isEmpty {
            getImage(url: json["account"]["avatar_static"].stringValue).then { image in
                self.boostedUserIcon.image = image
            }
            self.tootInfoView.backgroundColor = UIColor.init(red: 0.1, green: 0.7, blue: 0.1, alpha: 1)
            json = json["reblog"]
        } else {
            self.tootInfoView.backgroundColor = nil
            self.boostedUserIcon.image = nil
        }
        self.json = json_
        // textView.dataDetectorTypes = .link
        var attrStr = (
            "<style>*{font-size:%.2fpx;font-family: sans-serif;padding:0;margin:0;}</style>".format(Defaults[DefaultsKeys.timelineTextFontsize])
                + (json["content"].stringValue.replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "").emojify(custom_emoji: json["emojis"].arrayValue, profile_emoji: json["profile_emojis"].arrayValue))).parseText2HTML()
        if json["spoiler_text"].string != "" && json["spoiler_text"].string != nil {
            textView.text = json["spoiler_text"].stringValue.emojify() + "\n(CWの内容は詳細画面で)"
            textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
            attrStr = nil
        } else if attrStr == nil {
            textView.text = (json["content"].string ?? "")
                .replace("<br />","\n")
                .replace("</p><p>","\n\n")
                .pregReplace(pattern: "\\<.+?\\>", with: "")
                .replace("&lt;", "<") // HTMLのエスケープを解く
                .replace("&gt;", ">")
                .replace("&apos;", "\"")
                .replace("&quot;", "'")
                .replace("&amp;", "&")
        } else {
            textView.attributedText = attrStr
        }
        textView.font = textView.font?.withSize(CGFloat(Defaults[.timelineTextFontsize]))
        userView.text = (((json["account"]["display_name"].string ?? "") != "" ? json["account"]["display_name"].string : json["account"]["username"].string ?? "") ?? "").emojify()
        userView.font = userView.font.withSize(CGFloat(Defaults[.timelineUsernameFontsize]))
        if (json["account"]["avatar_static"].string != nil) {
            var iconUrl = json["account"]["avatar_static"].stringValue
            if iconUrl.count >= 1 && iconUrl[iconUrl.startIndex] == "/" {
                iconUrl = "https://"+MastodonUserToken.getLatestUsed()!.app.instance.hostName+iconUrl
            }
            getImage(url: iconUrl,size: Int(self.iconView.frame.width)).then { image in
                self.iconView.image = image
            }
        }
        let date = json["created_at"].string?.toDate()
        if date != nil {
            timeView.text = DateUtils.stringFromDate(date!, format: "HH:mm:ss")
        }
        if Defaults[.visibilityEmoji] {
            switch json["visibility"].stringValue {
            case "unlisted":
                timeView.text = "🔓" + (timeView.text ?? "")
            case "private":
                timeView.text = "🔒" + (timeView.text ?? "")
            case "direct":
                timeView.text = "✉️" + (timeView.text ?? "")
            default:
                break
            }
        }
        if json["pinned"].boolValue {
            timeView.text = "📌"+(timeView.text ?? "")
        }
        timeView.font = timeView.font.withSize(CGFloat(Defaults[.timelineTextFontsize]))
        iconWidthConstraint.constant = CGFloat(Defaults[.timelineIconSize])
        iconHeightConstraint.constant = CGFloat(Defaults[.timelineIconSize])
        // -- タッチ周り --
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapUser)))
        userView.isUserInteractionEnabled = true
        userView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapUser)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapPost)))
        // /-- タッチ周り --
        let thumbnail_height = Defaults[.thumbnailHeight]
        self.imageThumbnailStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        if thumbnail_height != 0 {
            json["media_attachments"].arrayValue.enumerated().forEach({ (index, media) in
                let imageView = UIImageView()
                getImage(url: media["preview_url"].stringValue).then({ (image) in
                    imageView.image = image
                })
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layoutIfNeeded()
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(thumbnail_height)).isActive=true
                imageView.isUserInteractionEnabled = true
                imageView.tag = 100+index
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapImage)))
                self.imageThumbnailStackView.addArrangedSubview(imageView)
            })
        }
        self.textView.delegate = self
        self.layoutIfNeeded()
    }
    
    func tapUser(sender: UITapGestureRecognizer) {
        if self.json == nil {
            return
        }
        let newVC = openUserProfile(user: json!["reblog"].isEmpty ? json!["account"] : json!["reblog"]["account"])
        self.viewController?.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func tapPost(sender: UITapGestureRecognizer) {
        if self.json == nil {
            return
        }
        let storyboard = UIStoryboard(name: "MastodonPostDetail", bundle: nil)
        // let newVC = storyboard.instantiateViewController(withIdentifier: "topVC") as! UserProfileTopViewController
        let newVC = storyboard.instantiateInitialViewController() as! MastodonPostDetailTableViewController
        if !json!["reblog"].isEmpty {
            newVC.load(post: self.json!["reblog"])
        } else {
            newVC.load(post: self.json!)
        }
        self.viewController?.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func tapImage(sender: UITapGestureRecognizer) {
        if self.json == nil {
            return
        }
        let json = self.json!["reblog"].isEmpty ? self.json! : self.json!["reblog"]
        print(sender.view)
        let media = json["media_attachments"].arrayValue[sender.view!.tag-100]
        if media["url"].stringValue.hasSuffix("webm") && openVLC(media["url"].stringValue) {
            return
        }
        let safari = SFSafariViewController(url: URL(string: media["url"].stringValue)!)
        self.viewController?.present(safari, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith shareUrl: URL, in characterRange: NSRange) -> Bool {
        var urlString = shareUrl.absoluteString
        for mention in self.json!["mentions"].arrayValue {
            if urlString == mention["url"].stringValue {
                MastodonUserToken.getLatestUsed()!.get("accounts/\(mention["id"].stringValue)").then({ user in
                    let newVC = openUserProfile(user: user)
                    self.viewController?.navigationController?.pushViewController(newVC, animated: true)
                })
                print(mention)
                return false
            }
        }
        for media in self.json!["media_attachments"].arrayValue {
            if urlString == media["text_url"].stringValue {
                urlString = media["url"].stringValue
            }
        }
        let safari = SFSafariViewController(url: URL(string: urlString)!)
        self.viewController?.present(safari, animated: true, completion: nil)
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedRange.length != 0 {
            textView.selectedRange = NSRange()
        }
    }
    
    
    static func getInstance(owner: Any? = nil) -> MastodonPostCell {
        return UINib(nibName: "MastodonPostCell", bundle: nil).instantiate(withOwner: owner, options: nil).first as! MastodonPostCell
    }

}
