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
import Ikemen

public let appGroupFileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!

public extension UIViewController {
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

public extension UIView {
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
public func urlComponentsToDict(url: URL) -> [String: String] {
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

public func numToCommaString(_ num: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = NumberFormatter.Style.decimal
    return formatter.string(from: num as NSNumber)!
}

public enum PostFabLocation: String, CustomStringConvertible, CaseIterable {
    public var description: String {
        switch self {
        case .leftCenter:
            return CoreL10n.PostFab.Locations.leftCenter
        case .rightCenter:
            return CoreL10n.PostFab.Locations.rightCenter
        case .leftBottom:
            return CoreL10n.PostFab.Locations.leftBottom
        case .centerBottom:
            return CoreL10n.PostFab.Locations.centerBottom
        case .rightBottom:
            return CoreL10n.PostFab.Locations.rightBottom
        }
    }
    
    case leftCenter
    case rightCenter
    case leftBottom
    case centerBottom
    case rightBottom
}

public let UserDefaultsAppGroup = UserDefaults.init(suiteName: appGroupIdentifier)!
