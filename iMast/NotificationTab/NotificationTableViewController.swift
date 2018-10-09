//
//  NotificationTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/07/30.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import AsyncDisplayKit

class NotificationTableViewController: ASViewController<ASTableNode>, ASTableDataSource, ASTableDelegate {
    
    class NotificationCell: ASCellNode {
        let notifyTypeImage = ASImageNode()
        let notifyTitleText = ASTextNode()
        let notifyBodyText = ASTextNode()
        
        init(notification: MastodonNotification) {
            super.init()
            
            self.notifyTypeImage.image = [
                "follow": R.image.follow(),
                "reblog": R.image.boost(),
                "favourite": R.image.star(),
                "mention": R.image.reply(),
            ][notification.type] ?? nil
            self.notifyTypeImage.style.width = ASDimension(unit: .points, value: 16)
            self.notifyTypeImage.style.height = ASDimension(unit: .points, value: 16)
            self.addSubnode(self.notifyTypeImage)
            
            self.notifyTitleText.attributedText = NSAttributedString(string: NSLocalizedString("tabs.notifications.cell.\(notification.type).title", comment: "").replace("%", notification.account?.acct ?? ""), attributes: [
                .font: UIFont.systemFont(ofSize: 14)
            ])
            self.notifyTitleText.truncationMode = .byTruncatingTail
            self.notifyTitleText.maximumNumberOfLines = 1
            self.addSubnode(self.notifyTitleText)
            
            self.notifyBodyText.attributedText = NSAttributedString(string: notification.status?.status.toPlainText() ?? notification.account?.name ?? "", attributes: [
                .font: UIFont.systemFont(ofSize: 17)
            ])
            self.notifyBodyText.truncationMode = .byTruncatingTail
            self.notifyBodyText.maximumNumberOfLines = 1
            self.addSubnode(self.notifyBodyText)
        }
        
        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            let main = ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .start, children: [
                self.notifyTitleText,
                self.notifyBodyText,
            ])
            main.style.flexGrow = 1
            main.style.flexShrink = 1
            
            let top = ASStackLayoutSpec(direction: .horizontal, spacing: 8, justifyContent: .start, alignItems: .start, children: [
                self.notifyTypeImage,
                main,
            ])
            
            top.style.flexGrow = 1
            top.style.flexShrink = 1

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16), child: top)
        }
    }

    var notifications:[MastodonNotification] = []
    let refreshControl = UIRefreshControl()
    
    init() {
        super.init(node: ASTableNode(style: .plain))
        self.node.dataSource = self
        self.node.delegate = self
        self.refreshControl.addTarget(self, action: #selector(self.refreshNotification), for: UIControlEvents.valueChanged)
        self.title = R.string.localizable.tabsNotificationsTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.node.view.addSubview(self.refreshControl)
        
        MastodonUserToken.getLatestUsed()?.getNoficitaions().then { notifications in
            self.notifications = notifications
            self.node.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    @objc func refreshNotification() {
        MastodonUserToken.getLatestUsed()?.getNoficitaions(sinceId: notifications.safe(0)?.id).then({ new_notifications in
            new_notifications.reversed().forEach({ (notify) in
                self.notifications.insert(notify, at: 0)
            })
            self.node.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return NotificationCell(notification: self.notifications[indexPath.row])
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let notification = self.notifications[indexPath.row]
        self.openNotify(notification)
    }
    
    func openNotify(_ notification: MastodonNotification, animated: Bool = true) {
        guard let account = notification.account else {
            return
        }
        if let status = notification.status { // 投稿つき
            if notification.type == "mention" {
                let storyboard = UIStoryboard(name: "MastodonPostDetail", bundle: nil)
                let newVC = storyboard.instantiateInitialViewController() as! MastodonPostDetailTableViewController
                newVC.load(post: status)
                self.navigationController?.pushViewController(newVC, animated: animated)
                return
            }
            let newVC = PostAndUserViewController(style: .grouped)
            newVC.posts = [status]
            newVC.users = [account]
            newVC.title = [
                "favourite": "ふぁぼられ",
                "reblog": "ブースト"
            ][notification.type]
            self.navigationController?.pushViewController(newVC, animated: animated)
        } else { // ユーザーつき
            let newVC = openUserProfile(user: account)
            self.navigationController?.pushViewController(newVC, animated: animated)
        }
    }
}
