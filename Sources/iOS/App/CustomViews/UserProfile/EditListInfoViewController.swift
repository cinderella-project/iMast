//
//  EditListInfoViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/09/29.
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

import SwiftUI
import Mew
import iMastiOSCore

class EditListInfoViewController: UIHostingController<EditListInfoView>, Instantiatable {
    typealias Input = MastodonList
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(rootView: .init(list: input, userToken: environment))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct EditListInfoView: View {
    let list: MastodonList
    let userToken: MastodonUserToken
    @State var title: String
    @State var saving = false
    @State var askDelete = false
    @StateObject var errorReporter: ErrorReporter = .init()
    @MainActor @Environment(\.dismiss) var dismiss
    
    init(list: MastodonList, userToken: MastodonUserToken) {
        self.list = list
        self.userToken = userToken
        _title = .init(initialValue: list.title)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        TextField(text: $title, prompt: Text("必須")) {
                            Text("名前")
                        }
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("名前")
                    }

                }
                Section {
                    Button(role: .destructive) {
                        askDelete = true
                    } label: {
                        Text("リストを削除…")
                    }
                    .confirmationDialog(Text("このリストを削除してもよろしいですか?"), isPresented: $askDelete, titleVisibility: .visible) {
                        Button(role: .destructive) {
                            Task { await delete() }
                        } label: {
                            Text("削除")
                        }

                    }
                }
            }
            .navigationTitle("リストを編集")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text(L10n.Localizable.cancel)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await save() }
                    } label: {
                        if saving {
                            ProgressView()
                        } else {
                            Text("保存")
                        }
                    }
                }
            }
            .disabled(saving)
            .attach(errorReporter: errorReporter)
        }
    }
    
    @MainActor func save() async {
        saving = true
        do {
            _ = try await MastodonEndpoint.UpdateList(list: list, title: title).request(with: userToken)
            dismiss()
        } catch {
            errorReporter.report(error)
            saving = false
        }
    }
    
    @MainActor func delete() async {
        saving = true
        do {
            _ = try await MastodonEndpoint.DeleteList(list: list).request(with: userToken)
            dismiss()
        } catch {
            errorReporter.report(error)
            saving = false
        }
    }
}
