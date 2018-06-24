//
//  UserProfileBioTableViewCell.swift
//  iMast
//
//  Created by user on 2018/06/25.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit
import SafariServices

class UserProfileBioTableViewCell: UITableViewCell, UITextViewDelegate {
    var loadAfter = false
    var isLoaded = false
    var user: MastodonAccount?
    
    @IBOutlet weak var profileTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isLoaded = true
        if let user = self.user, self.loadAfter {
            self.load(user: user)
        }
        self.profileTextView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func load(user: MastodonAccount) {
        self.user = user
        if !isLoaded {
            loadAfter = true
            return
        }
        self.profileTextView.attributedText = ("<style>*{font-size:14px;line-height: 1.1em;font-family: sans-serif;padding:0;margin:0;}body{text-align: center;}</style>" + user.bio.replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "")).parseText2HTML()
        self.profileTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        self.profileTextView.textContainer.lineFragmentPadding = 0
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let safari = SFSafariViewController(url: URL)
        self.viewController?.present(safari, animated: true, completion: nil)
        return false
    }
}
