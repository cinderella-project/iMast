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
import Ikemen

class UserProfileInfoTableViewCell: UITableViewCell {
    var user: MastodonAccount?
    var userToken: MastodonUserToken!

    let iconView = UIImageView() ※ { v in
        v.snp.makeConstraints { make in
            make.size.equalTo(64)
        }
    }
    let nameLabel = UILabel() ※ { v in
        v.font = .systemFont(ofSize: 17)
    }
    let screenNameLabel = UILabel() ※ { v in
        v.font = .systemFont(ofSize: 14)
    }
    let relationshipLabel = UILabel() ※ { v in
        v.text = "関係: 読み込み中…"
        v.font = .systemFont(ofSize: 14)
    }

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        let stackView = UIStackView(arrangedSubviews: [
            iconView,
            nameLabel,
            screenNameLabel,
            relationshipLabel,
        ])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 8
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview().inset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func load(user: MastodonAccount) {
        self.user = user
        self.iconView.sd_setImage(with: URL(string: user.avatarUrl), completed: nil)
        self.iconView.ignoreSmartInvert()
        self.nameLabel.text = user.name == "" ? user.screenName : user.name
        self.screenNameLabel.text = "@" + user.acct
        self.userToken.getRelationship([user]).then({ (relationships) in
            let relationship = relationships[0]
            let relationshipOld: Bool = Defaults[.followRelationshipsOld]
            var relationshipText: String
            if user.acct == self.userToken.screenName {
                relationshipText = "関係: それはあなたです！"
            } else {
                switch (relationship.following, relationship.followed_by) {
                case (true, true):
                    relationshipText = "関係: " + (relationshipOld ? "両思い" : "相互フォロー")
                case (true, false):
                    relationshipText = "関係: " + (relationshipOld ? "片思い" : "フォローしています")
                case (false, true):
                    relationshipText = "関係: " + (relationshipOld ? "片思われ" : "フォローされています")
                case (false, false):
                    relationshipText = "関係: 無関係"
                }
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
