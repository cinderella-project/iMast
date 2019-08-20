//
//  MastodonPostDetailTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/14.
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
import SwiftyJSON
import SafariServices
import AVKit

class MastodonPostDetailTableViewController: UITableViewController, UITextViewDelegate {
    var userToken: MastodonUserToken!
    
    @IBOutlet weak var firstCell: UITableViewCell!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var userNameView: UILabel!
    @IBOutlet weak var userScreenNameView: UILabel!
    @IBOutlet weak var actionCountCell: UITableViewCell!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var boostButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var postStackView: UIStackView!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var nsfwGuardView: NSFWGuardView!
    var loadAfter = false
    var isLoaded = false
    var post: MastodonPost?
    var cwOpen = false
    var isFavorited = false {
        didSet {
            favouriteButton.setTitleColor(isFavorited ?
                UIColor(
                    red: 1,
                    green: 0.8,
                    blue: 0.01,
                    alpha: 1
                )
              : UIColor.darkGray, for: .normal)
        }
    }
    var isBoosted = false {
        didSet {
            boostButton.setTitleColor(isBoosted ?
                UIColor(
                    red: 0.1,
                    green: 0.6,
                    blue: 1,
                    alpha: 1
                )
                : UIColor.darkGray, for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        isLoaded = true
        if loadAfter {
            loadAfter = false
            load(post: post!)
        }
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
//        textView.sizeToFit()
        textView.delegate = self
    }
    
    func load(post originalPost: MastodonPost, spoiler: Bool = false) {
        let post = originalPost.originalPost
        self.post = post
        if isLoaded == false {
            loadAfter = true
            return
        }
        print(post)
        var html = ""
        let postHtml = post.status.emojify().replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "")
        if post.spoilerText != "" {
            html += post.spoilerText.replace("<", "&lt;").replace(">", "&gt;").replace("\n", "<br>").emojify()
            if !spoiler {
                html += "<br><a href=\"imast://cw/show\">(CWの内容を読む)</a><br>"
            } else {
                html += "<br><a href=\"imast://cw/hide\">(CWの内容を畳む)</a><br>"
                html += postHtml
            }
        } else {
            html += postHtml
        }
        if let attrStr = html.parseText2HTML(attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.label,
        ], asyncLoadProgressHandler: {
            self.textView.setNeedsDisplay()
        })?.emojify(asyncLoadProgressHandler: {
            self.textView.setNeedsDisplay()
        }, emojifyProtocol: post) {
            textView.attributedText = attrStr
        } else {
            textView.text = post.status.toPlainText()
        }
        var iconUrl = post.account.avatarUrl
        if iconUrl.count >= 1 && iconUrl[iconUrl.startIndex] == "/" {
            iconUrl = "https://"+self.userToken.app.instance.hostName+iconUrl
        }
        userNameView.text = (post.account.name != "" ? post.account.name : post.account.screenName).emojify()
        userScreenNameView.text = "@"+post.account.acct
        iconView.sd_setImage(with: URL(string: iconUrl))
        iconView.ignoreSmartInvert()
        var actionTexts: [String] = []
        if post.repostCount > 0 {
            actionTexts.append("%d件のブースト".format(post.repostCount))
        }
        if post.favouritesCount > 0 {
            actionTexts.append("%d件のふぁぼ".format(post.favouritesCount))
        }
        if let app = post.application {
            actionTexts.append("via \(app.name)")
        }
        actionCountCell.textLabel?.text = actionTexts.joined(separator: " ")
        
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapUser)))
        userNameView.isUserInteractionEnabled = true
        userNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapUser)))
        userScreenNameView.isUserInteractionEnabled = true
        userScreenNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapUser)))

        isFavorited = post.favourited
        isBoosted = post.reposted
        
        let thumbnail_height = Defaults[.thumbnailHeight]
        nsfwGuardView.isHidden = !(nsfwGuardView.explicitlyOpened == false && post.sensitive && post.attachments.count > 0)

        for subview in self.imageStackView.arrangedSubviews {
            self.imageStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        if thumbnail_height != 0 {
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
                self.imageStackView.addArrangedSubview(imageView)
            })
        } else {
            for subview in self.imageStackView.arrangedSubviews {
                self.imageStackView.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }
        postStackView.layoutIfNeeded()
    }
    
    @objc func tapImage(sender: UITapGestureRecognizer) {
        guard let post = self.post?.originalPost else {
            return
        }
        let media = post.attachments[sender.view!.tag-100]
        if media.url.hasSuffix("webm") && openVLC(media.url) {
            return
        }

        if media.type == .video || media.type == .gifv || media.type == .audio, let url = URL(string: media.url) {
            let item = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: item)
            let viewController = LoopableAVPlayerViewController()
            viewController.player = player
            player.play()
            viewController.isLoop = media.type == .gifv
            self.present(viewController, animated: true, completion: nil)
            return
        }

        let safari = SFSafariViewController(url: URL(string: media.url)!)
        self.present(safari, animated: true, completion: nil)
    }
    
    @IBAction func replyTapped(_ sender: Any) {
        guard let post = self.post?.originalPost else {
            return
        }
        guard let newVC = R.storyboard.newPost.instantiateInitialViewController() else {
            return
        }
        newVC.userToken = self.userToken
        newVC.replyToPost = post
        newVC.title = "返信"
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    @IBAction func boostTapped(_ sender: Any) {
        guard let post = self.post?.originalPost else {
            return
        }
        if !isBoosted {
            self.userToken.repost(post: post).then({ (res) in
                self.isBoosted = true
            })
        } else {
            self.userToken.unrepost(post: post).then({ (res) in
                self.isBoosted = false
            })
        }
        print(isBoosted)
    }
    @IBAction func favouriteTapped(_ sender: Any) {
        guard let post = self.post?.originalPost else {
            return
        }
        if !isFavorited {
            self.userToken.favourite(post: post).then({ (res) in
                self.isFavorited = true
            })
        } else {
            self.userToken.unfavourite(post: post).then({ (res) in
                self.isFavorited = false
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath[0] == 0 && indexPath[1] == 0 {
//            return textView.frame.minY + textView.frame.height + 16 + imageStackView.frame.height
            return UITableView.automaticDimension
        }
        if indexPath[0] == 0 && indexPath[1] == 1 {
            if (actionCountCell.textLabel?.text ?? "") == ""{
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    @objc func tapUser(sender: UITapGestureRecognizer) {
        guard let post = self.post?.originalPost else {
            return
        }
        let newVC = UserProfileTopViewController.instantiate(post.account, environment: self.userToken)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        var urlString = url.absoluteString
        let visibleString = (textView.attributedText.string as NSString).substring(with: characterRange)
        if let post = self.post {
            if url.scheme == "imast" {
                if url.absoluteString == "imast://cw/show" {
                    self.load(post: post, spoiler: true)
                }
                if url.absoluteString == "imast://cw/hide" {
                    self.load(post: post, spoiler: false)
                }
                self.tableView.reloadData()
                return false
            }
            if let mention = post.mentions.first(where: { $0.url == urlString }) {
                self.userToken.getAccount(id: mention.id).then({ user in
                    let newVC = UserProfileTopViewController.instantiate(user, environment: self.userToken)
                    self.navigationController?.pushViewController(newVC, animated: true)
                })
                return false
            }
            if let media = post.attachments.first(where: { $0.textUrl == urlString }) {
                urlString = media.url
            }
            if visibleString.starts(with: "#") {
                let tag = String(visibleString[visibleString.index(after: visibleString.startIndex)...])
                let newVC = HashtagTimeLineTableViewController(hashtag: tag, environment: self.userToken)
                self.navigationController?.pushViewController(newVC, animated: true)
                return false
            }
        }
        self.open(url: URL(string: urlString)!)
        return false
    }
    @IBAction func moreButtonTapped(_ sender: Any) {
        guard let post = self.post?.originalPost else {
            return
        }
        let actionSheet = UIAlertController(title: "アクション", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.popoverPresentationController?.sourceView = self.moreButton as UIView
        actionSheet.popoverPresentationController?.sourceRect = (self.moreButton as UIView).bounds
        // ---
        actionSheet.addAction(UIAlertAction(title: "文脈", style: UIAlertAction.Style.default, handler: { action in
            self.openBunmyaku()
        }))
        if (post.emojis?.count ?? 0) + (post.profileEmojis?.count ?? 0) > 0 { // カスタム絵文字がある
            actionSheet.addAction(UIAlertAction(title: "カスタム絵文字一覧", style: .default, handler: { _ in
                let newVC = EmojiListTableViewController()
                newVC.emojis = (post.emojis ?? []) + (post.profileEmojis ?? [])
                newVC.account = post.account
                self.navigationController?.pushViewController(newVC, animated: true)
            }))
        }
        if self.userToken.screenName == post.account.acct {
            actionSheet.addAction(UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive, handler: { (action) in
                self.confirm(title: "投稿の削除", message: Defaults[.deleteTootTeokure] ? "失った信頼はもう戻ってきませんが、本当にこのトゥートを削除しますか?" : "この投稿を削除しますか?", okButtonMessage: "削除", style: .destructive).then({ (res) in
                    if res == false {
                        return
                    }
                    self.userToken.delete(post: post).then({ (res) in
                        self.navigationController?.popViewController(animated: true)
                        self.alert(title: "投稿を削除しました", message: "投稿を削除しました。\n※画面に反映されるには時間がかかる場合があります")
                    })
                })
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "通報", style: UIAlertAction.Style.destructive, handler: { (action) in
            let newVC = MastodonPostAbuseViewController.instantiate(post, environment: self.userToken)
            newVC.placeholder = "『\(post.status.pregReplace(pattern: "<.+?>", with: ""))』を通報します。\n詳細をお書きください（必須ではありません）"
            self.navigationController?.pushViewController(newVC, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func pushReplyTree(_ sender: Any) {
        self.openBunmyaku()
    }

    func openBunmyaku() {
        guard let post = post else {
            return
        }
        let bunmyakuVC = BunmyakuTableViewController.instantiate(.plain, environment: self.userToken)
        bunmyakuVC.basePost = post
        self.navigationController?.pushViewController(bunmyakuVC, animated: true)
    }
    
    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
