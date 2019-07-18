//
//  NSAttributedString+emojify.swift
//  iMast
//
//  Created by user on 2019/03/20.
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

import UIKit
import SDWebImage

extension NSAttributedString {
    func emojify(asyncLoadProgressHandler: (() -> Void)?, emojifyProtocol: EmojifyProtocol) -> NSAttributedString {
        let retstr = NSMutableAttributedString(attributedString: self)
        let emojis = (emojifyProtocol.emojis ?? []) + (emojifyProtocol.profileEmojis ?? [])
        emojis.forEach { (emoji) in
            print(emoji)
            if emoji.shortcode.count == 0 {
                return
            }
            let shortcode = ":\(emoji.shortcode):"
            guard let srcUrl = URL(string: emoji.url) else {
                return
            }
            while let range = (retstr.string as NSString).range(of: shortcode).optional {
                let attachment = NSTextAttachment()
                let fontAttribute = retstr.attribute(.font, at: range.location, longestEffectiveRange: nil, in: range)
                let font = fontAttribute as? UIFont ?? UIFont.systemFont(ofSize: CGFloat(Defaults[.timelineTextFontsize]))
                let size = font.lineHeight + 1
                attachment.bounds = CGRect(x: 0, y: 0, width: size, height: size)
                attachment.bounds.origin = CGPoint(x: 0, y: -4)
                if let asyncLoadProgressHandler = asyncLoadProgressHandler {
                    SDWebImageManager.shared().loadImage(with: srcUrl, options: [], progress: nil, completed: { (image, _, _, _, finished, _) in
                        if let image = image {
                            attachment.image = image
                            asyncLoadProgressHandler()
                        }
                    })
                } else {
                    if let srcData = try? Data(contentsOf: srcUrl) {
                        attachment.image = UIImage(data: srcData)
                    }
                }
                retstr.replaceCharacters(in: range, with: NSAttributedString(attachment: attachment))
            }
        }
        return retstr
    }
}
