//
//  UserProfileInfoTableViewCell.swift
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
import iMastiOSCore

class UserProfileInfoTableViewCell: UITableViewCell {
    var loadAfter = false
    var isLoaded = false
    var user: MastodonAccount?
    var userToken: MastodonUserToken!

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var relationshipLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isLoaded = true
        if let user = self.user, self.loadAfter {
            self.load(user: user)
        }
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
        self.iconView.sd_setImage(with: URL(string: user.avatarUrl), completed: nil)
        self.iconView.ignoreSmartInvert()
        self.nameLabel.text = user.name == "" ? user.screenName : user.name
        self.screenNameLabel.text = "@" + user.acct
        self.userToken.getRelationship([user]).then({ (relationships) in
            let relationship = relationships[0]
            let relationshipOld: Bool = Defaults[.followRelationshipsOld]
            var relationshipText: String
            switch (relationship.following, relationship.followed_by, user.acct == self.userToken.screenName) {
            case (_, _, true):
                relationshipText = "関係: それはあなたです！"
            case (true, true, false):
                relationshipText = "関係: " + (relationshipOld ? "両思い" : "相互フォロー")
            case (true, false, false):
                relationshipText = "関係: " + (relationshipOld ? "片思い" : "フォローしています")
            case (false, true, false):
                relationshipText = "関係: " + (relationshipOld ? "片思われ" : "フォローされています")
            case (false, false, false):
                relationshipText = "関係: 無関係"
            }
            if relationship.requested {
                relationshipText += " (フォローリクエスト中)"
            }
            if relationship.blocking {
                relationshipText += " (ブロック中)"
            }
            if relationship.muting {
                relationshipText += " (ミュート中)"
            }
            if relationship.domain_blocking {
                relationshipText += " (インスタンスミュート中)"
            }
            self.relationshipLabel.text = relationshipText
        })
    }
}
