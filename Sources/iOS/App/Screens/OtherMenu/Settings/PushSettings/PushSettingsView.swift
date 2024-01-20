//
//  PushSettingsTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/07/17.
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
import AuthenticationServices
import UserNotifications
import Ikemen
import iMastiOSCore

struct PushSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.webAuthenticationSession) var webAuth
    @Environment(\.openURL) var openURL
    @AppStorage(defaults: .$showPushServiceError) var showPushServiceError
    @StateObject var errorReporter: ErrorReporter = .init()
    @State var accounts: [PushServiceToken] = []
    @State var loading = false
    @State var showNewServerHostConfirm = false
    @State var newServerHostName = ""
    @State var showDeleteAccountConfirm = false
    @State var loadingTask: Task<Void, Never>?
    @State var showUserIdAlert = false
    @State var userId: String?
    @State var selectedAccount: PushServiceToken?
    
    var body: some View {
        List {
            Section(L10n.Preferences.Push.Accounts.title) {
                ForEach(accounts) { account in
                    Button(account.acct) {
                        selectedAccount = account
                    }
                }
                .sheet(item: $selectedAccount) { account in
                    NavigationView {
                        PushSettingsAccountView(account: account)
                    }
                }
                Button(L10n.Preferences.Push.AddAccount.title) {
                    newServerHostName = ""
                    showNewServerHostConfirm = true
                }
                .alert(L10n.Preferences.Push.AddAccount.alertTitle, isPresented: $showNewServerHostConfirm) {
                    TextField("mstdn.example.com", text: $newServerHostName)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("OK") {
                        Task { await addAccount() }
                    }
                    Button(L10n.Localizable.cancel, role: .cancel) {}
                } message: {
                    Text(L10n.Preferences.Push.AddAccount.alertText)
                }
            }
            Section(L10n.Preferences.Push.Shared.title) {
                Toggle(L10n.Preferences.Push.Shared.displayErrorIfOccured, isOn: $showPushServiceError)
                NavigationLink(L10n.Preferences.Push.Shared.GroupRules.title) {
                    PushSettingsGroupNotifyTableView()
                }
                NavigationLink(L10n.Preferences.Push.Shared.CustomSounds.title) {
                    PushSettingsChangeSoundView()
                }
                Button(L10n.Preferences.Push.Shared.DeleteAccount.title, role: .destructive) {
                    showDeleteAccountConfirm = true
                }
                .alert("確認", isPresented: $showDeleteAccountConfirm) {
                    Button("削除する", role: .destructive) {
                        Task { await deleteAccount() }
                    }
                } message: {
                    Text(
                        "プッシュ通知の設定を削除します。\nこれにより、サーバーに保存されているあなたのプッシュ通知に関連する情報が削除されます。\n再度利用するには、もう一度プッシュ通知の設定をしなおす必要があります。"
                    )
                }
            }
            Section(L10n.Preferences.Push.Support.title) {
                Button(L10n.Preferences.Push.Support.ShowUserID.title) {
                    do {
                        userId = try Keychain_ForPushBackend.get("userId")
                        showUserIdAlert = true
                    } catch {
                        errorReporter.report(error)
                    }
                }
                .alert(L10n.Preferences.Push.Support.title, isPresented: $showUserIdAlert, presenting: userId) { userId in
                    Button(L10n.Preferences.Push.Support.ShowUserID.copyAction) {
                        UIPasteboard.general.string = userId
                    }
                    Button("OK", role: .cancel) { }
                } message: { userId in
                    Text("ユーザーID: \(userId)")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L10n.Preferences.Push.title)
        .disabled(loading)
        .refreshable {
            await self.load(block: false)
        }
        .task {
            await self.load(block: true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .pushSettingsAccountReload)) { _ in
            Task { await self.load(block: true) }
        }
        .overlay {
            ModalLoadingIndicatorView()
                .ignoresSafeArea()
                .opacity(loading ? 1 : 0)
                .allowsHitTesting(loading)
                .transition(.opacity)
        }
        .attach(errorReporter: errorReporter)
    }
    
    @MainActor func load(block: Bool) async {
        if block {
            loading = true
        }
        if let loadingTask {
            await loadingTask.result
            return
        }
        let task = Task { @MainActor in
            print("reloading")
            do {
                let newAccounts = try await PushService.getRegisterAccounts()
                withAnimation {
                    loading = false
                    accounts = newAccounts
                }
            } catch {
                errorReporter.report(error)
                dismiss()
            }
            print("reload-finish")
        }
        loadingTask = task
        defer {
            loadingTask = nil
        }
        await task.value
    }
    
    @MainActor func addAccount() async {
        loading = true
        defer {
            loading = false
        }
        do {
            let url = try await PushService.getAuthorizeUrl(host: newServerHostName)
            let resultUrl = try await webAuth.authenticate(using: url, callbackURLScheme: "", preferredBrowserSession: .shared)
            openURL(resultUrl)
        } catch {
            if case ASWebAuthenticationSessionError.canceledLogin = error  {
                return
            }
            errorReporter.report(error)
        }
    }
    
    @MainActor func deleteAccount() async {
        loading = true
        defer {
            loading = false
        }
        do {
            try await PushService.unRegister()
            dismiss()
        } catch {
            errorReporter.report(error)
        }
    }
}

//    func deleteAuthInfo() async {
//        let navigationController = self.navigationController
//        guard await confirmAsync(
//            title: "エラー",
//            message: "サーバー上にあなたのデータが見つかりませんでした。これは一時的な障害や、プログラムの不具合で起こる可能性があります。\n\nこれが一時的なものではなく、永久的に直らないようであれば、(存在するかもしれない)サーバー上のデータを見捨てて再登録することができます。再登録をするために現在のプッシュ通知アカウントを削除しますか?",
//            okButtonMessage: "削除",
//            style: .destructive,
//            cancelButtonMessage: "キャンセル"
//        ) else {
//            return
//        }
//        try! PushService.deleteAuthInfo()
//        navigationController?.visibleViewController?.alert(title: "削除完了", message: "削除が完了しました。")
//    }
//}
