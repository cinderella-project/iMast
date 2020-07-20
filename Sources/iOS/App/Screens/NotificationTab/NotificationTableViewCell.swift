//
//  NotificationTableViewCell.swift
//  iMast
//
//  Created by rinsuki on 2018/12/20.
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

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var notifyTypeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func getIcon(type: String) -> UIImage? {
        switch type {
        case "reblog":
            return Asset.boost.image
        case "favourite":
            return Asset.star.image
        case "mention":
            return Asset.reply.image
        case "follow":
            return Asset.follow.image
        case "poll":
            return Asset.poll.image
        default:
            return nil
        }
    }
    
    func getTitle(notification: MastodonNotification) -> String {
        let acct = notification.account?.acct ?? ""
        switch notification.type {
        case "reblog":
            return L10n.Notification.Types.boost(acct)
        case "favourite":
            return L10n.Notification.Types.favourite(acct)
        case "mention":
            return L10n.Notification.Types.mention(acct)
        case "follow":
            return L10n.Notification.Types.follow(acct)
        case "poll":
            if MastodonUserToken.getLatestUsed()?.screenName == notification.account?.acct {
                return L10n.Notification.Types.Poll.owner
            } else {
                return L10n.Notification.Types.Poll.notowner
            }
        case "follow_request":
            return L10n.Notification.Types.followRequest(acct)
        default:
            return L10n.Notification.Types.unknown(notification.type)
        }
    }
    
    func load(notification: MastodonNotification) {
        self.notifyTypeImageView.image = NotificationTableViewCell.getIcon(type: notification.type)
        self.titleLabel.text = self.getTitle(notification: notification)
        self.descriptionLabel.text = (notification.status?.status.toPlainText() ?? notification.account?.name ?? " ").replacingOccurrences(of: "\n", with: " ")
    }
    
}
