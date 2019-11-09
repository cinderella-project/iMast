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
            return R.image.boost()
        case "favourite":
            return R.image.star()
        case "mention":
            return R.image.reply()
        case "follow":
            return R.image.follow()
        case "poll":
            return R.image.poll()
        default:
            return nil
        }
    }
    
    func getTitle(notification: MastodonNotification) -> String {
        let acct = notification.account?.acct ?? ""
        switch notification.type {
        case "reblog":
            return R.string.localizable.boostedYourToot(acct)
        case "favourite":
            return R.string.localizable.favouritedYourToot(acct)
        case "mention":
            return R.string.localizable.mentionedYou(acct)
        case "follow":
            return R.string.localizable.followedYou(acct)
        case "poll":
            if MastodonUserToken.getLatestUsed()?.screenName == notification.account?.acct {
                return R.string.localizable.myPollEnded()
            } else {
                return R.string.localizable.votedPollEnded()
            }
        default:
            return R.string.localizable.unknownNotificationType(notification.type)
        }
    }
    
    func load(notification: MastodonNotification) {
        self.notifyTypeImageView.image = NotificationTableViewCell.getIcon(type: notification.type)
        self.titleLabel.text = self.getTitle(notification: notification)
        self.descriptionLabel.text = (notification.status?.status.toPlainText() ?? notification.account?.name ?? " ").replacingOccurrences(of: "\n", with: " ")
    }
    
}
