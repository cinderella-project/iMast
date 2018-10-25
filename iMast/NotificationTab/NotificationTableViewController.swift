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
            
            let notifyBody = (notification.status?.status.toPlainText() ?? notification.account?.name ?? " ").replace("\n", " ")
            self.notifyBodyText.attributedText = NSAttributedString(string: notifyBody, attributes: [
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
    
    class NotificationReadmoreCell: ASCellNode {
        enum State {
            case enabled
            case loading
            case nothingMore
        }
        let textNode = ASTextNode()
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        var indicatorNode: ASDisplayNode!
        
        var state: State = .enabled { didSet {
            self.textNode.isHidden = state == .loading
            if oldValue != state {
                if state != .loading {
                    self.indicatorView.stopAnimating()
                } else {
                    self.indicatorView.startAnimating()
                }
                switch state {
                case .enabled:
                    self.textNode.attributedText = NSAttributedString(string: R.string.localizable.tabsNotificationsCellReadmoreTitle(), attributes: [
                        .font: UIFont.systemFont(ofSize: 15),
                        .foregroundColor: self.tintColor,
                    ])
                case .nothingMore:
                    self.textNode.attributedText = NSAttributedString(string: R.string.localizable.tabsNotificationsCellReadmoreDisabledTitle(), attributes: [
                        .font: UIFont.systemFont(ofSize: 15),
                        .foregroundColor: UIColor.darkGray,
                    ])
                default:
                    break
                }
            }
        }}
        
        override init() {
            super.init()
            self.indicatorNode = ASDisplayNode { () -> UIView in
                return self.indicatorView
            }

            self.addSubnode(self.textNode)
            self.addSubnode(self.indicatorNode)
            self.style.height = ASDimensionMake(44)
            self.selectionStyle = .none
        }
        
        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            return ASOverlayLayoutSpec(child: ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self.textNode), overlay: self.indicatorNode)
        }
    }

    var notifications:[MastodonNotification] = []
    let refreshControl = UIRefreshControl()
    let readmoreCell = NotificationReadmoreCell()
    
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
        
        self.readmoreCell.state = .loading
        MastodonUserToken.getLatestUsed()?.getNoficitaions(sinceId: nil).then { notifications in
            self.readmoreCell.state = notifications.count > 0 ? .enabled : .nothingMore
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
        return 2
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notifications.count
        } else {
            return 1
        }
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
        if indexPath.section == 0 {
            return NotificationCell(notification: self.notifications[indexPath.row])
        } else {
            return self.readmoreCell
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let notification = self.notifications[indexPath.row]
            self.openNotify(notification)
        } else {
            // read more
            self.readMore()
        }
    }
    
    var oldFetchedTime = Date.timeIntervalSinceReferenceDate
    var oldOffset: CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let diff = maxOffset - currentOffset
        var bottomHeight = scrollView.contentInset.bottom
        if #available(iOS 11.0, *) {
            bottomHeight = scrollView.adjustedContentInset.bottom
        }
        
        let diffTrue = Int(diff + bottomHeight)
        print(diff, diffTrue, bottomHeight)
        let nowTime = Date.timeIntervalSinceReferenceDate
        
        let diffTime = nowTime - self.oldFetchedTime
        if diffTime > 0.1 {
            self.oldFetchedTime = nowTime
            let speed = currentOffset - oldOffset
            if speed > 10 {
                let estOffset = diffTrue - Int(speed / CGFloat(diffTime)) // 1秒後も同じ速さでスクロールしていた場合の位置
                if estOffset < 200 {
                    self.readMore()
                }
            }
            self.oldFetchedTime = nowTime
            self.oldOffset = currentOffset
        }
        
        if diffTrue < 200 {
            self.readMore()
        }
    }
    
    func readMore() {
        guard self.readmoreCell.state == .enabled else {
            return
        }
        
        self.readmoreCell.state = .loading
        MastodonUserToken.getLatestUsed()?.getNoficitaions(maxId: self.notifications.last?.id).then { notifications in
            let oldCount = self.notifications.count
            self.notifications.append(contentsOf: notifications)
            self.node.performBatchUpdates({
                for i in oldCount..<oldCount + notifications.count {
                    self.node.insertRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                }
            }, completion: nil)
            self.readmoreCell.state = notifications.count > 0 ? .enabled : .nothingMore
        }
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
