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
import SDWebImage
import AVKit
import Ikemen
import NorthLayout

class MastodonPostCell: UITableViewCell, UITextViewDelegate {
    static let boostColor = UIColor(red: 0.1, green: 0.7, blue: 0.1, alpha: 1)
    static let favouritedColor = UIColor(red: 0.9, green: 0.8, blue: 0.1, alpha: 1)
    
    let iconView = UIImageView()
    let userView = UILabel()
    let timeView = UILabel()
    let textView = UITextView() ※ {
        $0.isScrollEnabled = false
        $0.isEditable = false
    }
    let imageThumbnailStackView = UIStackView()
    let boostedUserIcon = UIImageView()
    let tootInfoView =  UIView() ※ {
        $0.backgroundColor = MastodonPostCell.boostColor
    }
    let nsfwGuardView = NSFWGuardView()
    var post: MastodonPost?
    let myBoostedView = UIView() ※ {
        $0.backgroundColor = MastodonPostCell.boostColor
    }
    let myFavouritedView = UIView() ※ {
        $0.backgroundColor = MastodonPostCell.favouritedColor
    }
    var pinned: Bool = false
    
    func viewDidLayoutSubviews() {
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let northLayout = northLayoutFormat([
            "outerPadding": 8,
            "infoWidth": 3,
            "iconSize": CGFloat(Defaults[.timelineIconSize]),
        ], [
            "icon": self.iconView,
            "tootInfo": self.tootInfoView,
            "user": self.userView,
            "time": self.timeView,
            "text": self.textView,
            "myBoosted": self.myBoostedView,
            "myFavourited": self.myFavouritedView,
            "images": self.imageThumbnailStackView,
            "boostedUser": self.boostedUserIcon,
        ])
        northLayout("H:|[tootInfo(==infoWidth)]")
        northLayout("H:[myBoosted(==infoWidth,==myFavourited)]|")
        northLayout("H:[myFavourited]|")
        northLayout("H:|-outerPadding-[icon(==iconSize)]-outerPadding-[user]-[time]-outerPadding-|")
        northLayout("H:[icon]-[text]-outerPadding-|")
        northLayout("H:[icon]-outerPadding-[images]-outerPadding-|")
        northLayout("H:|-outerPadding-(iconSize*0.5)-[boostedUser(==iconSize*0.5)]")
        northLayout("V:|-outerPadding-[icon(==iconSize)]-(>=outerPadding)-|")
        northLayout("V:|[tootInfo]|")
        northLayout("V:|-outerPadding-[user]-4-[text]-[images]-outerPadding-|")
        northLayout("V:|-outerPadding-[time]-4-[text]")
        northLayout("V:|[myBoosted(==myFavourited)][myFavourited]|")
        northLayout("V:|-outerPadding-(iconSize*0.5)-[boostedUser(==iconSize*0.5)]")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(post post_: MastodonPost) {
        let post = post_.repost ?? post_
        if let repost = post_.repost {
            self.boostedUserIcon.sd_setImage(with: URL(string: post_.account.avatarUrl))
            self.boostedUserIcon.ignoreSmartInvert()
        } else {
            self.boostedUserIcon.image = nil
        }
        self.tootInfoView.isHidden = post_.repost == nil
        self.post = post
        // textView.dataDetectorTypes = .link
        let attrStrTmp = (post.status.replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "").emojify(custom_emoji: post.emojis, profile_emoji: post.profileEmojis))
        var attrs: [NSAttributedString.Key: Any] = [:]
        if Defaults[.timelineTextBold] {
            attrs[.font] = UIFont.boldSystemFont(ofSize: CGFloat(Defaults[.timelineTextFontsize]))
        } else {
            attrs[.font] = UIFont.systemFont(ofSize: CGFloat(Defaults[.timelineTextFontsize]))
        }
        if post.spoilerText != "" {
            textView.text = post.spoilerText.emojify() + "\n(CWの内容は詳細画面で\(post.attachments.count != 0 ? ", \(post.attachments.count)個の添付メディア" : ""))"
            textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        } else if let attrStr = attrStrTmp.parseText2HTML(attributes: attrs, asyncLoadProgressHandler: {
            self.textView.setNeedsDisplay()
        }) {
            textView.attributedText = attrStr
        } else {
            textView.text = post.status.toPlainText()
        }
        textView.font = textView.font?.withSize(CGFloat(Defaults[.timelineTextFontsize]))
        userView.text = (post.account.name != "" ? post.account.name : post.account.screenName).emojify()
        userView.font = userView.font.withSize(CGFloat(Defaults[.timelineUsernameFontsize]))
        var iconUrl = post.account.avatarUrl
        if iconUrl.count >= 1 && iconUrl[iconUrl.startIndex] == "/" {
            iconUrl = "https://"+MastodonUserToken.getLatestUsed()!.app.instance.hostName+iconUrl
        }
        self.iconView.sd_setImage(with: URL(string: iconUrl))
        self.iconView.ignoreSmartInvert()
        let calendar = Calendar(identifier: .gregorian)
        if calendar.isDateInToday(post.createdAt) {
            timeView.text = DateUtils.stringFromDate(post.createdAt, format: "HH:mm:ss")
        } else if calendar.component(.year, from: Date()) == calendar.component(.year, from: post.createdAt) {
            timeView.text = DateUtils.stringFromDate(post.createdAt, format: "MM/dd HH:mm:ss")
        } else {
            timeView.text = DateUtils.stringFromDate(post.createdAt, format: "yyyy/MM/dd HH:mm:ss")
        }
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
        
        if Defaults[.inReplyToEmoji] && post.inReplyToId != nil {
            timeView.text = "💬" + (timeView.text ?? "")
        }
        
        if self.pinned {
            timeView.text = "📌"+(timeView.text ?? "")
            let limit = Int(Defaults[.pinnedTootLinesLimit])
            if limit > 0 {
                textView.textContainer.maximumNumberOfLines = Int(Defaults[.pinnedTootLinesLimit])
                textView.textContainer.lineBreakMode = .byTruncatingTail
            }
        }
        timeView.font = timeView.font.withSize(CGFloat(Defaults[.timelineUsernameFontsize]))
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
        
        self.nsfwGuardView.isHidden = true
        self.nsfwGuardView.isUserInteractionEnabled = false
        
        if thumbnail_height != 0 && post.spoilerText == "" && post.attachments.count > 0 {
            post.attachments.enumerated().forEach({ (index, media) in
                let imageView = UIImageView()
                imageView.sd_setImage(with: URL(string: media.previewUrl))
                imageView.ignoreSmartInvert()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layoutIfNeeded()
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(thumbnail_height)).isActive=true
                imageView.isUserInteractionEnabled = true
                imageView.tag = 100+index
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapImage)))
                self.imageThumbnailStackView.addArrangedSubview(imageView)
            })
            
            if post.sensitive {
                self.nsfwGuardView.isHidden = false
                self.nsfwGuardView.isUserInteractionEnabled = true
            }
        }

        self.myBoostedView.isHidden = !post.reposted
        self.myFavouritedView.isHidden = !post.favourited
        
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
        if media.type == .video || media.type == .gifv, Defaults[.useAVPlayer], let url = URL(string: media.url) {
            let item = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: item)
            let viewController = LoopableAVPlayerViewController()
            viewController.player = player
            player.play()
            viewController.isLoop = media.type == .gifv
            self.viewController?.present(viewController, animated: true, completion: nil)
            return
        }
        let safari = SFSafariViewController(url: URL(string: media.url)!)
        self.viewController?.present(safari, animated: true, completion: nil)
    }

    func textView(_ textView: UITextView, shouldInteractWith shareUrl: URL, in characterRange: NSRange) -> Bool {
        var urlString = shareUrl.absoluteString
        let visibleString = (textView.attributedText.string as NSString).substring(with: characterRange)
        if let post = self.post {
            if let mention = post.mentions.first(where: { $0.url == urlString }) {
                MastodonUserToken.getLatestUsed()!.getAccount(id: mention.id).then({ user in
                    let newVC = openUserProfile(user: user)
                    self.viewController?.navigationController?.pushViewController(newVC, animated: true)
                })
                return false
            }
            if let media = post.attachments.first(where: { $0.textUrl == urlString }) {
                urlString = media.url
            }
            if visibleString.starts(with: "#") {
                let tag = String(visibleString[visibleString.index(after: visibleString.startIndex)...])
                let newVC = HashtagTimeLineTableViewController(hashtag: tag)
                self.viewController?.navigationController?.pushViewController(newVC, animated: true)
                return false
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
        return MastodonPostCell(style: .default, reuseIdentifier: nil)
    }

}
