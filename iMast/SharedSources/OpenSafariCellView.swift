//
//  OpenSafariCellView.swift
//  iMast
//
//  Created by rinsuki on 2019/06/19.
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
//

import SwiftUI
import SafariServices

struct OpenSafariCellView: View {
    
    let url: URL
    let text: Text
    var showUrl: Bool = true
    
    var body: some View {
        Button(action: self.open) {
            HStack {
                VStack(alignment: .leading) {
                    text
                    if showUrl {
                        Text(url.absoluteString)
                            .lineLimit(1)
                            .font(.system(.footnote))
                    }
                }
                Spacer().layoutPriority(-1)
                Image(systemName: "safari").colorMultiply(.secondary)
            }
        }
    }
    
    func open() {
        let safariVC = SFSafariViewController(url: self.url)
        UIApplication.shared.keyWindow?.rootViewController?.present(safariVC, animated: true, completion: nil)
    }
}

#if DEBUG
struct OpenSafariCellView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            OpenSafariCellView(url: URL(string: "https://example.com")!, text: Text("Open example.com"), showUrl: true)
        }
    }
}
#endif
