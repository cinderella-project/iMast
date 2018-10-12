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
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        if let attrStr = user.bio.replace("</p><p>", "<br /><br />").replace("<p>", "").replace("</p>", "").parseText2HTML(attributes: [
            .paragraphStyle: paragraph,
            .font: UIFont.systemFont(ofSize: 14),
        ]) {
            self.profileTextView.attributedText = attrStr
        }
        self.profileTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        self.profileTextView.textContainer.lineFragmentPadding = 0
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let string = (textView.attributedText.string as NSString).substring(with: characterRange)
        if string.hasPrefix("@") {
            let alert = UIAlertController(title: "ユーザー検索中", message: "\(URL.absoluteString)\n\nしばらくお待ちください", preferredStyle: .alert)
            var canceled = false
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
                canceled = true
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "強制的にSafariで開く", style: .default, handler: { _ in
                canceled = true
                alert.dismiss(animated: true, completion: nil)
                let safari = SFSafariViewController(url: URL)
                self.viewController?.present(safari, animated: true, completion: nil)
            }))
            MastodonUserToken.getLatestUsed()?.search(q: URL.absoluteString, resolve: true).then { result in
                if canceled { return }
                alert.dismiss(animated: true, completion: nil)
                if result.accounts.count >= 1 {
                    let newVC = openUserProfile(user: result.accounts[0])
                    self.viewController?.navigationController?.pushViewController(newVC, animated: true)
                } else {
                    let safari = SFSafariViewController(url: URL)
                    self.viewController?.present(safari, animated: true, completion: nil)
                }
            }.catch { error in
                alert.dismiss(animated: true, completion: nil)
            }
            self.viewController?.present(alert, animated: true, completion: nil)
            return false
        }
        let safari = SFSafariViewController(url: URL)
        self.viewController?.present(safari, animated: true, completion: nil)
        return false
    }
}
