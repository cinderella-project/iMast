//
//  MastodonPostAbuseViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/08/04.
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
import Mew
import iMastiOSCore
import SwiftUI

class MastodonPostAbuseViewController: UIHostingController<MastodonPostAbuseView>, Instantiatable {
    typealias Input = MastodonPost
    typealias Environment = MastodonUserToken
    
    private let input: Input
    internal let environment: Environment
    private let model: MastodonPostAbuseViewModel
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        model = .init(post: input, userToken: environment)
        super.init(rootView: .init(model: model))
        model.viewController = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var placeholder = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "投稿を通報"
        navigationItem.largeTitleDisplayMode = .never
    }
}

class MastodonPostAbuseViewModel: ObservableObject {
    let post: MastodonPost
    let userToken: MastodonUserToken
    let postText: String
    let forwardDestination: String?
    
    weak var viewController: MastodonPostAbuseViewController?

    @Published @MainActor var text: String = ""
    @Published @MainActor var forward: Bool = false
    @Published @MainActor var sending: Bool = false
    @Published @MainActor var finished: Bool = false
    
    internal init(post: MastodonPost, userToken: MastodonUserToken) {
        self.post = post
        self.userToken = userToken
        if let host = post.account.acct.split(separator: "@").safe(1) {
            forwardDestination = String(host)
        } else {
            forwardDestination = nil
        }
        postText = post.status.toPlainText() + (post.attachments.count > 0 ? " (\(post.attachments.count)個のメディア)" : "")
    }
    
    func send() {
        Task {
            await MainActor.run {
                sending = true
            }
            do {
                let text = await text
                let forward = await forward
                let req = MastodonEndpoint.CreateReport(account: post.account, comment: text, forward: forward, posts: [post])
                try await req.request(with: userToken)
                await MainActor.run {
                    finished = true
                }
            } catch {
                await MainActor.run {
                    viewController?.errorReport(error: error)
                    sending = false
                }
            }
        }
    }
}

struct MastodonPostAbuseView: View {
    @ObservedObject var model: MastodonPostAbuseViewModel
    @Environment(\.dismiss) var dismiss: DismissAction
    
    var body: some View {
        Form {
            Group {
                Section("対象の投稿") {
                    Text(model.postText)
                }
                Section {
                    TextField(
                        "追加情報", text: $model.text,
                        prompt: Text("オプション"),
                        axis: .vertical
                    )
                    .lineLimit(4...)
                } header: {
                    Text("追加情報")
                }
                if let forwardDestination = model.forwardDestination {
                    Section {
                        Toggle(isOn: $model.forward) {
                            Text("リモートサーバーに転送")
                        }
                    } footer: {
                        Text("このチェックボックスをONにすると、この通報内容は\(forwardDestination)にも転送されます。あなたのアカウントがあるサーバーと\(forwardDestination)が共にMastodon 2.3以上であるか、通報の連合経由での転送に対応している必要があります。")
                    }
                }
            }
        }
        .disabled(model.sending)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if model.sending {
                    ProgressView()
                } else {
                    Button("送信") {
                        model.send()
                    }
                }
            }
        }
        .alert("送信しました", isPresented: $model.sending, actions: {
            Button("OK") {
                dismiss()
            }
        })
        .navigationTitle(Text("投稿を通報"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
