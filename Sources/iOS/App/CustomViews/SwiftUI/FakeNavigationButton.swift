//
//  FakeNavigationButton.swift
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

struct FakeNavigationButton<Label: View>: View {
    let action: () -> Void
    let label: Label

    var body: some View {
        Button(action: action) {
            LabeledContent {
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.init(uiColor: .tertiaryLabel))
            } label: {
                label
            }
            .tint(.primary)
        }
    }
    
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
}

#if DEBUG
private struct FakeNavigationButtonPreviewView: View {
    @State var flag: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                FakeNavigationButton(action: {
                    print("?")
                }) {
                    Text("偽物のNavigationLink" as String)
                    Text("https://example.com/" as String)
                }
                NavigationLink(destination: { EmptyView() }) {
                    LabeledContent {
                        EmptyView()
                    } label: {
                        Text("本物のNavigationLink" as String)
                        Text("https://example.com/" as String)
                    }
                }
                if flag {
                    FakeNavigationButton(action: {
                        print("?")
                    }) {
                        Text("偽物のNavigationLink" as String)
                        Text("https://example.com/" as String)
                    }
                } else {
                    NavigationLink(destination: { EmptyView() }) {
                        LabeledContent {
                            EmptyView()
                        } label: {
                            Text("本物のNavigationLink" as String)
                            Text("https://example.com/" as String)
                        }
                    }
                }
                Toggle(isOn: $flag, label: {
                    Text("New/Old")
                })
            }
        }
    }
}

#Preview {
    FakeNavigationButtonPreviewView()
}
#endif
