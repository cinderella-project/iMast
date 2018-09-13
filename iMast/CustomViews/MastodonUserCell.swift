//
//  MastodonUserCell.swift
//  iMast
//
//  Created by user on 2018/07/28.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit

class MastodonUserCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func load(user: MastodonAccount) {
        self.textLabel?.text = user.name == "" ? user.screenName : user.name
        self.detailTextLabel?.text = "@" + user.acct
        self.imageView?.sd_setImage(with: URL(string: user.avatarUrl)) { _, _, _, _ in
            self.setNeedsLayout()
        }
    }

    static func getInstance() -> MastodonUserCell {
        return MastodonUserCell(style: .subtitle, reuseIdentifier: nil)
    }
}
