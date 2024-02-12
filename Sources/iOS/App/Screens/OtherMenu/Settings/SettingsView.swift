//
//  SettingsView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/06/10.
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
import SDWebImage

class NewSettingsViewController: UIHostingController<SettingsView> {
    init() {
        super.init(rootView: .init())
        navigationItem.title = L10n.Localizable.settings
        navigationItem.rightBarButtonItem = .init(title: "ヘルプ", style: .plain, target: self, action: #selector(openHelp))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openHelp() {
        open(url: URL(string: "https://cinderella-project.github.io/iMast/help/settings.html")!)
    }
}

struct SettingsView: View {
    
    var body: some View {
        Form {
            GeneralSection()
            PostSection()
            NowPlayingSection()
            PostDetailSection()
            TimelineAppearanceSection()
            TimelineSection()
            ShareSection()
            MediaCacheSection()
            ExperimentalSection()
            Section {
                NavigationLink(destination: DeveloperSettingsView()) {
                    Label("内部設定", systemImage: "wrench.and.screwdriver.fill")
                }
            } footer: {
                Text("開発者から指示されたか、あなたが開発者である場合を除いて、通常これらの設定を変更する必要はありません。")
            }
        }
    }
    
    struct GeneralSection: View {
        @AppStorage(defaults: .$streamingAutoConnect) var streamingAutoConnect
        @AppStorage(defaults: .$newAccountVia) var newAccountVia
        @AppStorage(defaults: .$followRelationshipsOld) var followRelationshipsOld
        
        struct EditNewAccountViaView: View {
            @Environment(\.dismiss) var dismiss
            @AppStorage(defaults: .$newAccountVia) var newAccountVia
            @FocusState var focusState: Bool
            
