//
//  String+emojify.swift
//  iMast
//
//  Created by user on 2018/07/24.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

extension String {
    func emojify() -> String {
        var retstr = self
        retstr.pregMatch(pattern: ":.+?:").forEach { (emoji) in
            if let unicodeEmoji = emojidict[emoji].string {
                retstr = retstr.replace(emoji, unicodeEmoji)
            }
        }
//        if let emojifyProtocol = emojifyProtocol {
//            let emojis = (emojifyProtocol.emojis ?? []) + (emojifyProtocol.profileEmojis ?? [])
//            emojis.forEach { (emoji) in
//                print(emoji)
//                if emoji.shortcode.count == 0 {
//                    return
//                }
//                let html = "<img src=\"\(emoji.url)\" style=\"height:1em;width:1em;\">"
//                retstr = retstr.replace(":\(emoji.shortcode):", html)
//            }
//        }
        return retstr
    }
}
