//
//  OpenSafariButton.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/09/25.
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

struct OpenSafariButton: View {
    let title: Text
    let url: URL
    let flag: Bool
    @Environment(\.openURL) var open
    
    var body: some View {
        FakeNavigationButton {
            open(url)
        } label: {
            title.workaroundForSubtitleSpacing()
            Text(url.absoluteString)
        }
    }
}
