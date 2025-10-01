//
//  NewPostViewController+visionOS.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2025/10/02.
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

#if os(visionOS)

import UIKit
import SwiftUI
import iMastiOSCore

extension NewPostViewController {
    struct OrnamentView: View {
        @StateObject var viewModel: NewPostViewModel
        
        var body: some View {
            HStack {
                Button {
                    viewModel.alertPresenter?.mediaVC?.addFromPhotoLibrary()
                } label: {
                    Image(systemName: "photo")
                    Text("\(viewModel.media.count)")
                }

                Toggle(isOn: $viewModel.isNSFW) {
                    Image(systemName: viewModel.isNSFW ? "eye.slash" : "eye" )
                }
                .toggleStyle(.button)
                .help("NSFW (Current: \(viewModel.isNSFW ? "ON" : "OFF"))")

                Menu {
                    ForEach(MastodonPostVisibility.allCases) { v in
                        Button {
                            viewModel.visibility = v
                        } label: {
                            Label {
                                Text(v.localizedName)
                            } icon: {
                                Image(systemName: v.sfSymbolsName)
                            }
                        }
                    }
                } label: {
                    Image(systemName: viewModel.visibility.sfSymbolsName)
                        .aspectRatio(1, contentMode: .fit)
                }
                .menuStyle(.borderlessButton)
                .help("Visibility (Current: \(viewModel.visibility.localizedName))")

                Divider()

                Button {
                    viewModel.insertNowPlayingInfo()
                } label: {
                    Image(systemName: "music.note")
                }
                .help("Insert NowPlaying")
            }
            .padding()
            .buttonStyle(.borderless)
            .glassBackgroundEffect()
        }
    }
    
    func setupOrnaments() {
        let mediaVC = NewPostMediaListViewController(viewModel: viewModel, inline: true)
        contentView.stackView.addArrangedSubview(mediaVC.view)
        addChild(mediaVC)
        self.mediaVC = mediaVC
        viewModel.$media
            .prepend(viewModel.media)
            .receive(on: DispatchQueue.main)
            .sink {
                mediaVC.view.isHidden = $0.count == 0
            }
            .store(in: &cancellables)

        let ornament = UIHostingOrnament(sceneAnchor: .bottom, contentAlignment: .center) {
            OrnamentView(viewModel: self.viewModel)
        }
        
        ornaments = [ornament]
    }
}

#endif
