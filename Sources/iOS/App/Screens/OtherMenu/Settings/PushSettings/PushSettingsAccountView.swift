//
//  PushSettingsAccountTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/07/28.
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
import SwiftUI
import iMastiOSCore

struct PushSettingsAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State var account: PushServiceToken
    @State var showDeleteConfirm = false
    @State var loading = false
    @State var deleting = false
    @StateObject var errorReporter = ErrorReporter()
    
    var body: some View {
        Form {
            Section("通知設定") {
                Toggle("フォロー", isOn: $account.notify.follow)
                Toggle("メンション", isOn: $account.notify.mention)
                Toggle("ブースト", isOn: $account.notify.boost)
                Toggle("ふぁぼ", isOn: $account.notify.favourite)
            }
            Section {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    HStack {
                        Text("このアカウントのプッシュ通知設定を削除…")
                        if deleting {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
        }
        .confirmationDialog("\(account.acct)のプッシュ通知設定を削除してもよろしいですか?\n削除したアカウントは再度追加できます。", isPresented: $showDeleteConfirm, titleVisibility: .visible, actions: {
            Button("削除", role: .destructive) {
                Task { await deleteAccount() }
            }
        })
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.Localizable.cancel, role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task { await save() }
                } label: {
                    if loading {
                        ProgressView()
                    } else {
                        Text("保存")
                    }
                }
            }
        }
        .disabled(loading || deleting)
        .navigationTitle(account.acct)
        .navigationBarTitleDisplayMode(.inline)
        .attach(errorReporter: errorReporter)
    }
    
    @MainActor func deleteAccount() async {
        deleting = true
        do {
            try await account.delete()
            NotificationCenter.default.post(name: .pushSettingsAccountReload, object: nil)
            dismiss()
        } catch {
            errorReporter.report(error)
            deleting = false
        }
    }
    
    @MainActor func save() async {
        loading = true
        do {
            try await account.update()
            NotificationCenter.default.post(name: .pushSettingsAccountReload, object: nil)
            dismiss()
        } catch {
            errorReporter.report(error)
            loading = false
        }
    }
}
