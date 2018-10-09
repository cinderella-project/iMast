//
//  TimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Hydra
import ReachabilitySwift

class TimeLineTableViewController: UITableViewController {
    
    var posts:[MastodonPost] = []
    var streamingNavigationItem: UIBarButtonItem?
    var postsQueue:[MastodonPost] = []
    var cellCache:[String:MastodonPostCell] = [:]
    var isAlreadyAdded:[String:Bool] = [:]
    var readmoreCell: UITableViewCell!
    var maxPostCount = 100
    var isReadmoreLoading = false {
        didSet {
            (readmoreCell.viewWithTag(2) as! UIActivityIndicatorView).alpha = isReadmoreLoading ? 1 : 0
            (readmoreCell.viewWithTag(1) as! UIButton).alpha = isReadmoreLoading ? 0 : 1
        }
    }
    var isReadmoreEnabled = true
    var socket: WebSocketWrapper?
    let isNurunuru = Defaults[.timelineNurunuruMode]
    var timelineType: MastodonTimelineType? = nil
    var pinnedPosts: [MastodonPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        // 引っ張って更新
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refreshTimeline), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        loadTimeline().then {
            self.tableView.reloadData()
            self.websocketConnect(auto: true)
        }
        self.navigationItem.leftItemsSupplementBackButton = true
        if self.websocketEndpoint() != nil {
            self.streamingNavigationItem = UIBarButtonItem(image: UIImage(named: "StreamingStatus")!, style: .plain, target: self, action: #selector(self.streamingStatusTapped))
            self.streamingNavigationItem?.tintColor = UIColor.gray
            self.navigationItem.leftBarButtonItems = [
                self.streamingNavigationItem!
            ]
        }
        if !isNurunuru {
            DispatchQueue(label: "jp.pronama.imast.timelinequeue").async {
                while true {
                    while self.postsQueue.count == 0 {
                        usleep(500)
                    }
                    let posts = self.postsQueue.sorted(by: { (a, b) -> Bool in
                        return a.id.int > b.id.int
                    })
                    print(posts.map({ (post) -> Int64  in
                        return post.id.int
                    }))
                    self.postsQueue = []
                    DispatchQueue.main.async {
                        self._addNewPosts(posts: posts)
                    }
                    sleep(1)
                }
            }
        }
        
        readmoreCell = Bundle.main.loadNibNamed("TimeLineReadMoreCell", owner: self, options: nil)?.first as! UITableViewCell
        readmoreCell.layer.zPosition = CGFloat.infinity
        (readmoreCell.viewWithTag(1) as! UIButton).addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.readMoreTimelineTapped)))
    }
    
    func loadTimeline() -> Promise<()> {
        guard let timelineType = self.timelineType else {
            print("loadTimelineを実装するか、self.timelineTypeを定義してください。")
            return Promise.init(resolved: Void())
        }
        return MastodonUserToken.getLatestUsed()!.timeline(timelineType).then { (posts) -> Void in
            self._addNewPosts(posts: posts)
            return Void()
        }
    }
    @objc func refreshTimeline(){
        guard let timelineType = self.timelineType else {
            print("refreshTimelineを実装するか、self.timelineTypeを定義してください。")
            self.refreshControl?.endRefreshing()
            return
        }
        MastodonUserToken.getLatestUsed()!.timeline(
            timelineType,
            limit: 40,
            since: self.posts.first
        ).then { posts in
            self.addNewPosts(posts: posts)
            self.refreshControl?.endRefreshing()
        }
    }
    func readMoreTimeline(){
        guard let timelineType = self.timelineType else {
            print("readMoreTimelineを実装してください!!!!!!")
            isReadmoreLoading = false
            return
        }
        
        MastodonUserToken.getLatestUsed()!.timeline(
            timelineType,
            limit: 40,
            max: self.posts.last
        ).then { posts in
            self.appendNewPosts(posts: posts)
            self.isReadmoreLoading = false
        }
    }
    
    @objc func readMoreTimelineTapped(sender: UITapGestureRecognizer) {
        isReadmoreLoading = true
        readMoreTimeline()
    }
    
    func addNewPosts(posts: [MastodonPost]) {
        if isNurunuru {
            self._addNewPosts(posts: posts)
        } else {
            posts.forEach { (post) in
                postsQueue.append(post)
            }
        }
    }
    
    func _addNewPosts(posts posts_: [MastodonPost]) {
        if posts_.count == 0 {
            return
        }
        let myAccount = MastodonUserToken.getLatestUsed()!.screenName!
        let posts: [MastodonPost] = posts_.sorted(by: { (a, b) -> Bool in
            return a.id.int > b.id.int
        }).filter({ (post) -> Bool in
//            if ((post.sensitive && myAccount != post.account.acct) || post.repost?.sensitive ?? false) && post.spoilerText == "" { // Appleに怒られたのでNSFWだったら隠す
//                return false
//            }
            if isAlreadyAdded[post.id.string] != true {
                isAlreadyAdded[post.id.string] = true
                return true
            }
            return false
        })
        posts.forEach { post in
            _ = getCell(post:post)
        }
        
        /*
        if self.posts.count == 0 {
            self.posts = posts
            tableView.reloadData()
            return
        }
         */
        let usingAnimationFlag = self.posts.count != 0
        if usingAnimationFlag {
            self.tableView.beginUpdates()
        }
        var cnt = 0
        var indexPaths: [IndexPath] = []
        var deleteIndexPaths: [IndexPath] = []
        posts.forEach { (post) in
            self.posts.insert(post, at: cnt)
            indexPaths.append(IndexPath(row: cnt, section: 1))
            cnt += 1

        }
        if self.posts.count - cnt > maxPostCount { // メモリ節約
            for i in (maxPostCount+cnt)..<self.posts.count {
                deleteIndexPaths.append(IndexPath(row: i - cnt, section: 1))
            }
            self.posts = Array(self.posts.prefix(maxPostCount + cnt))
        }
        if usingAnimationFlag {
            self.tableView.insertRows(at: indexPaths, with: .none)
            self.tableView.deleteRows(at: deleteIndexPaths, with: .none)
            self.tableView.endUpdates()
        } else {
            self.tableView.reloadData()
        }
    }
    
    func websocketEndpoint() -> String? {
        return nil
    }
    
    func websocketConnect(auto: Bool) {
        if auto {
            let conditions = Defaults[.streamingAutoConnect]
            if conditions == "no" {
                return
            } else if conditions == "wifi" {
                if !(Reachability.init()?.isReachableViaWiFi ?? false) {
                    return
                }
            }
        }
        guard let webSocketEndpoint = self.websocketEndpoint() else {
            return
        }
        getWebSocket(endpoint: webSocketEndpoint).then { socket in
            socket.event.connect.on {
                self.streamingNavigationItem?.tintColor = nil
            }
            socket.event.disconnect.on { _ in
                self.streamingNavigationItem?.tintColor = UIColor(red: 1, green: 0.3, blue: 0.15, alpha: 1)
            }
            socket.event.message.on { text in
                var object = JSON(parseJSON: text)
                if object["event"].string == "update" {
                    object["payload"] = JSON(parseJSON: object["payload"].string ?? "{}")
                    /*
                     self.tableView.beginUpdates()
                     self.posts.insert(object["payload"], at: 0)
                     let indexPath = IndexPath(row: 0, section: 0)
                     self.tableView.insertRows(at: [indexPath], with: .automatic)
                     self.tableView.endUpdates()
                     */
                    self.addNewPosts(posts: [try! MastodonPost.decode(json: object["payload"])])
                } else if object["event"].string == "delete" {
                    var tootFound = false
                    self.posts = self.posts.filter({ (post) -> Bool in
                        if post.id.string != object["payload"].stringValue {
                            return true
                        }
                        tootFound = true
                        return false
                    })
                    if tootFound {
                        for section in [0, 1] {
                            self.cellCache["\(section):\(object["payload"].stringValue)"] = nil
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    print(object)
                }
            }
            self.socket = socket
        }
    }
    
    @objc func streamingStatusTapped() {
        print("called")
        let nowStreamConnected = (socket?.webSocket.isConnected ?? false)
        let alertVC = UIAlertController(
            title: R.string.localizable.timelineStreamingTitle(),
            message: R.string.localizable.timelineStreamingStatusBase().replace("%", nowStreamConnected ? R.string.localizable.timelineStreamingStatusConnected() : R.string.localizable.timelineStreamingStatusNotConnected()),
            preferredStyle: .actionSheet
        )
        alertVC.popoverPresentationController?.sourceView = (self.streamingNavigationItem?.value(forKey: "view") as! UIView)
        alertVC.popoverPresentationController?.sourceRect = (self.streamingNavigationItem?.value(forKey: "view") as! UIView).frame
        if nowStreamConnected {
            alertVC.addAction(UIAlertAction(title: R.string.localizable.timelineStreamingActionDisconnect(), style: .default, handler: { (action) in
                self.socket?.disconnect()
            }))
        } else {
            alertVC.addAction(UIAlertAction(title: R.string.localizable.timelineStreamingActionConnect(), style: .default, handler: { (action) in
                self.websocketConnect(auto: false)
            }))
        }
        alertVC.addAction(UIAlertAction(title: R.string.localizable.timelineStreamingActionRefresh(),  style: .default, handler: { (action) in
            let isStreamingConnectingNow = self.socket?.webSocket.isConnected ?? false
            if isStreamingConnectingNow {
                self.socket?.disconnect()
            }
            self.posts = []
            self.tableView.reloadData()
            self.cellCache = [:]
            self.isAlreadyAdded = [:]
            self.loadTimeline().then {
                print(self.posts)
                self.posts.forEach({ (post) in
                    _ = self.getCell(post: post)
                })
                self.tableView.reloadData()
                if isStreamingConnectingNow {
                    self.socket?.connect()
                }
            }
        }))
        alertVC.addAction(UIAlertAction(title: R.string.localizable.timelineStreamingActionCancel(), style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return pinnedPosts.count
        }
        return posts.count == 0 ? 0 : posts.count + (isReadmoreEnabled ? 1 : 0)
    }
    
    func getCell(post: MastodonPost, section: Int = 1) -> UITableViewCell {
        let cellHash = "\(section):\(post.id.string)"
        if let cell = cellCache[cellHash] {
            return cell
        }
        let postView = MastodonPostCell.getInstance(owner: self)
        postView.pinned = section == 0  
        // Configure the cell...
        postView.load(post: post)
        cellCache[cellHash] = postView
        return postView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == posts.count && posts.count != 0 {
            return readmoreCell
        }
        let post = (indexPath.section == 0 ? pinnedPosts : posts)[indexPath.row]
        return getCell(post: post, section: indexPath.section)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 && indexPath.row >= self.posts.count {
            return []
        }
        let post = (indexPath.section == 0 ? pinnedPosts : posts)[indexPath.row]
        // Reply
        let replyAction = UITableViewRowAction(style: .normal, title: "返信"){
            (action, index) -> Void in
            tableView.isEditing = false
            print("reply")
        }
        // ブースト
        let boostAction = UITableViewRowAction(style: .normal, title: "ブースト"){
            (action,index) -> Void in
            MastodonUserToken.getLatestUsed()!.repost(post: post).then { post_ in
                let post = post_.repost!
                var indexs: [IndexPath] = []
                self.pinnedPosts = self.pinnedPosts.enumerated().map({ (index, map_post) -> MastodonPost in
                    if map_post.id == post.id {
                        indexs.append(IndexPath(row: index, section: 0))
                        return post
                    } else {
                        return map_post
                    }
                })
                self.posts = self.posts.enumerated().map({ (index, map_post) -> MastodonPost in
                    if map_post.id == post.id {
                        indexs.append(IndexPath(row: index, section: 1))
                        return post
                    } else {
                        return map_post
                    }
                })
                for section in [0, 1] {
                    if let cell = self.cellCache["\(section):\(post.id.string)"] {
                        cell.load(post: post)
                    }
                }
                action.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                tableView.isEditing = false
            }
            print("repost")
        }
        // like
        let likeAction = UITableViewRowAction(style: .normal, title: "ふぁぼ"){
            (action,index) -> Void in
            MastodonUserToken.getLatestUsed()!.favourite(post: post).then { post in
                var indexs: [IndexPath] = []
                self.pinnedPosts = self.pinnedPosts.enumerated().map({ (index, map_post) -> MastodonPost in
                    if map_post.id == post.id {
                        indexs.append(IndexPath(row: index, section: 0))
                        return post
                    } else {
                        return map_post
                    }
                })
                self.posts = self.posts.enumerated().map({ (index, map_post) -> MastodonPost in
                    if map_post.id == post.id {
                        indexs.append(IndexPath(row: index, section: 1))
                        return post
                    } else {
                        return map_post
                    }
                })
                for section in [0, 1] {
                    if let cell = self.cellCache["\(section):\(post.id.string)"] {
                        cell.load(post: post)
                    }
                }
                action.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                tableView.isEditing = false
            }
            print("like")
        }
        replyAction.backgroundColor = UIColor.init(red: 0.95, green: 0.4, blue: 0.4, alpha: 1)
        if post.reposted {
            boostAction.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        } else {
            boostAction.backgroundColor = UIColor.init(red: 0.3, green: 0.95, blue: 0.3, alpha: 1)
        }
        if post.favourited {
            likeAction.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        } else {
            likeAction.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.3, alpha: 1)
        }
        return [
            // replyAction,
            boostAction,
            likeAction
        ].reversed()
    }
    
    func appendNewPosts(posts: [MastodonPost]) {
        var rows:[IndexPath] = []
        posts.forEach { (post) in
            _ = self.getCell(post: post)
            self.posts.append(post)
            rows.append(IndexPath(row: self.posts.count-1, section: 1))
        }
        self.tableView.insertRows(at: rows, with: .automatic)
        self.maxPostCount += posts.count
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return indexPath.row < (indexPath.section == 0 ? self.pinnedPosts : self.posts).count
    }
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    

}
