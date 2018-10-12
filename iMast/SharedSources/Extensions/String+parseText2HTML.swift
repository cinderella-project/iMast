//
//  String+parseText2HTML.swift
//  iMast
//
//  Created by user on 2018/09/20.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Fuzi

extension String {
    func parseText2HTMLNew(attributes: [NSAttributedStringKey: Any]) -> NSAttributedString? {
        do {
            let document = try Fuzi.HTMLDocument(string: self)
            guard let root = document.root?.children(staticTag: "body").first else {
                print("empty root")
                return NSAttributedString(string: "")
            }
            
            let fetchNodeTypes: [Fuzi.XMLNodeType] = [
                .Text,
                .Element
            ]
            
            func generateAttrStr(nodes: [XMLNode]) -> NSMutableAttributedString {
                let attrStr = NSMutableAttributedString(string: "")
                for node in nodes {
                    switch(node.type) {
                    case .Text:
                        attrStr.append(NSAttributedString(string: node.stringValue))
                    case .Element:
                        if let element = node.toElement() {
                            var childAttrStr = generateAttrStr(nodes: element.childNodes(ofTypes: fetchNodeTypes))
                            if let tagName = element.tag?.lowercased() {
                                switch tagName {
                                case "br":
                                    childAttrStr.append(NSAttributedString(string: "\n"))
                                case "p":
                                    childAttrStr.append(NSAttributedString(string: "\n\n"))
                                case "a":
                                    if let href = element.attributes["href"] {
                                        childAttrStr.addAttributes([
                                            .link: href,
                                            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                                        ], range: NSRange(location: 0, length: childAttrStr.length))
                                    }
                                case "img":
                                    if let src = element.attributes["src"], let srcUrl = URL(string: src),
                                        let srcData = try? Data(contentsOf: srcUrl) {
                                        let attachment = NSTextAttachment()
                                        attachment.image = UIImage(data: srcData)
                                        let font = attributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: CGFloat(Defaults[.timelineTextFontsize]))
                                        let size = font.lineHeight + 1
                                        attachment.bounds = CGRect(x: 0, y: 0, width: size, height: size)
                                        attachment.bounds.origin = CGPoint(x: 0, y: -4)
                                        childAttrStr = NSMutableAttributedString(attachment: attachment)
                                    }
                                default:
                                    break
                                }
                            }
                            attrStr.append(childAttrStr)
                        }
                    default:
                        print("unknown node.type", node.type)
                    }
                }
                return attrStr
            }
            
            let attrStr = generateAttrStr(nodes: root.childNodes(ofTypes: fetchNodeTypes))
            var count = 0
            for char in attrStr.string.reversed() {
                if char == "\n" {
                    count += 1
                } else {
                    break
                }
            }
            attrStr.deleteCharacters(in: NSRange(location: attrStr.length - count, length: count))
            attrStr.addAttributes(attributes, range: NSRange(location: 0, length: attrStr.length))
            return attrStr
        } catch let error {
            print("failed to parse in new parser", error)
            return nil
        }
    }
    
    func parseText2HTML(attributes: [NSAttributedStringKey: Any] = [:]) -> NSAttributedString? {
        if Defaults[.newHtmlParser], let newParserResult = self.parseText2HTMLNew(attributes: attributes) {
            return newParserResult
        }
        if !self.replace("<p>","").replace("</p>","").contains("<") {
            return nil
        }
        
        // 受け取ったデータをUTF-8エンコードする
        let encodeData = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        // 表示データのオプションを設定する
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        // 文字列の変換処理
        let attributedString = try? NSMutableAttributedString(
            data: encodeData!,
            options: attributedOptions,
            documentAttributes: nil
        )
        attributedString?.addAttributes(attributes, range: NSRange(location: 0, length: attributedString?.length ?? 0))
        return attributedString
    }
}
