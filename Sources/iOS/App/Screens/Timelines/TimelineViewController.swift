//
//  TimelineViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/24.
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
import Hydra
import Ikemen
import SnapKit
import Mew
import iMastiOSCore

class TimelineViewController: UIViewController, Instantiatable {
    enum TableSection: String, Hashable {
        case pinned
        case posts
    }
    
    enum TableBody: Hashable {
        case post(id: MastodonID, pinned: Bool)
    }
    
    let environment: Environment
    
    typealias Input = UITableView.Style
    
    typealias Environment = MastodonUserToken
    
    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    
    var diffableDataSource: TableViewDiffableDataSource<TableSection, TableBody>!
    var streamingNavigationItem: UIBarButtonItem?
    var postsQueue: [MastodonPost] = []
    var isAlreadyAdded: [String: Bool] = [:]
    let readmoreView = ReadmoreView()
    var maxPostCount = 100
    var socket: WebSocketWrapper?
    var timelineType: MastodonTimelineType?
    var postFabButton = PostFabButton()
    
    let updateDataSourceQueue = DispatchQueue(label: "jp.pronama.imast.timeline.update-data-source", qos: .userInteractive)
    
    var isRefreshEnabled = true
    var isReadmoreEnabled = true
    var isNewPostAvailable = false
    
    required init(with input: Input = .plain, environment: Environment) {
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
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.width.height.equalTo(view)
            }
            
            $0.estimatedRowHeight = 100
            $0.rowHeight = UITableView.automaticDimension

            // 引っ張って更新
            if isRefreshEnabled {
                $0.refreshControl = refreshControl ※ {
                    $0.addTarget(self, action: #selector(refreshTimeline), for: .valueChanged)
                }
            }
            
            $0.delegate = self
        }

        TableViewCell<MastodonPostWrapperViewController<MastodonPostCellViewController>>.register(to: tableView)
        
        diffableDataSource = .init(tableView: tableView) { [weak self] (tableView, indexPath, target) -> UITableViewCell? in
            guard let strongSelf = self else {
                return nil
            }
            switch target {
            case .post(let id, let pinned):
                let cell = TableViewCell<MastodonPostWrapperViewController<MastodonPostCellViewController>>.dequeued(
                    from: tableView,
                    for: indexPath,
                    input: (id: id, pinned: pinned),
                    parentViewController: strongSelf
                )
                return cell
            }
        }
        diffableDataSource.canEditRowAt = true
        tableView.dataSource = diffableDataSource
        tableView.separatorInset = .zero
        // in iOS 15, UITableViewCell didn't apply separatorInset to first separator
        // TODO: we should find right way to apply separatorInset to first separator and remove this workaround
        tableView.tableHeaderView = UIView(frame: .zero)
        if isReadmoreEnabled {
            readmoreView.target = self
            readmoreView.action = #selector(readmoreTapped)
            readmoreView.setTableView(tableView)
        }
        
        _ = diffableDataSource.snapshot() ※ { snapshot in
            snapshot.appendSections([.pinned, .posts])
            updateDataSourceQueue.sync {
                diffableDataSource.apply(snapshot, animatingDifferences: false)
            }
        }
        
