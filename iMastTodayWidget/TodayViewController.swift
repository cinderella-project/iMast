//
//  TodayViewController.swift
//  iMastTodayWidget
//
//  Created by rinsuki on 2017/08/14.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import NotificationCenter
import SDWebImage

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var postTextView: UILabel!
    var postText = "" {
        didSet {
            postTextView.text = postText
        }
    }
    @IBOutlet weak var userIconView: UIImageView!
    @IBOutlet weak var userScreenNameView: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var postSendLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // UserDefaultsAppGroup.register(defaults: defaultValues)
        postActivityIndicator.alpha = 0
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        let clipboardText = UIPasteboard.general.string ?? ""
        var regex = Defaults[.widgetFilter]
        if regex == "" {
            regex = ".*"
        }
        print(clipboardText.pregMatch(pattern: "^\(regex)$") as [String])
        if clipboardText.pregMatch(pattern: "^\(regex)$") {
            postText = Defaults[.widgetFormat].replace("{clipboard}", clipboardText)
        } else {
            postTextView.text = "正規表現フィルタにマッチしていません。\nフィルタ: "+regex
            postButton.alpha = 0
            postButton.isEnabled = false
        }
        let userToken = MastodonUserToken.getLatestUsed()!
        userScreenNameView.text = "@" + userToken.screenName! + "@" + userToken.app.instance.hostName
        if let avatarUrl = userToken.avatarUrl {
            self.userIconView.sd_setImage(with: URL(string: avatarUrl))
        }
        postActivityIndicator.alpha = 0
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func tootButtonTapped(_ sender: Any) {
        postButton.alpha = 0
        postButton.isEnabled = false
        postActivityIndicator.alpha = 1
        MastodonUserToken.getLatestUsed()!.post("statuses", params: [
            "media_ids": [],
            "sensitive": false,
            "spoiler_text": "",
            "status": postText,
            "visibility": "public"
        ]).then { (toot) in
            self.postActivityIndicator.alpha = 0
            self.postTextView.text = "送信しました"
            self.postSendLabel.alpha = 1
            print("toot end")
        }
    }
}
