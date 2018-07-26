//
//  UserProfileInfoTableViewCell.swift
//  iMast
//
//  Created by user on 2018/06/25.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit

class UserProfileInfoTableViewCell: UITableViewCell {
    var loadAfter = false
    var isLoaded = false
    var user: MastodonAccount?

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
        MastodonUserToken.getLatestUsed()?.getRelationship([user]).then({ (relationships) in
            let relationship = relationships[0]
            let relationshipOld: Bool = Defaults[.followRelationshipsOld]
            if relationship.following && relationship.followed_by {
                self.relationshipLabel.text = "関係: " + (relationshipOld ? "両思い" : "相互フォロー")
            }
            if relationship.following && !relationship.followed_by {
                self.relationshipLabel.text = "関係: " + (relationshipOld ? "片思い" : "フォローしています")
            }
            if !relationship.following && relationship.followed_by {
                self.relationshipLabel.text = "関係: " + (relationshipOld ? "片思われ" : "フォローされています")
            }
            if !relationship.following && !relationship.followed_by {
                self.relationshipLabel.text = "関係: 無関係"
            }
            if user.acct == MastodonUserToken.getLatestUsed()?.screenName {
                self.relationshipLabel.text = "関係: それはあなたです！"
            }
            if relationship.requested {
                self.relationshipLabel.text! += " (フォローリクエスト中)"
            }
            if relationship.blocking {
                self.relationshipLabel.text! += " (ブロック中)"
            }
            if relationship.muting {
                self.relationshipLabel.text! += " (ミュート中)"
            }
            if relationship.domain_blocking {
                self.relationshipLabel.text! += " (インスタンスミュート中)"
            }
        })
    }
}
