//
//  OpenPushSettingsButton.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/06/15.
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

import SwiftUI
import iMastiOSCore

struct OpenPushSettingsButton: View {
    @Environment(\.openURL) var open
    @StateObject var errorReporter = ErrorReporter()
    @State var confirmsEnableNotificationPermission = false
    @State var confirmsTermsOfService = false
    @State var registeringNow = false
    @State var openPushSettings = false

    var body: some View {
        Button {
            Task { await openPushSettings() }
        } label: {
            HStack {
                Text(L10n.Preferences.Push.title)
                Spacer()
                if registeringNow {
                    ProgressView()
                }
            }
        }
        .disabled(registeringNow)
        .alert("通知が許可されていません", isPresented: $confirmsEnableNotificationPermission) {
            Button("設定へ") {
                open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button(L10n.Localizable.cancel, role: .cancel) {
            }
        } message: {
            Text("iOSの設定で、iMastからの通知を許可してください。")
        }
        .alert("プッシュ通知の利用確認", isPresented: $confirmsTermsOfService) {
            Button("同意する") {
                Task { await register() }
            }
            Button(L10n.Localizable.cancel, role: .cancel) {
            }
        } message: {
            Text("このプッシュ通知機能は、\n本アプリ(iMast)の開発者である@rinsuki@mstdn.rinsuki.netが、希望したiMastの利用者に対して無償で提供するものです。そのため、予告なく一時もしくは永久的にサービスが利用できなくなることがあります。また、本機能を利用したことによる不利益や不都合などについて、本アプリの開発者や提供者は一切の責任を持たないものとします。\n\n同意して利用を開始しますか?")
        }
        .background {
            NavigationLink(isActive: $openPushSettings) {
                PushSettingsView()
            } label: {
                EmptyView()
            }
            .hidden()
        }
    }
    
    @MainActor func openPushSettings() async {
        do {
            if try! PushService.isRegistered() {
                openPushSettings = true
                return
            }
            guard try await UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) else {
                confirmsEnableNotificationPermission = true
                return
            }
            confirmsTermsOfService = true
        } catch {
            errorReporter.report(error)
        }
    }
    
    @MainActor func register() async {
        registeringNow = true
        defer {
            registeringNow = false
        }
        do {
            try await PushService.register()
            UIApplication.shared.registerForRemoteNotifications()
        } catch {
            errorReporter.report(error)
        }
        openPushSettings = true
    }
}
