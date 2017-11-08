//
//  MastodonPostDetailTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/14.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import SafariServices

class MastodonPostDetailTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var firstCell: UITableViewCell!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var userNameView: UILabel!
    @IBOutlet weak var userScreenNameView: UILabel!
    @IBOutlet weak var actionCountCell: UITableViewCell!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var boostButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    var loadAfter = false
    var isLoaded = false
    var loadJSON: JSON?
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
              : UIColor.darkGray
            , for: .normal)
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
                : UIColor.darkGray
            , for: .normal)
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
            load(post: loadJSON!)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        textView.sizeToFit()
        textView.delegate = self
    }
    
    func load(post: JSON) {
        loadJSON = post
        if isLoaded == false {
            loadAfter = true
            return
        }
        print(post)
        var html = "<style>*{font-size:14px;font-family: sans-serif;padding:0;margin:0;}</style>"
        if post["spoiler_text"].string != "" && post["spoiler_text"].string != nil {
            html += post["spoiler_text"].stringValue.replace("<", "&lt;").replace(">", "&gt;").replace("&", "&amp;").replace("\n", "<br>")
            html += "<br><a href=\""+post["url"].stringValue+"\">(CWの内容を読む)</a><br>"
        } else {
            html += post["content"].stringValue.emojify(custom_emoji: post["emojis"].arrayValue, profile_emoji: post["profile_emojis"].arrayValue).replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "")
        }
        let attrStr = html.parseText2HTML()
        if attrStr == nil {
            textView.text = (post["content"].string ?? "")
                .pregReplace(pattern: "\\<br /\\>", with: "\n")
                .pregReplace(pattern: "\\<.+?\\>", with: "")
                .replace("&lt;", "<") // HTMLのエスケープを解く
                .replace("&gt;", ">")
                .replace("&apos;", "\"")
                .replace("&quot;", "'")
                .replace("&amp;", "&")
        } else {
            textView.attributedText = attrStr
        }
        var iconUrl = post["account"]["avatar_static"].stringValue
        if iconUrl.count >= 1 && iconUrl[iconUrl.startIndex] == "/" {
            iconUrl = "https://"+MastodonUserToken.getLatestUsed()!.app.instance.hostName+iconUrl
        }
        userNameView.text = (((post["account"]["display_name"].string ?? "") != "" ? post["account"]["display_name"].string : post["account"]["username"].string ?? "") ?? "").emojify()
        userScreenNameView.text = "@"+(post["account"]["acct"].string ?? post["account"]["username"].stringValue)
        getImage(url: iconUrl).then { (image) in
            self.iconView.image = image
        }
        var actionText = ""
        if post["reblogs_count"].intValue > 0 {
            actionText += "%d件のブースト ".format(post["reblogs_count"].intValue)
        }
        if post["favourites_count"].intValue > 0 {
            actionText += "%d件のふぁぼ ".format(post["favourites_count"].intValue)
        }
        if post["application"]["name"].string != nil {
            actionText += "via "+post["application"]["name"].stringValue+" "
        }
        actionCountCell.textLabel?.text = actionText
        
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapUser)))
        userNameView.isUserInteractionEnabled = true
        userNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapUser)))
        userScreenNameView.isUserInteractionEnabled = true
        userScreenNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapUser)))
    }
    @IBAction func replyTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "NewPost", bundle: nil)
        // let newVC = storyboard.instantiateViewController(withIdentifier: "topVC") as! UserProfileTopViewController
        let newVC = storyboard.instantiateInitialViewController() as! NewPostViewController
        if !loadJSON!["reblog"].isEmpty {
            newVC.replyToPost = loadJSON!["reblog"]
        } else {
            newVC.replyToPost = loadJSON!
        }
        newVC.title = "返信"
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    @IBAction func boostTapped(_ sender: Any) {
        if !isBoosted {
            MastodonUserToken.getLatestUsed()!.post("statuses/%d/reblog".format(loadJSON!["id"].intValue)).then({ (res) in
                self.isBoosted = true
            })
        } else {
            MastodonUserToken.getLatestUsed()!.post("statuses/%d/unreblog".format(loadJSON!["id"].intValue)).then({ (res) in
                self.isBoosted = false
            })
        }
        print(isBoosted)
    }
    @IBAction func favouriteTapped(_ sender: Any) {
        if !isFavorited {
            MastodonUserToken.getLatestUsed()!.post("statuses/%d/favourite".format(loadJSON!["id"].intValue)).then({ (res) in
                self.isFavorited = true
            })
        } else {
            MastodonUserToken.getLatestUsed()!.post("statuses/%d/unfavourite".format(loadJSON!["id"].intValue)).then({ (res) in
                self.isFavorited = false
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*
        let textViewRequiredHeight = textView.frame.minY + textView.frame.height + 8
        if firstCell.frame.height < textViewRequiredHeight {
            firstCell.frame = CGRect(x: firstCell.frame.minX, y: firstCell.frame.minY, width: firstCell.frame.width, height: textViewRequiredHeight)
            
        }
         */
        textView.sizeToFit()
        print(textView.frame)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath[0] == 0 && indexPath[1] == 0 {
            textView.sizeToFit()
            return textView.frame.minY + textView.frame.height + 10
        }
        if indexPath[0] == 0 && indexPath[1] == 1 {
            if (actionCountCell.textLabel?.text ?? "") == ""{
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    func tapUser(sender: UITapGestureRecognizer) {
        if loadJSON == nil {
            return
        }
        let newVC = openUserProfile(user: loadJSON!["reblog"].isEmpty ? loadJSON!["account"] : loadJSON!["reblog"]["account"])
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let safari = SFSafariViewController(url: URL)
        self.present(safari, animated: true, completion: nil)
        return false
    }
    @IBAction func moreButtonTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "アクション", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.popoverPresentationController?.sourceView = self.moreButton as UIView
        actionSheet.popoverPresentationController?.sourceRect = (self.moreButton as UIView).bounds
        // ---
        actionSheet.addAction(UIAlertAction(title: "文脈", style: UIAlertActionStyle.default, handler: { action in
            MastodonUserToken.getLatestUsed()?.get("statuses/%d/context".format(self.loadJSON!["id"].intValue)).then { res in
                print(res)
                let posts = res["ancestors"].arrayValue + [self.loadJSON!] + res["descendants"].arrayValue
                let bunmyakuVC = TimeLineTableViewController()
                bunmyakuVC.addNewPosts(posts: posts)
                bunmyakuVC.isReadmoreEnabled = false
                bunmyakuVC.title = "文脈"
                self.navigationController?.pushViewController(bunmyakuVC, animated: true)
            }
        }))
        if MastodonUserToken.getLatestUsed()!.screenName == loadJSON?["account"]["acct"].stringValue {
            actionSheet.addAction(UIAlertAction(title: "削除", style: UIAlertActionStyle.destructive, handler: { (action) in
                self.confirm(title: "投稿の削除", message: "この投稿を削除しますか?", okButtonMessage: "削除", style: .destructive).then({ (res) in
                    if res == false {
                        return
                    }
                    MastodonUserToken.getLatestUsed()!.delete("statuses/%d".format(self.loadJSON!["id"].intValue)).then({ (res) in
                        self.navigationController?.popViewController(animated: true)
                        self.alert(title: "投稿を削除しました", message: "投稿を削除しました。\n※画面に反映されるには時間がかかる場合があります")
                    })
                })
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "通報", style: UIAlertActionStyle.destructive, handler: { (action) in
            self.performSegue(withIdentifier: "goAbuse", sender: self.loadJSON)
        }))
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goAbuse" {
            let VC = segue.destination as! MastodonPostAbuseViewController
            let post = sender as! JSON
            VC.targetPost = post
            VC.placeholder = "『"+post["content"].stringValue.pregReplace(pattern: "<.+?>", with: "")+"』を通報します。\n詳細をお書きください（必須ではありません）"
        }
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
