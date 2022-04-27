//
//  MastodonUserCell.swift
//  iMast
//
//  Created by rinsuki on 2018/07/28.
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
        self.imageView?.loadImage(from: URL(string: user.avatarUrl)) {
            self.setNeedsLayout()
        }
    }

    static func getInstance(user: MastodonAccount? = nil) -> MastodonUserCell {
        let cell = MastodonUserCell(style: .subtitle, reuseIdentifier: nil)
        if let user = user {
            cell.load(user: user)
        }
        return cell
    }
}
