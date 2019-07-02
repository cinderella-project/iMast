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
    enum TableSection: String, Hashable {
        case pinned
        case posts
        case readMore
    }
    
    enum TableBody: Hashable {
        case post(content: MastodonPost, pinned: Bool)
        case readMore
    }
    
    var environment: Environment
    
    typealias Input = UITableView.Style
    
    typealias Environment = MastodonUserToken
    
    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    
    var diffableDataSource: UITableViewDiffableDataSource<TableSection, TableBody>!
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
    var socket: WebSocketWrapper?
    let isNurunuru = Defaults[.timelineNurunuruMode]
    var timelineType: MastodonTimelineType?
    var postFabButton = UIButton()
    
    var isRefreshEnabled = true
    var isReadmoreEnabled = true
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
            if isRefreshEnabled {
                $0.refreshControl = refreshControl ※ {
                    $0.addTarget(self, action: #selector(self.refreshTimeline), for: .valueChanged)
                }
            }
            
            $0.delegate = self
        }

        TableViewCell<MastodonPostCellViewController>.register(to: tableView)
        
        readmoreCell = Bundle.main.loadNibNamed("TimeLineReadMoreCell", owner: self, options: nil)?.first as! UITableViewCell
        readmoreCell.layer.zPosition = CGFloat(FLT_MAX)
        (readmoreCell.viewWithTag(1) as! UIButton).addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.readMoreTimelineTapped)))

        
        self.diffableDataSource = UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, target) -> UITableViewCell? in
            switch target {
            case .post(let content, let pinned):
                return TableViewCell<MastodonPostCellViewController>.dequeued(
                    from: tableView,
                    for: indexPath,
                    input: .init(post: content, pinned: pinned),
                    parentViewController: self
                )
            case .readMore:
                return self.readmoreCell
            }
        }
        self.tableView.dataSource = self.diffableDataSource
        
        _ = self.diffableDataSource.snapshot() ※ {
            $0.appendSections([.pinned, .posts, .readMore])
            if self.isReadmoreEnabled {
                $0.appendItems([.readMore], toSection: .readMore)
            }
            self.diffableDataSource.apply($0, animatingDifferences: false)
        }
        
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
        let snapshot = self.diffableDataSource.snapshot()
        var pointer: MastodonPost?
        if let v = snapshot.itemIdentifiers(inSection: .posts).first,
            case .post(let content, _) = v {
            pointer = content
        } else {
            pointer = nil
        }
        MastodonUserToken.getLatestUsed()!.timeline(
            timelineType,
            limit: 40,
            since: pointer
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
        let snapshot = self.diffableDataSource.snapshot()
        var pointer: MastodonPost?
        if let v = snapshot.itemIdentifiers(inSection: .posts).last,
            case .post(let content, _) = v {
            pointer = content
        } else {
            pointer = nil
        }
        MastodonUserToken.getLatestUsed()!.timeline(
            timelineType,
            limit: 40,
            max: pointer
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
        let posts: [MastodonPost] = posts_.sorted(by: { (a, b) -> Bool in
            return a.id.compare(b.id) == .orderedDescending
        }).filter({ (post) -> Bool in
            if isAlreadyAdded[post.id.string] != true {
                isAlreadyAdded[post.id.string] = true
                return true
            }
            return false
        })
        
        let snapshot = self.diffableDataSource.snapshot()
        snapshot.prependItems(
            posts.map { .post(content: $0, pinned: false) },
            section: .posts
        )
        if snapshot.numberOfItems(inSection: .posts) > maxPostCount { // メモリ節約
            let items = snapshot.itemIdentifiers(inSection: .posts)
            snapshot.deleteItems(Array(items.dropFirst(maxPostCount)))
        }
        self.diffableDataSource.apply(snapshot, animatingDifferences: true)
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
                    self.addNewPosts(posts: [try! MastodonPost.decode(json: object["payload"])])
                } else if object["event"].string == "delete" {
                    let deletedTootID = object["payload"].stringValue
                    let snapshot = self.diffableDataSource.snapshot()
                    var deletePosts: [TableBody] = []

                    for body in snapshot.itemIdentifiers(inSection: .posts) {
                        if case .post(let content, _) = body {
                            if content.id.string == deletedTootID {
                                deletePosts.append(body)
                            } else if content.repost?.id.string == deletedTootID {
                                deletePosts.append(body)
                            }
                        }
                    }

                    if deletePosts.count > 0 {
                        self.diffableDataSource.apply(snapshot, animatingDifferences: true)
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
            let snapshot = self.diffableDataSource.snapshot()
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .posts))
            self.diffableDataSource.apply(snapshot, animatingDifferences: false)
            self.isAlreadyAdded = [:]
            self.loadTimeline().then {
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
        let snapshot = self.diffableDataSource.snapshot()
        snapshot.appendItems(posts.map { .post(content: $0, pinned: false) }, toSection: .posts)
        self.diffableDataSource.apply(snapshot, animatingDifferences: true)
        self.maxPostCount += posts.count
    }
}

extension TimeLineTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard case .post(let post, _) = self.diffableDataSource.itemIdentifier(for: indexPath) else {
            return []
        }
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = self.diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item {
        case .post(let content, _):
            let postDetailVC = R.storyboard.mastodonPostDetail.instantiateInitialViewController()!
            postDetailVC.load(post: content)
            self.navigationController?.pushViewController(postDetailVC, animated: true)
        case .readMore:
            // TODO: read more 処理をこっちに移すべき
            break
        }
    }
    
    func updatePost(from: MastodonPost, includeRepost: Bool) {
        var indexPaths = [] as [IndexPath]
        
        func processPost(section: Int, posts: inout [MastodonPost]) {
            for (row, post) in posts.enumerated() {
                if from.id == post.id {
                    posts[row] = from
                } else if includeRepost, from.id == post.repost?.id {
                    var post = posts[row]
                    post.repost = from
                    posts[row] = post
                } else {
                    continue
                }
                indexPaths.append(IndexPath(row: row, section: section))
            }
        }
        
//        processPost(section: 0, posts: &self.pinnedPosts)
//        processPost(section: 1, posts: &self.posts)
        
        self.tableView.reloadRows(
            at: indexPaths,
            with: .right
        )
    }
}
