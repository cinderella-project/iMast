//
//  NewPostViewModel.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2024/02/12.
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

import Foundation
import UIKit
import Combine
import iMastiOSCore
import MediaPlayer

class NewPostViewModel: ObservableObject {
    @Published var visibility: MastodonPostVisibility = .public
    @Published var isNSFW = false
    @Published var media: [UploadableMedia] = []

    weak var alertPresenter: NewPostViewController?
    
    @MainActor @objc func insertNowPlayingInfo() {
        switch MPMediaLibrary.authorizationStatus() {
        case .denied:
            alertPresenter?.alert(
                title: L10n.Localizable.Error.title,
                message: L10n.NewPost.Errors.declineAppleMusicPermission
            )
            return
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.insertNowPlayingInfo()
                }
            }
            return
        case .restricted:
            alertPresenter?.alert(title: "よくわからん事になりました", message: "もしよければ、このアラートがどのような条件で出たか、以下のコードを添えて @imast_ios@mstdn.rinsuki.net までお知らせください。\ncode: MPMediaLibraryAuthorizationStatus is restricted")
            return
        case .authorized:
            break
        @unknown default:
            alertPresenter?.alert(title: "よくわからん事になりました", message: "もしよければ、このアラートがどのような条件で出たか、以下のコードを添えて @imast_ios@mstdn.rinsuki.net までお知らせください。\ncode: MPMediaLibraryAuthorizationStatus is unknown value")
            return
        }
        guard let nowPlayingMusic = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else { return }
        if nowPlayingMusic.title == nil {
            return
        }
        var nowPlayingText = Defaults.nowplayingFormat
        nowPlayingText = nowPlayingText.replacingOccurrences(of: "{title}", with: nowPlayingMusic.title ?? "")
        nowPlayingText = nowPlayingText.replacingOccurrences(of: "{artist}", with: nowPlayingMusic.artist ?? "")
        nowPlayingText = nowPlayingText.replacingOccurrences(of: "{albumArtist}", with: nowPlayingMusic.albumArtist ?? "")
        nowPlayingText = nowPlayingText.replacingOccurrences(of: "{albumTitle}", with: nowPlayingMusic.albumTitle ?? "")
        
        func finished(_ text: String) {
            alertPresenter?.contentView.textInput.insertText(text)
        }

        func checkAppleMusic() -> Bool {
            guard Defaults.nowplayingAddAppleMusicUrl else { return false }
            let storeId = nowPlayingMusic.playbackStoreID
            guard storeId != "0" else { return false }
            let region = Locale.current.regionCode ?? "jp"
            var request = URLRequest(url: URL(string: "https://itunes.apple.com/lookup?id=\(storeId)&country=\(region)&media=music")!)
            request.timeoutInterval = 1.5
            request.addValue(UserAgentString, forHTTPHeaderField: "User-Agent")
            Task { @MainActor in
                var text = nowPlayingText
                do {
                    let (data, res) = try await URLSession.shared.data(for: request)
                    struct SearchResultWrapper: Codable {
                        let results: [SearchResult]
                    }
                    struct SearchResult: Codable {
                        let trackViewUrl: URL
                    }
                    let result = try JSONDecoder().decode(SearchResultWrapper.self, from: data)
                    if let url = result.results.first?.trackViewUrl {
                        text += " " + url.absoluteString + " "
                    }
                } catch {
                    // nothing
                }
                finished(text)
            }
            return true
        }
        if !checkAppleMusic() {
            finished(nowPlayingText)
        }
    }
}
