//
//  TimelineViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/01.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

import Cocoa
import Ikemen
import iMastMacCore

class TimelineViewController: NSViewController {
    let userToken: MastodonUserToken
    let timelineType: MastodonTimelineType
    lazy var tableView = NSTableView() ※ {
        $0.headerView = nil
        $0.addTableColumn(.init())
        $0.dataSource = self
        $0.delegate = self
        $0.usesAutomaticRowHeights = true
        $0.style = .fullWidth
        $0.gridStyleMask = [.solidHorizontalGridLineMask]
    }
    lazy var scrollView = NSScrollView() ※ {
        $0.hasVerticalScroller = true
        $0.documentView = tableView
    }
    var posts = [MastodonPost]()
    
    init(userToken: MastodonUserToken, timelineType: MastodonTimelineType) {
        self.userToken = userToken
        self.timelineType = timelineType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userToken.timeline(timelineType).then(in: .main) { [weak self] posts in
            self?.addNewPosts(newPosts: posts)
        }
    }
    
    func addNewPosts(newPosts: [MastodonPost]) {
//        let newPosts = newPosts.filter { $0.visibility == .public }
        posts.insert(contentsOf: newPosts, at: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: IndexSet(0..<newPosts.count), withAnimation: [])
        tableView.endUpdates()
    }
    
    @objc func newDocument(_ sender: Any) {
        let wc = NewPostWindowController(userToken: userToken)
        if let window = view.window, let newWindow = wc.window {
            // TLのウインドウの右に投稿画面を出す
            var origin = window.frame.origin
            print(origin.y, window.frame.height)
            origin.y += window.frame.height - newWindow.frame.height
            origin.x += window.frame.width
            newWindow.setFrameOrigin(origin)
        }
        wc.showWindow(self)
    }
}

extension TimelineViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return posts.count
    }
}

extension TimelineViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let post = posts[row]
        return PostView(post: post)
    }
}
