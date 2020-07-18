//
//  GoodUtils.swift
//  iOSの各種APIの便利なラッパー。
//
//  Created by rinsuki on 2017/04/25.
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
import UIKit
import Hydra
import Alamofire
import SwiftyJSON
import Ikemen

let appGroupFileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.jp.pronama.imast")!

var emojidict = JSON(parseJSON: String(data: try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "emoji", ofType: "json")!)), encoding: .utf8)!)

#if IS_DEBUG_BUILD
    let isDebugBuild = true
#else
    let isDebugBuild = false
#endif

extension UIViewController {
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    var viewController: UIViewController? {
        var responder: UIResponder? = self as UIResponder
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc
            }
            responder = r.next
        }
        return nil
    }
}

// クエリ文字列をDictionaryに変換するやつ
func urlComponentsToDict(url: URL) -> [String: String] {
    let comp = NSURLComponents(url: url, resolvingAgainstBaseURL: false)!
    var dict: [String: String] = [:]
    
    guard let queryItems = comp.queryItems else {
        return dict
    }
    
    queryItems.forEach { item in
        dict[item.name] = item.value
    }
    
    return dict
}

extension String {
    
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.locale=Locale(identifier: "en_US_POSIX")
        formatter.dateFormat="yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZZZZ"
        return formatter.date(from: self)!
    }
    
    func format(_ params: CVarArg...) -> String {
        return String(format: self, arguments: params)
    }
    
}

extension UserDefaults {
    func exists(_ key: String) -> Bool {
        return self.object(forKey: key) != nil
    }
}

func numToCommaString(_ num: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = NumberFormatter.Style.decimal
    return formatter.string(from: num as NSNumber)!
}

enum PostFabLocation: String, WithDefaultValue, CustomStringConvertible, CaseIterable {
    var description: String {
        switch self {
        case .leftCenter:
            return "左中央"
        case .rightCenter:
            return "右中央"
        case .leftBottom:
            return "左下"
        case .centerBottom:
            return "中央下"
        case .rightBottom:
            return "右下"
        }
    }
    
    static var _defaultValue: PostFabLocation = .rightBottom
    
    case leftCenter
    case rightCenter
    case leftBottom
    case centerBottom
    case rightBottom
}

let UserDefaultsAppGroup = UserDefaults.init(suiteName: "group.jp.pronama.imast")!
var Defaults = UserDefaultsAppGroup