        performLoadTimeline {
            self.tableView.reloadData()
            self.websocketConnect(auto: true)
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.leftItemsSupplementBackButton = true
        if websocketEndpoint() != nil {
            streamingNavigationItem = UIBarButtonItem(image: UIImage(systemName: "bolt"), style: .plain, target: nil, action: nil)
            streamingNavigationItem?.tintColor = UIColor.gray
            setStreamingMenu(connected: false)
            navigationItem.leftBarButtonItems = [
                streamingNavigationItem!,
            ]
        }
        
        if isNewPostAvailable {
            navigationItem.rightBarButtonItem = .init(
                title: L10n.Localizable.post, style: .plain,
                target: self, action: #selector(openNewPostVC)
            )
            
            addKeyCommand(.init(
                title: L10n.NewPost.KeyCommand.Open.title,
                action: #selector(openNewPostVC),
                input: "n", modifierFlags: .command,
                discoverabilityTitle: L10n.NewPost.KeyCommand.Open.description
            ))
            
            if Defaults.postFabEnabled {
                _ = postFabButton ※ {
                    view.addSubview(postFabButton)
                    $0.snp.makeConstraints { make in
                        let offset = 16
                        // X
                        switch Defaults.postFabLocation {
                        case .leftCenter, .leftBottom:
                            make.left.equalTo(view.safeAreaLayoutGuide).offset(offset)
                        case .rightCenter, .rightBottom:
                            make.right.equalTo(view.safeAreaLayoutGuide).offset(-offset)
                        case .centerBottom:
                            make.centerX.equalTo(view.safeAreaLayoutGuide)
                        }
                        
                        // Y
                        switch Defaults.postFabLocation {
                        case .leftCenter, .rightCenter:
                            make.centerY.equalTo(view.safeAreaLayoutGuide)
                        case .leftBottom, .centerBottom, .rightBottom:
                            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-offset)
                        }
                    }
                    
                    $0.addTarget(self, action: #selector(postFabTapped(sender:)), for: .touchUpInside)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            self.socket?.disconnect()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        readmoreView.layoutIfNeeded()
    }
    
    func performLoadTimeline(completion: @escaping () -> Void) {
        Task {
            do {
                try await loadTimeline()
                completion()
            } catch {
                self.readmoreView.state = .withError
                self.readmoreView.lastError = error
            }
        }
    }
    
    func loadTimeline() async throws {
        guard let timelineType = self.timelineType else {
            print("loadTimelineを実装するか、self.timelineTypeを定義してください。")
            return
        }
        
        self.readmoreView.state = .loading
        let posts = try await MastodonEndpoint.GetTimeline(timelineType).request(with: environment)
        self.addNewPosts(posts: posts)
        self.readmoreView.state = .moreLoadable
    }
    
    @objc func refreshTimeline() {
        guard let timelineType = self.timelineType else {
            print("refreshTimelineを実装するか、self.timelineTypeを定義してください。")
            self.refreshControl.endRefreshing()
            return
        }
        let snapshot = self.diffableDataSource.snapshot()
        var timelineRequest = MastodonEndpoint.GetTimeline(timelineType, limit: 40)
        if let v = snapshot.itemIdentifiers(inSection: .posts).first, case .post(let id, _) = v {
            timelineRequest.paging = .prev(id.string, isSinceId: true)
        }
        timelineRequest.request(with: environment).then { posts in
            self.addNewPosts(posts: posts)
        }.catch { error in
            self.errorReport(error: error)
        }.always(in: .main) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func readmoreTapped() {
        readmoreView.state = .loading
        readMoreTimeline()
    }
    
    func readMoreTimeline() {
        guard let timelineType = self.timelineType else {
            print("readMoreTimelineを実装してください!!!!!!")
            readmoreView.state = .allLoaded
            return
        }
        let snapshot = self.diffableDataSource.snapshot()
        var request = MastodonEndpoint.GetTimeline(timelineType, limit: 40)
        if let v = snapshot.itemIdentifiers(inSection: .posts).last, case .post(let id, _) = v {
            request.paging = .next(id.string)
        }
        
        request.request(with: environment).then { posts in
            self.appendNewPosts(posts: posts)
            self.readmoreView.state = posts.count == 0 ? .allLoaded : .moreLoadable
        }.catch { e in
            self.readmoreView.state = .withError
            self.readmoreView.lastError = e
        }
    }
    
    func processNewPostVC(userActivity: NSUserActivity) {
        // オーバーライド用
    }
    
    @objc func openNewPostVC() {
        let userActivity = NSUserActivity(newPostWithMastodonUserToken: environment)
        processNewPostVC(userActivity: userActivity)
        showAsWindow(userActivity: userActivity, fallback: .timeline)
    }
    
    @objc func postFabTapped(sender: UITapGestureRecognizer) {
        self.openNewPostVC()
    }
    
    func addNewPosts(posts inputPosts: [MastodonPost]) {
        if inputPosts.count == 0 {
            return
        }
        let posts: [MastodonPost]
        do {
            posts = try inputPosts.sorted(by: { (a, b) -> Bool in
                return a.id.compare(b.id) == .orderedDescending
            }).filter({ (post) -> Bool in
                try self.environment.memoryStore.post.change(obj: post)
                if isAlreadyAdded[post.id.string] != true {
                    isAlreadyAdded[post.id.string] = true
                    return true
                }
                return false
            })
        } catch {
            DispatchQueue.mainAsyncIfNeed {
                self.errorReport(error: error)
            }
            return
        }
        
        var snapshot = self.diffableDataSource.snapshot()
        snapshot.prependItems(
            posts.map { .post(id: $0.id, pinned: false) },
            section: .posts
        )
        if snapshot.numberOfItems(inSection: .posts) > maxPostCount { // メモリ節約
            let items = snapshot.itemIdentifiers(inSection: .posts)
            snapshot.deleteItems(Array(items.dropFirst(maxPostCount)))
        }
        self.updateDataSourceQueue.sync {
            self.diffableDataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func websocketEndpoint() -> String? {
        return nil
    }
    
    func websocketConnect(auto: Bool) {
        var shouldConnectOnlyNotConstrainedNetworkAccess = false
        if auto {
            let conditions = Defaults.streamingAutoConnect
            if conditions != "always" {
                return
            }
        }
        guard let webSocketEndpoint = self.websocketEndpoint() else {
            return
        }
        Task {
            let socket = try await environment.getWebSocket(endpoint: webSocketEndpoint)
            socket.delegate = self
            socket.connect()
            self.socket = socket
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func appendNewPosts(posts: [MastodonPost]) {
        var snapshot = self.diffableDataSource.snapshot()
        for post in posts {
            do {
                try environment.memoryStore.post.change(obj: post)
            } catch {
                DispatchQueue.mainAsyncIfNeed {
                    self.errorReport(error: error)
                }
                return
            }
        }
        snapshot.appendItems(posts.map { .post(id: $0.id, pinned: false) }, toSection: .posts)
        updateDataSourceQueue.sync {
            self.diffableDataSource.apply(snapshot, animatingDifferences: true)
        }
        self.maxPostCount += posts.count
    }
    
    func setStreamingMenu(connected: Bool) {
        var items = [UIMenuElement]()
        if connected {
            items.append(UIAction(title: L10n.Localizable.disconnect) { [weak self] _ in
                self?.socket?.disconnect()
            })
        } else {
            items.append(UIAction(title: L10n.Localizable.connect) { [weak self] _ in
                self?.websocketConnect(auto: false)
            })
        }
        items.append(UIAction(title: L10n.Localizable.refetch, image: UIImage(systemName: "arrow.clockwise")) { [weak self] _ in
            self?.refetchTimeline()
        })
        streamingNavigationItem?.menu = UIMenu(title: L10n.Localizable.streaming + "\n" + L10n.Localizable.streamingStatus(connected ? L10n.Localizable.connected : L10n.Localizable.notConnected), children: items)
    }
    
    @objc func refetchTimeline() {
        let isStreamingConnectingNow = self.socket?.webSocket.isConnected ?? false
        if isStreamingConnectingNow {
            self.socket?.disconnect()
        }
        var snapshot = self.diffableDataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .posts))
        self.updateDataSourceQueue.sync {
            self.diffableDataSource.apply(snapshot, animatingDifferences: false)
        }
        self.isAlreadyAdded = [:]
        performLoadTimeline {
            if isStreamingConnectingNow {
                self.socket?.connect()
            }
        }
    }
}

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard case .post(let id, _) = self.diffableDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        guard let post = environment.memoryStore.post.container[id]?.originalPost else {
            return nil
        }
        
        var actions = [UIContextualAction]()
        
        if environment.canBoost(post: post) {
            actions.append(.init(style: .normal, title: "ブースト") { (action, view, callback) in
                MastodonEndpoint.CreateRepost(post: post).request(with: self.environment).then { result in
                    try self.updatePost(from: result.originalPost, includeRepost: true)
                    action.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                    callback(true)
                }
            } ※ { v in
                if post.reposted {
                    v.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                } else {
                    v.backgroundColor = .init(red: 0.3, green: 0.95, blue: 0.3, alpha: 1)
                }
            })
        }
        actions.append(.init(style: .normal, title: "ふぁぼ") { (action, view, callback) in
            MastodonEndpoint.CreateFavourite(post: post).request(with: self.environment).then { result in
                try self.updatePost(from: result.originalPost, includeRepost: true)
                action.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                callback(true)
            }
        } ※ { v in
            if post.favourited {
                v.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            } else {
                v.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.3, alpha: 1)
            }
        })
        return .init(actions: actions.reversed())
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = self.diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item {
        case .post(let id, _):
            guard let post = environment.memoryStore.post.container[id] else { break }
            let postDetailVC = MastodonPostDetailViewController.instantiate(post, environment: self.environment)
            showFromTimeline(postDetailVC)
        }
    }
    
    func updatePost(from: MastodonPost, includeRepost: Bool) throws {
        try MastodonMemoryStoreContainer[self.environment].post.change(obj: from)
    }
}

extension TimelineViewController: WebSocketWrapperDelegate {
    func webSocketDidConnect(_ wrapper: WebSocketWrapper) {
        DispatchQueue.mainSafeSync {
            streamingNavigationItem?.image = UIImage(systemName: "bolt.fill")
            streamingNavigationItem?.tintColor = nil
            setStreamingMenu(connected: true)
        }
    }
    
    func webSocketDidDisconnect(_ wrapper: WebSocketWrapper, error: Error?) {
        DispatchQueue.mainSafeSync {
            streamingNavigationItem?.image = UIImage(systemName: "bolt.slash.fill")
            streamingNavigationItem?.tintColor = .systemRed
            setStreamingMenu(connected: false)
        }
    }
    
    enum WebSocketEvent: Decodable {
        case update(MastodonPost)
        case statusUpdate(MastodonPost)
        case delete(String)
        case unknown(String)
        
        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            let event = try container.decode(String.self, forKey: .event)
            switch event {
            case "update":
                let payload = try container.decode(String.self, forKey: .payload)
                self = .update(try JSONDecoder.forMastodonAPI.decode(MastodonPost.self, from: payload.data(using: .utf8)!))
            case "delete":
                let payload = try container.decode(String.self, forKey: .payload)
                self = .delete(payload)
            case "status.update":
                let payload = try container.decode(String.self, forKey: .payload)
                self = .statusUpdate(try JSONDecoder.forMastodonAPI.decode(MastodonPost.self, from: payload.data(using: .utf8)!))
            default:
                self = .unknown(event)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case event
            case payload
        }
    }
    
    func webSocketDidReceiveMessage(_ wrapper: WebSocketWrapper, text: String) {
        do {
            var event = try JSONDecoder().decode(WebSocketEvent.self, from: text.data(using: .utf8)!)
            switch event {
            case .update(let post):
                addNewPosts(posts: [post])
            case .delete(let deletedTootID):
                var snapshot = diffableDataSource.snapshot()
                var deletePosts: [TableBody] = []

                for body in snapshot.itemIdentifiers(inSection: .posts) {
                    if case .post(let id, _) = body {
                        if id.string == deletedTootID {
                            deletePosts.append(body)
                        } else if environment.memoryStore.post.container[id]?.repost?.value.id.string == deletedTootID {
                            deletePosts.append(body)
                        }
                    }
                }
                
                snapshot.deleteItems(deletePosts)

                if deletePosts.count > 0 {
                    updateDataSourceQueue.sync {
                        diffableDataSource.apply(snapshot, animatingDifferences: true)
                    }
                }
            case .statusUpdate(let post):
                try environment.memoryStore.post.change(obj: post)
            case .unknown(let type):
                print("WebSocket: Receiving Unknown Event Type: \(type)")
            }
        } catch {
            DispatchQueue.mainAsyncIfNeed {
                self.errorReport(error: error)
            }
        }
    }
}
