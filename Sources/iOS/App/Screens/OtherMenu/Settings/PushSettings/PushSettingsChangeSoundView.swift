//
//  PushSettingsChangeSoundViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/01/01.
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

import UIKit
import SwiftUI
import AVKit
import iMastiOSCore

struct PushSettingsChangeSoundView: View {
    private enum NotificationType: String {
        case boost
        case favourite
        
        var title: String {
            switch self {
            case .boost:
                return "ブースト"
            case .favourite:
                return "ふぁぼ"
            }
        }
    }
    
    @AppStorage(defaults: .$useCustomBoostSound) var useCustomBoostSound
    @AppStorage(defaults: .$useCustomFavouriteSound) var useCustomFavoriteSound
    @State var showBoostSoundPicker: Bool = false
    @State var showFavoriteSoundPicker: Bool = false
    @StateObject var errorReporter: ErrorReporter = .init()
    @State var doesntHaveSoundFileError: Bool = false
    
    var body: some View {
        Form {
            section(type: .boost, isOn: $useCustomBoostSound, showPicker: $showBoostSoundPicker)
            section(type: .favourite, isOn: $useCustomFavoriteSound, showPicker: $showFavoriteSoundPicker)
        }
        .navigationTitle(L10n.Preferences.Push.Shared.CustomSounds.title)
        .attach(errorReporter: errorReporter)
        .alert("エラー", isPresented: $doesntHaveSoundFileError) {
            Button("OK") {
                doesntHaveSoundFileError = false
            }
        } message: {
            Text("通知音が登録されていません。先に登録してください")
        }

    }
    
    private func destUrl(type: NotificationType) throws -> URL {
        let destDirUrl = appGroupFileUrl
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Sounds", isDirectory: true)
        try FileManager.default.createDirectory(at: destDirUrl, withIntermediateDirectories: true)
        return destDirUrl.appendingPathComponent("custom-\(type.rawValue).caf")
    }
    
    private func section(type: NotificationType, isOn: Binding<Bool>, showPicker: Binding<Bool>) -> some View {
        return Section {
            Toggle(isOn: isOn) {
                Text(type.title)
            }
            Button("ファイル選択") {
                showPicker.wrappedValue = true
            }
            .fileImporter(isPresented: showPicker, allowedContentTypes: [.init("com.apple.coreaudio-format")!]) { result in
                do {
                    let url = try result.get()
                    let destUrl = try destUrl(type: type)
                    print(destUrl.absoluteString)
                    try? FileManager.default.removeItem(at: destUrl)
                    try FileManager.default.copyItem(at: url, to: destUrl)
                    url.stopAccessingSecurityScopedResource()
                    isOn.wrappedValue = true
                } catch {
                    errorReporter.report(error)
                }
            }
            Button("再生してみる") {
                let url = try? destUrl(type: type)
                guard let url, FileManager.default.fileExists(atPath: url.path) else {
                    doesntHaveSoundFileError = true
                    return
                }
                print(url.path)
                let playerVC = AVPlayerViewController()
                let player = AVPlayer(url: url)
                playerVC.player = player
                // TODO: 悪用をやめる
                errorReporter.view?.viewController?.present(playerVC, animated: true)
            }
        }
    }
}
