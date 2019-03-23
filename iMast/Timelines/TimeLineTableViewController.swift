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
import Reachability
import SafariServices
import Ikemen
import SnapKit
import Mew

class TimeLineTableViewController: UIViewController, Instantiatable {
    var environment: Environment
    
    typealias Input = UITableView.Style
    
    typealias Environment = MastodonUserToken
    
    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    
    var posts: [MastodonPost] = []
    var streamingNavigationItem: UIBarButtonItem?
    var postsQueue: [MastodonPost] = []
    var isAlreadyAdded: [String: Bool] = [:]
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
    var timelineType: MastodonTimelineType?
    var pinnedPosts: [MastodonPost] = []
    var postFabButton = UIButton()
    var isNewPostAvailable = false
    
    required init(with input: Input = .plain, environment: Environment = MastodonUserToken.getLatestUsed()!) {
        tableView = UITableView(frame: .zero, style: input)
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = tableView ※ {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.width.height.equalTo(self.view)
            }
            
            $0.estimatedRowHeight = 100
            $0.rowHeight = UITableView.automaticDimension

            // 引っ張って更新
            $0.refreshControl = refreshControl ※ {
                $0.addTarget(self, action: #selector(self.refreshTimeline), for: .valueChanged)
            }
            
            $0.delegate = self
            $0.dataSource = self
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        TableViewCell<MastodonPostCellViewController>.register(to: tableView)
        
        loadTimeline().then {
            self.tableView.reloadData()
            self.websocketConnect(auto: true)
        }
        
        self.navigationItem.leftItemsSupplementBackButton = true
        if self.websocketEndpoint() != nil {
            self.streamingNavigationItem = UIBarButtonItem(image: UIImage(named: "StreamingStatus")!, style: .plain, target: self, action: #selector(self.streamingStatusTapped))
            self.streamingNavigationItem?.tintColor = UIColor.gray
            self.navigationItem.leftBarButtonItems = [
                self.streamingNavigationItem!,
            ]
        }
        if !isNurunuru {
            DispatchQueue(label: "jp.pronama.imast.timelinequeue").async {
                while true {
                    while self.postsQueue.count == 0 {
                        usleep(500)
                    }
                    let posts = self.postsQueue.sorted(by: { (a, b) -> Bool in
                        return a.id.compare(b.id) == .orderedDescending
                    })
                    print(posts.map { $0.id.raw })
                    self.postsQueue = []
                    DispatchQueue.main.async {
                        self._addNewPosts(posts: posts)
                    }
                    sleep(1)
                }
            }
        }
        
        if isNewPostAvailable {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.post(), style: .plain) { _ in
                self.openNewPostVC()
            }
            
            if Defaults[.postFabEnabled] {
                _ = self.postFabButton ※ {
                    $0.setTitle("投稿", for: .normal)
                    $0.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                    $0.backgroundColor = self.view.tintColor
                    
                    self.view.addSubview(self.postFabButton)
                    let size = 56
                    $0.snp.makeConstraints { make in
                        let offset = 16
                        // X
                        switch Defaults[.postFabLocation] {
                        case .leftCenter, .leftBottom:
                            make.left.equalTo(self.fakeSafeAreaLayoutGuide).offset(offset)
                        case .rightCenter, .rightBottom:
                            make.right.equalTo(self.fakeSafeAreaLayoutGuide).offset(-offset)
                        case .centerBottom:
                            make.centerX.equalTo(self.fakeSafeAreaLayoutGuide)
                        }
                        
                        // Y
                        switch Defaults[.postFabLocation] {
                        case .leftCenter, .rightCenter:
                            make.centerY.equalTo(self.fakeSafeAreaLayoutGuide)
                        case .leftBottom, .centerBottom, .rightBottom:
                            make.bottom.equalTo(self.fakeSafeAreaLayoutGuide).offset(-offset)
                        }
                        make.width.height.equalTo(size)
                    }
                    $0.layer.cornerRadius = CGFloat(size / 2)
                    
                    $0.layer.shadowOpacity = 0.25
                    $0.layer.shadowRadius = 2
                    $0.layer.shadowColor = UIColor.black.cgColor
                    $0.layer.shadowOffset = CGSize(width: 0, height: 2)
                    
                    $0.addTarget(self, action: #selector(self.postFabTapped(sender:)), for: .touchUpInside)
                }
            }
        }

        readmoreCell = Bundle.main.loadNibNamed("TimeLineReadMoreCell", owner: self, options: nil)?.first as! UITableViewCell
        readmoreCell.layer.zPosition = CGFloat(FLT_MAX)
        (readmoreCell.viewWithTag(1) as! UIButton).addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.readMoreTimelineTapped)))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            self.socket?.disconnect()
        }
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
    
    @objc func refreshTimeline() {
        guard let timelineType = self.timelineType else {
            print("refreshTimelineを実装するか、self.timelineTypeを定義してください。")
            self.refreshControl.endRefreshing()
            return
        }
        MastodonUserToken.getLatestUsed()!.timeline(
            timelineType,
            limit: 40,
            since: self.posts.first
        ).then { posts in
            self.addNewPosts(posts: posts)
            self.refreshControl.endRefreshing()
        }
    }
    
    func readMoreTimeline() {
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
    
    func processNewPostVC(newPostVC: NewPostViewController) {
        // オーバーライド用
    }
    
    func openNewPostVC() {
        let vc = R.storyboard.newPost.instantiateInitialViewController()!
        self.processNewPostVC(newPostVC: vc)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func postFabTapped(sender: UITapGestureRecognizer) {
        self.openNewPostVC()
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
            return a.id.compare(b.id) == .orderedDescending
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
//            _ = getCell(post: post)
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
            title: R.string.localizable.streaming(),
            message: R.string.localizable.streamingStatus(
                nowStreamConnected
                ? R.string.localizable.connected()
                : R.string.localizable.notConnected()
            ),
            preferredStyle: .actionSheet
        )
        alertVC.popoverPresentationController?.barButtonItem = self.streamingNavigationItem
        if nowStreamConnected {
            alertVC.addAction(UIAlertAction(title: R.string.localizable.disconnect(), style: .default, handler: { (action) in
                self.socket?.disconnect()
            }))
        } else {
            alertVC.addAction(UIAlertAction(title: R.string.localizable.connect(), style: .default, handler: { (action) in
                self.websocketConnect(auto: false)
            }))
        }
        alertVC.addAction(UIAlertAction(title: R.string.localizable.refetch(), style: .default, handler: { (action) in
            let isStreamingConnectingNow = self.socket?.webSocket.isConnected ?? false
            if isStreamingConnectingNow {
                self.socket?.disconnect()
            }
            self.posts = []
            self.tableView.reloadData()
            self.isAlreadyAdded = [:]
            self.loadTimeline().then {
                self.tableView.reloadData()
                if isStreamingConnectingNow {
                    self.socket?.connect()
                }
            }
        }))
        alertVC.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func getCell(post: MastodonPost, section: Int = 1) -> UITableViewCell {
//        let postView = MastodonPostCell.getInstance(owner: self)
//        postView.pinned = section == 0
//        // Configure the cell...
//        postView.load(post: post)
//
//        return postView
//    }
//
    func appendNewPosts(posts: [MastodonPost]) {
        var rows: [IndexPath] = []
        posts.forEach { (post) in
//            _ = self.getCell(post: post)
            self.posts.append(post)
            rows.append(IndexPath(row: self.posts.count-1, section: 1))
        }
        self.tableView.insertRows(at: rows, with: .automatic)
        self.maxPostCount += posts.count
    }
}

extension TimeLineTableViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return pinnedPosts.count
        }
        return posts.count == 0 ? 0 : posts.count + (isReadmoreEnabled ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == posts.count && posts.count != 0 {
            return readmoreCell
        }
        let post = (indexPath.section == 0 ? pinnedPosts : posts)[indexPath.row]
        return TableViewCell<MastodonPostCellViewController>.dequeued(
            from: self.tableView,
            for: indexPath,
            input: MastodonPostCellViewController.Input(post: post, pinned: indexPath.section == 0),
            parentViewController: self
        )
//        return getCell(post: post, section: indexPath.section)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return indexPath.row < (indexPath.section == 0 ? self.pinnedPosts : self.posts).count
    }
}

