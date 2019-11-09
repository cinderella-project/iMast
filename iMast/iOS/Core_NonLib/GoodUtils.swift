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
import XCGLogger
import Ikemen

let appGroupFileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.jp.pronama.imast")!

let log = XCGLogger.default

func WARN(_ message: String) {
    log.warning(message)
}

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
    
    var nsLength: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    func format(_ params: CVarArg...) -> String {
        return String(format: self, arguments: params)
    }
    
    func trim(_ start: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: start)..<self.endIndex])
    }
    func trim(_ start: Int, _ length: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: start)..<self.index(self.startIndex, offsetBy: start + length)])
    }
    func parseInt() -> Int {
        return Int(self.pregMatch(pattern: "^[0-9]+")[0]) ?? 0
    }
}

extension UserDefaults {
    func exists(_ key: String) -> Bool {
        return self.object(forKey: key) != nil
    }
}

enum APIError: Error {
    case `nil`(String)
    case alreadyError // すでにエラーをユーザーに伝えているときに使う
    case errorReturned(errorMessage: String, errorHttpCode: Int) // APIがまともにエラーを返してきた場合
    case unknownResponse(errorHttpCode: Int) // APIがJSONではない何かを返してきた場合
    case decodeFailed // 画像のデコードに失敗したときのエラー
    case dateParseFailed(dateString: String)
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


let jsISODateDecoder = JSONDecoder.DateDecodingStrategy.custom {
    let container = try $0.singleValueContainer()
    let str = try container.decode(String.self)
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZZZZ"
    if let d = f.date(from: str) {
        return d
    }
    // https://github.com/imas/mastodon/pull/200 への対処
    f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZZ"
    if let d = f.date(from: str) {
        return d
    }
    throw APIError.dateParseFailed(dateString: str)
}

func CodableDeepCopy<T: Codable>(_ object: T) -> T {
    // TODO: ここ `try!` 使ってええんか?
    let encoder = JSONEncoder()
    let data = try! encoder.encode(object)
    let decoder = JSONDecoder()
    return try! decoder.decode(T.self, from: data)
}

func CodableCompare<T: Codable>(_ from: T, _ to: T) -> Bool {
    let encoder = JSONEncoder()
    let fromData = try! encoder.encode(from)
    let toData = try! encoder.encode(to)
    return fromData == toData
}

extension JSONDecoder {
    static func get() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = jsISODateDecoder
        return decoder
    }
}

extension Decodable {
    static func decode(json: JSON) throws -> Self {
        if let error = json["error"].string {
            throw APIError.errorReturned(errorMessage: error, errorHttpCode: json["_response_code"].intValue)
        }
        let decoder = JSONDecoder.get()
        do {
            return try decoder.decode(self, from: json.rawData())
        } catch {
            if let error = error as? DecodingError {
                reportError(error: error)
            }
            throw error
        }
    }
}

let VisibilityString = ["public", "unlisted", "private", "direct"]
let VisibilityLocalizedString = ["公開", "未収載", "フォロワー限定", "ダイレクト"]
let VisibilityDescriptionString = ["LTLやフォロワーのHTL等に流れます", "LTLやハッシュタグ検索には出ません", "あなたのフォロワーと、メンションを飛ばした対象の人のみ見れます", "メンションを飛ばした対象の人にのみ見れます"]
let UserDefaultsAppGroup = UserDefaults.init(suiteName: "group.jp.pronama.imast")!
var Defaults = UserDefaultsAppGroup
