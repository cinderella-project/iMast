//
//  String+parseText2HTML.swift
//  iMast
//
//  Created by rinsuki on 2018/09/20.
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
import Fuzi
import SDWebImage

#if os(macOS)
typealias NSUIFont = NSFont
#else
typealias NSUIFont = UIFont
#endif

extension String {
    public func parseText2HTMLNew(attributes: [NSAttributedString.Key: Any]) -> NSAttributedString? {
        do {
            let document = try Fuzi.HTMLDocument.parse(string: self)
            guard let root = document.root?.children(staticTag: "body").first else {
                print("empty root")
                return NSAttributedString(string: "")
            }
            
            let fetchNodeTypes: [Fuzi.XMLNodeType] = [
                .Text,
                .Element,
            ]
            
            func generateAttrStr(attributes: [NSAttributedString.Key: Any], nodes: [Fuzi.XMLNode]) -> NSMutableAttributedString {
                let attrStr = NSMutableAttributedString(string: "")
                for node in nodes {
                    switch node.type {
                    case .Text:
                        attrStr.append(NSAttributedString(string: node.stringValue, attributes: attributes))
                    case .Element:
                        var attrs = attributes
                        if let element = node.toElement() {
                            let tagName = element.tag?.lowercased() ?? ""
                            // タグ前処理
                            switch tagName {
                            case "a":
                                if let href = element.attributes["href"]?.addingPercentEncoding(withAllowedCharacters: CharacterSet.init(charactersIn: Unicode.Scalar(0)...Unicode.Scalar(0x7f))) {
                                    attrs[.link] = href
                                    attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
                                }
                            case "strong", "b":
                                let font = (attrs[.font] as? NSUIFont) ?? NSUIFont.systemFont(ofSize: NSUIFont.systemFontSize)
                                #if os(macOS)
                                let newFont = NSUIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.bold), size: font.pointSize)
                                attrs[.font] = newFont
                                #else
                                if let fontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
                                    let newFont = NSUIFont(descriptor: fontDescriptor, size: font.pointSize)
                                    attrs[.font] = newFont
                                }
                                #endif
                            default:
                                break
                            }
                            
                            var childAttrStr = generateAttrStr(attributes: attrs, nodes: element.childNodes(ofTypes: fetchNodeTypes))
                            
                            // タグ後処理
                            if let tagName = element.tag?.lowercased() {
                                switch tagName {
                                case "br":
                                    childAttrStr.append(NSAttributedString(string: "\n", attributes: attrs))
                                case "p":
                                    childAttrStr.append(NSAttributedString(string: "\n\n", attributes: attrs))
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
            
            let attrStr = generateAttrStr(attributes: attributes, nodes: root.childNodes(ofTypes: fetchNodeTypes))
            var count = 0
            for char in attrStr.string.reversed() {
                if char == "\n" {
                    count += 1
                } else {
                    break
                }
            }
            attrStr.deleteCharacters(in: NSRange(location: attrStr.length - count, length: count))
            return attrStr
        } catch let error {
            print("failed to parse in new parser", error)
            return nil
        }
    }
    
    public func parseText2HTML(attributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString? {
        return parseText2HTMLNew(attributes: attributes)
    }
}
