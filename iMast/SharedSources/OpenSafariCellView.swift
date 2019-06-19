//
//  OpenSafariCellView.swift
//  iMast
//
//  Created by user on 2019/06/19.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import SwiftUI
import SafariServices

struct OpenSafariCellView : View {
    
    let url: URL
    let text: Text
    var showUrl: Bool = true
    
    var body: some View {
        Button(action: self.open) {
            HStack {
                VStack(alignment: .leading) {
                    text
                    if showUrl {
                        Text(url.absoluteString).font(.system(.footnote))
                    }
                }
                Spacer()
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
struct OpenSafariCellView_Previews : PreviewProvider {
    static var previews: some View {
        List {
            OpenSafariCellView(url: URL(string: "https://example.com")!, text: Text("Open example.com"), showUrl: true)
        }
    }
}
#endif
