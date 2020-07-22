//
//  UserProfileBioTableViewCell.swift
//  iMast
//
//  Created by rinsuki on 2018/06/25.
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
import SafariServices
import iMastiOSCore
import Ikemen

class UserProfileBioTableViewCell: UITableViewCell, UITextViewDelegate {
    var user: MastodonAccount?
    var userToken: MastodonUserToken?
    
    let profileTextView = UITextView() ※ { v in
        v.isScrollEnabled = false
        v.isEditable = false
        v.isSelectable = true
        v.backgroundColor = .clear
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        addSubview(profileTextView)
        profileTextView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(layoutMarginsGuide)
            make.top.bottom.equalTo(layoutMarginsGuide)
        }
        profileTextView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(user: MastodonAccount) {
        self.user = user
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        if let attrStr = user.bio.replacingOccurrences(of: "</p><p>", with: "<br /><br />").replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: "").parseText2HTML(attributes: [
            .paragraphStyle: paragraph,
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.label,
        ]) {
            self.profileTextView.attributedText = attrStr
        }
        self.profileTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        self.profileTextView.textContainer.lineFragmentPadding = 0
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let string = (textView.attributedText.string as NSString).substring(with: characterRange)
        if string.hasPrefix("@"), let userToken = self.userToken {
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
            userToken.search(q: URL.absoluteString, resolve: true).then { result in
                if canceled { return }
                alert.dismiss(animated: true, completion: nil)
                if let account = result.accounts.first {
                    let newVC = UserProfileTopViewController.instantiate(account, environment: userToken)
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
