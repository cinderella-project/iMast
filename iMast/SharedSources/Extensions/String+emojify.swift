//
//  String+emojify.swift
//  iMast
//
//  Created by user on 2018/07/24.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

extension String {
    func emojify(custom_emoji: [MastodonCustomEmoji] = [], profile_emoji: [MastodonCustomEmoji] = []) -> String {
        var retstr = self
        retstr.pregMatch(pattern: ":.+?:").forEach { (emoji) in
            if let unicodeEmoji = emojidict[emoji].string {
                retstr = retstr.replace(emoji, unicodeEmoji)
            }
        }
        (custom_emoji + profile_emoji).forEach { (emoji) in
            print(emoji)
            if emoji.shortcode.count == 0 {
                return
            }
            let html = "<img src=\"\(emoji.url)\" style=\"height:1em;width:1em;\">"
            retstr = retstr.replace(":\(emoji.shortcode):", html)
        }
        return retstr
    }
}
