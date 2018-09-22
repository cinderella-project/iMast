//
//  String+toPlainText.swift
//  iMast
//
//  Created by user on 2018/09/22.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

extension String {
    func toPlainText() -> String {
        return self.pregReplace(pattern: "<br.+?>", with: "\n")
            .replace("</p><p>", "\n\n")
            .pregReplace(pattern: "<.+?>", with: "")
            .replace("&lt;", "<")
            .replace("&gt;", ">")
            .replace("&apos;", "'")
            .replace("&quot;", "\"")
            .replace("&amp;", "&")
    }
}
