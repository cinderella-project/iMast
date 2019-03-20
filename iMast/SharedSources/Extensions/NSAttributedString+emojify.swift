//
//  NSAttributedString+emojify.swift
//  iMast
//
//  Created by user on 2019/03/20.
//  Copyright © 2019 rinsuki. All rights reserved.
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