extension TimeLineTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 && indexPath.row >= self.posts.count {
            return []
        }
        let post = (indexPath.section == 0 ? pinnedPosts : posts)[indexPath.row]
        // Reply
        let replyAction = UITableViewRowAction(style: .normal, title: "返信") { (action, index) -> Void in
            tableView.isEditing = false
            print("reply")
        }
        // ブースト
        let boostAction = UITableViewRowAction(style: .normal, title: "ブースト") { (action, index) -> Void in
            MastodonUserToken.getLatestUsed()!.repost(post: post).then { post_ in
                let post = post_.repost!
                self.updatePost(from: post, includeRepost: true)
                action.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                tableView.isEditing = false
            }
            print("repost")
        }
        // like
        let likeAction = UITableViewRowAction(style: .normal, title: "ふぁぼ") { (action, index) -> Void in
            MastodonUserToken.getLatestUsed()!.favourite(post: post).then { post in
                self.updatePost(from: post, includeRepost: true)
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
            likeAction,
            ].reversed()
    }
    
    func updatePost(from: MastodonPost, includeRepost: Bool) {
        var indexPaths = [] as [IndexPath]
        
        func processPost(section: Int, posts: inout [MastodonPost]) {
            for (row, post) in posts.enumerated() {
                if from.id == post.id {
                    posts[row] = from
                } else if includeRepost, from.id == post.repost?.id {
                    posts[row] = from
                } else {
                    continue
                }
                indexPaths.append(IndexPath(row: row, section: section))
            }
        }
        
        processPost(section: 0, posts: &self.pinnedPosts)
        processPost(section: 1, posts: &self.posts)
        
        self.tableView.reloadRows(
            at: indexPaths,
            with: .right
        )
    }
}
