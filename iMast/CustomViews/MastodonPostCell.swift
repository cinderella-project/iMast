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
    var post: MastodonPost?
    
    func viewDidLayoutSubviews() {
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func load(post post_: MastodonPost) {
        let post = post_.repost ?? post_
        if let repost = post_.repost {
            getImage(url: post_.account.avatarUrl).then { image in
                self.boostedUserIcon.image = image
            }
            self.tootInfoView.backgroundColor = UIColor.init(red: 0.1, green: 0.7, blue: 0.1, alpha: 1)
        } else {
            self.tootInfoView.backgroundColor = nil
            self.boostedUserIcon.image = nil
        }
        self.post = post
        // textView.dataDetectorTypes = .link
        var attrStrTmp = "<style>*{font-size:%.2fpx;font-family: sans-serif;padding:0;margin:0;}</style>".format(Defaults[DefaultsKeys.timelineTextFontsize])
        if Defaults[.timelineTextBold] {
            attrStrTmp += "<strong>"
        }
        attrStrTmp += (post.status.replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "").emojify(custom_emoji: post.emojis, profile_emoji: post.profileEmojis))
        if Defaults[.timelineTextBold] {
            attrStrTmp += "</strong>"
        }
        var attrStr = attrStrTmp.parseText2HTML()
        if post.spoilerText != "" {
            textView.text = post.spoilerText.emojify() + "\n(CWの内容は詳細画面で\(post.attachments.count != 0 ? ", \(post.attachments.count)個の添付メディア" : ""))"
            textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
            attrStr = nil
        } else if attrStr == nil {
            textView.text = post.status
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
        userView.text = (post.account.name != "" ? post.account.name : post.account.screenName).emojify()
        userView.font = userView.font.withSize(CGFloat(Defaults[.timelineUsernameFontsize]))
        var iconUrl = post.account.avatarUrl
        if iconUrl.count >= 1 && iconUrl[iconUrl.startIndex] == "/" {
            iconUrl = "https://"+MastodonUserToken.getLatestUsed()!.app.instance.hostName+iconUrl
        }
        getImage(url: iconUrl,size: Int(self.iconView.frame.width)).then { image in
            self.iconView.image = image
        }
        timeView.text = DateUtils.stringFromDate(post.createdAt, format: "HH:mm:ss")
        if Defaults[.visibilityEmoji] {
            switch post.visibility {
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
        if post.pinned ?? false {
            timeView.text = "📌"+(timeView.text ?? "")
        }
        timeView.font = timeView.font.withSize(CGFloat(Defaults[.timelineTextFontsize]))
        iconWidthConstraint.constant = CGFloat(Defaults[.timelineIconSize])
        iconHeightConstraint.constant = CGFloat(Defaults[.timelineIconSize])
        // -- タッチ周り --
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.isUserInteractionEnabled = true
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapPost)))
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
        if thumbnail_height != 0 && post.spoilerText == "" {
            post.attachments.enumerated().forEach({ (index, media) in
                let imageView = UIImageView()
                getImage(url: media.previewUrl).then({ (image) in
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
    
    @objc func tapUser(sender: UITapGestureRecognizer) {
        guard let post = self.post else {
            return
        }
        let newVC = openUserProfile(user: post.account)
        self.viewController?.navigationController?.pushViewController(newVC, animated: true)
    }
    
    @objc func tapPost(sender: UITapGestureRecognizer) {
        guard let post = self.post else {
            return
        }
        let storyboard = UIStoryboard(name: "MastodonPostDetail", bundle: nil)
        // let newVC = storyboard.instantiateViewController(withIdentifier: "topVC") as! UserProfileTopViewController
        let newVC = storyboard.instantiateInitialViewController() as! MastodonPostDetailTableViewController
        newVC.load(post: post)
        self.viewController?.navigationController?.pushViewController(newVC, animated: true)
    }
    
    @objc func tapImage(sender: UITapGestureRecognizer) {
        guard let post = self.post else {
            return
        }
        let media = post.attachments[sender.view!.tag-100]
        if media.url.hasSuffix("webm") && openVLC(media.url) {
            return
        }
        let safari = SFSafariViewController(url: URL(string: media.url)!)
        self.viewController?.present(safari, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith shareUrl: URL, in characterRange: NSRange) -> Bool {
        var urlString = shareUrl.absoluteString
        if let post = self.post {
            for mention in post.mentions {
                if urlString == mention.url {
                    MastodonUserToken.getLatestUsed()!.getAccount(id: mention.id).then({ user in
                        let newVC = openUserProfile(user: user)
                        self.viewController?.navigationController?.pushViewController(newVC, animated: true)
                    })
                    return false
                }
            }
            for media in post.attachments {
                if urlString == media.textUrl {
                    urlString = media.url
                }
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