            var body: some View {
                Form {
                    TextField(L10n.Preferences.General.NewAccountVia.title, text: $newAccountVia)
                        .submitLabel(.done)
                        .onSubmit {
                            dismiss()
                        }
                        .focused($focusState)
                        .onAppear {
                            focusState = true
                        }
                }
                .navigationTitle(L10n.Preferences.General.NewAccountVia.title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
        var body: some View {
            Section {
                Picker(L10n.Preferences.General.StreamingAutoConnect.title, selection: $streamingAutoConnect) {
                    Text(L10n.Preferences.General.StreamingAutoConnect.no).tag("no")
//                    Text(L10n.Preferences.General.StreamingAutoConnect.wifi).tag("wifi")
                    Text(L10n.Preferences.General.StreamingAutoConnect.always).tag("always")
                }
                NavigationLink {
                    EditNewAccountViaView()
                } label: {
                    LabeledContent(L10n.Preferences.General.NewAccountVia.title, value: newAccountVia)
                }
                Toggle("フォロー関係を以前の表記にする", isOn: $followRelationshipsOld)
                OpenPushSettingsButton()
            }
        }
    }
    
    struct PostSection: View {
        @AppStorage(defaults: .$autoResizeSize) var autoResizeSize
        @AppStorage(defaults: .$usingDefaultVisibility) var usingDefaultVisibility
        
        var body: some View {
            Section(L10n.Preferences.Post.title) {
                Picker(L10n.Preferences.Post.AutoResize.title, selection: $autoResizeSize) {
                    Text(L10n.Preferences.Post.AutoResize.no).tag(0)
                    ForEach([1920, 1280, 1000, 750, 500], id: \.self) {
                        Text(L10n.Preferences.Post.AutoResize.pixel($0)).tag($0)
                    }
                }
                Toggle(L10n.Preferences.Post.useDefaultVisibility, isOn: $usingDefaultVisibility)
            }
        }
    }
    
    struct NowPlayingSection: View {
        @AppStorage(defaults: .$nowplayingFormat) var nowplayingFormat
        @AppStorage(defaults: .$nowplayingAddAppleMusicUrl) var addAppleMusicIfAvailable
        
        var body: some View {
            Section(L10n.Preferences.NowPlaying.title) {
                NavigationLink {
                    Form {
                        TextField(
                            "\(L10n.Preferences.NowPlaying.Format.title)",
                            text: $nowplayingFormat,
                            prompt: Text("#NowPlaying {title} - {artist} ({albumTitle})" as String),
                            axis: .vertical
                        )
                            .lineLimit(3...)
                    }
                    .navigationTitle(L10n.Preferences.NowPlaying.Format.title)
                } label: {
                    LabeledContent(L10n.Preferences.NowPlaying.Format.title, value: nowplayingFormat)
                }
                Toggle(L10n.Preferences.NowPlaying.addURLIfAppleMusicAndAvailable, isOn: $addAppleMusicIfAvailable)
            }
        }
    }
    
    struct PostDetailSection: View {
        @AppStorage(defaults: .$deleteTootTeokure) var deleteTootTeokure
        
        var body: some View {
            Section("投稿詳細") {
                Toggle("投稿削除をておくれにする", isOn: $deleteTootTeokure)
            }
        }
    }
    
    struct TimelineAppearanceSection: View {
        @AppStorage(defaults: .$timelineUsernameFontsize) var timelineUsernameFontsize
        @AppStorage(defaults: .$timelineTextFontsize) var timelineTextFontsize
        @AppStorage(defaults: .$timelineTextBold) var timelineTextBold
        @AppStorage(defaults: .$timelineIconSize) var timelineIconSize
        @AppStorage(defaults: .$visibilityEmoji) var visibilityEmoji
        @AppStorage(defaults: .$inReplyToEmoji) var inReplyToEmoji
        @AppStorage(defaults: .$thumbnailHeight) var thumbnailHeight
        @AppStorage(defaults: .$postFabEnabled) var postFabEnabled
        @AppStorage(defaults: .$postFabLocation) var postFabLocation
        @AppStorage(defaults: .$acctAbbr) var acctAbbr
        @AppStorage(defaults: .$usePostLanguageInfo) var usePostLanguageInfo
        
        var body: some View {
            Section(L10n.Preferences.TimelineAppearance.title) {
                Group {
                    VStack {
                        LabeledContent(L10n.Preferences.TimelineAppearance.userNameSize, value: String(format: "%.1f", timelineUsernameFontsize))
                        Slider(value: $timelineUsernameFontsize, in: 10...20, step: 0.5)
                    }
                    VStack {
                        LabeledContent(L10n.Preferences.TimelineAppearance.contentSize, value: String(format: "%.1f", timelineTextFontsize))
                        Slider(value: $timelineTextFontsize, in: 10...20, step: 0.5)
                    }
                    Toggle(L10n.Preferences.TimelineAppearance.contentBold, isOn: $timelineTextBold)
                    VStack {
                        LabeledContent(L10n.Preferences.TimelineAppearance.iconSize, value: String(format: "%.1f", timelineIconSize))
                        Slider(value: $timelineIconSize, in: 24...72, step: 0.5)
                    }
                    Toggle(L10n.Preferences.TimelineAppearance.visibilityAsEmoji, isOn: $visibilityEmoji)
                    Toggle(L10n.Preferences.TimelineAppearance.inReplyToAsEmoji, isOn: $inReplyToEmoji)
                    VStack {
                        LabeledContent(L10n.Preferences.TimelineAppearance.thumbnailHeight, value: String(format: "%.1f", thumbnailHeight))
                        Slider(value: $thumbnailHeight, in: 0...100, step: 5)
                    }
                }
                Group {
                    Toggle(L10n.Preferences.TimelineAppearance.BigNewPostButton.show, isOn: $postFabEnabled)
                    Picker(L10n.Preferences.TimelineAppearance.BigNewPostButton.Location.title, selection: $postFabLocation) {
                        ForEach(PostFabLocation.allCases, id: \.rawValue) {
                            Text($0.description).tag($0)
                        }
                    }
                }
                Toggle(isOn: $acctAbbr) {
                    Text("acctのホスト名を略す").workaroundForSubtitleSpacing()
                    Text("例: m6n.s4l")
                }
                Toggle("投稿の言語情報を表示時に考慮", isOn: $usePostLanguageInfo)
            }
        }
    }
    
    struct TimelineSection: View {
        @AppStorage(defaults: .$webmVlcOpen) var webmVlcOpen
        @AppStorage(defaults: .$useAVPlayer) var useAVPlayer
        @AppStorage(defaults: .$useUniversalLink) var useUniversalLinks
        
        var body: some View {
            Section(L10n.Preferences.Timeline.title) {
                Toggle(L10n.Preferences.Timeline.openWebMInVLC, isOn: $webmVlcOpen)
                Toggle(L10n.Preferences.Timeline.useSystemVideoPlayer, isOn: $useAVPlayer)
                Toggle(L10n.Preferences.Timeline.useUniversalLinks, isOn: $useUniversalLinks)
            }
        }
    }
    
    struct ShareSection: View {
        @AppStorage(defaults: .$shareNoTwitterTracking) var shareNoTwitterTracking
        @AppStorage(defaults: .$usingNowplayingFormatInShareSpotifyUrl) var usingNowplayingFormatInShareSpotifyUrl
        @AppStorage(defaults: .$shareNoSpotifySIParameter) var shareNoSpotifySIParameter
        
        var body: some View {
            Section("共有") {
                Toggle("Twitterにトラッキングさせない" as String, isOn: $shareNoTwitterTracking)
                Toggle(isOn: $usingNowplayingFormatInShareSpotifyUrl) {
                    Text("Spotifyを共有する時にNowPlayingフォーマットを使用" as String)
                        .workaroundForSubtitleSpacing()
                    Text("SpotifyのURLを共有しようとする際に https://open.spotify.com との通信が発生します。また、この機能は非公式であり、問題が発生しても開発者は責任を負いません。自己責任でお使いください。" as String)
                }
                Toggle("Spotifyのsiパラメータを削除" as String, isOn: $shareNoSpotifySIParameter)
            }
        }
    }
    
    struct MediaCacheSection: View {
        @State var cacheStorageValue = "計算中…"
        @State var askToDeleteCache = false
        @State var deleting = false
        
        var body: some View {
            Section("画像キャッシュ") {
                LabeledContent("キャッシュの容量", value: cacheStorageValue)
                Button(deleting ? "キャッシュを削除中…" : "ストレージ上のキャッシュを削除…") {
                    askToDeleteCache = true
                }
                    .disabled(deleting)
                    .alert("キャッシュを削除しますか?", isPresented: $askToDeleteCache) {
                        Button(L10n.Localizable.cancel, role: .cancel) {}
                        Button("削除", role: .destructive) {
                            deleting = true
                            Task {
                                // 実際の処理がめちゃめちゃ早く終わってもなんかしてるように見せる
                                async let minimum = Task.sleep(nanoseconds: 500_000_000)
                                await SDImageCache.shared.clearDiskOnCompletion()
                                try await minimum
                                DispatchQueue.main.async {
                                    refresh()
                                    deleting = false
                                }
                            }
                        }
                    }
            }
            .onAppear { refresh() }
        }
        
        func refresh() {
            let size = SDImageCache.shared.totalDiskSize()
            let formatter = ByteCountFormatter()
            cacheStorageValue = formatter.string(fromByteCount: Int64(size))
        }
    }
    
    struct ExperimentalSection: View {
        @AppStorage(defaults: .$notifyTabInfiniteScroll) var notifyTabInfiniteScroll
        @AppStorage(defaults: .$newFirstScreen) var newFirstScreen
        @AppStorage(defaults: .$communicationNotificationsEnabled) var communicationNotificationsEnabled
        @AppStorage(defaults: .$openAsHalfModalFromTimeline) var openAsHalfModalFromTimeline
        @AppStorage(defaults: .$openAsAnotherWindow) var openAsAnotherWindow

        var body: some View {
            Section("実験的な要素") {
                Toggle("通知タブの無限スクロール", isOn: $notifyTabInfiniteScroll)
                Toggle("最初の画面を新しい物に (α)", isOn: $newFirstScreen)
                Toggle(isOn: $communicationNotificationsEnabled) {
                    Text("Communication Notifications を有効にする").workaroundForSubtitleSpacing()
                    Text("メンションのプッシュ通知に送信者のアイコンが付くようになります。")
                }
                Toggle("タイムラインから何かを開いた時にハーフモーダルにする", isOn: $openAsHalfModalFromTimeline)
                Toggle("できるだけ新ウィンドウで開く", isOn: $openAsAnotherWindow)
            }
        }
    }
    
}

struct DeveloperSettingsView: View {
    @AppStorage(defaults: .$workaroundOfiOS16_TextKit2_WontUpdatesLinkColor) var workaroundOfiOS16_TextKit2_WontUpdatesLinkColor
    @Environment(\.dismiss) var dismiss
    @StateObject var errorReporter = ErrorReporter()
    @State var failedToOpenDeckBecauseZeroPinnedScreens = false
    @State var failedToOpenDeckBecauseTooManyPinnedScreens = false
    
