//
//  NotificationTableViewCell.swift
//  iMast
//
//  Created by user on 2018/12/20.
//  Copyright © 2018 rinsuki. All rights reserved.
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
        default:
            return R.string.localizable.unknownNotificationType(notification.type)
        }
    }
    
    func load(notification: MastodonNotification) {
        self.notifyTypeImageView.image = NotificationTableViewCell.getIcon(type: notification.type)
        self.titleLabel.text = self.getTitle(notification: notification)
        self.descriptionLabel.text = (notification.status?.status.toPlainText() ?? notification.account?.name ?? " ").replace("\n", " ")
    }
    
}
