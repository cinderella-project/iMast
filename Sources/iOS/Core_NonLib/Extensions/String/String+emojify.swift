//
//  String+emojify.swift
//  iMast
//
//  Created by rinsuki on 2018/07/24.
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

import Foundation
import iMastiOSCore

extension String {
    func emojify() -> String {
        var retstr = self
        retstr.pregMatch(pattern: ":.+?:").forEach { (emoji) in
            if let unicodeEmoji = emojidict[emoji].string {
                retstr = retstr.replacingOccurrences(of: emoji, with: unicodeEmoji)
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