    var body: some View {
        Form {
            Section("Workarounds") {
                Toggle(isOn: $workaroundOfiOS16_TextKit2_WontUpdatesLinkColor) {
                    Text("投稿の本文表示に TextKit 1 を使用").workaroundForSubtitleSpacing()
                    Text("ハーフモーダルに関連してタイムラインにある投稿内のリンクの色がおかしくなる現象への Workaround です。")
                }
            }
            Section("user_pinned_screens") {
                Button {
                    try! dbQueue.inDatabase { db in
                        try MastodonUserToken.defragPinnedScreens(in: db)
                    }
                    dismiss()
                } label: {
                    Text("Force Defrag (padding=default)")
                }
                Button(role: .destructive) {
                    try! dbQueue.inDatabase { db in
                        try MastodonUserToken.defragPinnedScreens(in: db, padding: 1)
                    }
                    dismiss()
                } label: {
                    Text("Force Defrag (padding=1, causes re-defrag in next time)")
                }
            }
            Section("In Development Features") {
                Button("Open Deck") {
                    let pinnedScreens = (try? dbQueue.inDatabase(MastodonUserToken.getPinnedScreens)) ?? []
                    if pinnedScreens.count < 1 {
                        failedToOpenDeckBecauseZeroPinnedScreens = true
                        return
                    }
                    if pinnedScreens.count > 10 {
                        failedToOpenDeckBecauseTooManyPinnedScreens = true
                        return
                    }
                    errorReporter.view?.window?.changeRootVC(TopDeckViewController())
                }
                .alert("Error: There is no pinned screens (Deck will use pinned screens as a column)", isPresented: $failedToOpenDeckBecauseZeroPinnedScreens) {
                    Button("OK") {
                    }
                }
                .alert("Error: There is too many pinned screens (Deck will use pinned screens as a column), maximum is 10", isPresented: $failedToOpenDeckBecauseTooManyPinnedScreens) {
                    Button("OK") {
                    }
                }
            }
        }
        .attach(errorReporter: errorReporter)
        .navigationTitle("内部設定")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
