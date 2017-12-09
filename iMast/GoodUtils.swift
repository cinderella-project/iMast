//
//  GoodUtils.swift
//  iOSの各種APIの便利なラッパー。
//
//  Created by rinsuki on 2017/04/25.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import Foundation
import UIKit
import Hydra
import Alamofire
import SwiftyJSON
import Starscream
import XCGLogger

let log = XCGLogger.default

func WARN(_ message: String) {
    log.warning(message)
}

var emojidict = JSON(parseJSON: String(data: try! Data(contentsOf:URL(fileURLWithPath: Bundle.main.path(forResource: "emoji", ofType: "json")!)), encoding: .utf8)!)

extension UIViewController {
    func alertWithPromise(title: String = "", message: String = "") -> Promise<Void> {
        print("alert", title, message)
        return Promise<Void>(in: .main) { resolve, reject in
            print("alert", title, message)
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                resolve()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func confirm(title: String = "", message: String = "", okButtonMessage:String = "OK", style:UIAlertActionStyle = .default, cancelButtonMessage:String = "キャンセル") -> Promise<Bool> {
        return Promise<Bool>(in: .main) { resolve, reject in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: okButtonMessage, style: style, handler: { action in
                resolve(true)
            }))
            alert.addAction(UIAlertAction(title: cancelButtonMessage, style: .cancel, handler: { action in
                resolve(false)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func alert(title: String = "", message: String = "") {
        alertWithPromise(title: title, message: message).then {}
    }
    
    func errorWithPromise(errorMsg: String = "不明なエラー") -> Promise<Void>{
        let promise = alertWithPromise(
            title: "内部エラー",
            message: "あれ？何かがおかしいようです。\nこのメッセージは通常このアプリにバグがあるときに表示されます。\nもしよければ、下のエラーメッセージを開発者にお伝え下さい。\nエラーメッセージ: \(errorMsg)\n同じことをしようとしてもこのエラーが出る場合は、アプリを再起動してみてください。"
        ).then {}
        return promise
    }
    func error(errorMsg: String = "") {
        errorWithPromise(errorMsg: errorMsg).then {}
    }
    
    func apiErrorWithPromise(_ errorMsg: String? = nil, _ httpNumber: Int? = nil) -> Promise<Void>{
        let errorMessage:String = String(format: "エラーメッセージ:\n%@ (%@)\n\nエラーメッセージに従っても解決しない場合は、アプリを再起動してみてください。", arguments:[
            errorMsg ?? "不明なエラー(iMast)",
            String(httpNumber ?? -1)
        ])
        return alertWithPromise(
            title: "APIエラー",
            message: errorMessage
        )
    }
    func apiError(_ errorMsg: String? = nil, _ httpNumber: Int? = nil) {
        apiErrorWithPromise(errorMsg, httpNumber).then {}
    }
    func apiError(_ json: JSON) {
        apiError(json["error"].string, json["_response_code"].int)
    }
}

extension UIView {
    var viewController: UIViewController? {
        get {
            var responder:UIResponder? = self as UIResponder
            while responder != nil {
                if responder!.isKind(of: UIViewController.self) {
                    return responder as! UIViewController
                }
                responder = responder?.next
            }
            return nil
        }
    }
}

// クエリ文字列をDictionaryに変換するやつ
func urlComponentsToDict(url: URL) -> Dictionary<String, String> {
    let comp = NSURLComponents(url: url, resolvingAgainstBaseURL: false)!
    var dict:Dictionary<String, String> = Dictionary<String, String>()
    
    if comp.queryItems == nil {
        return dict
    }
    
    comp.queryItems!.forEach { item in
        dict[item.name] = item.value
    }
    
    return dict
}
var html2ascache:[String:NSAttributedString?] = [:]
var html2ascacheavail:[String:Bool] = [:]
extension String {
    var sha256: String! {
        if let cstr = self.cString(using: String.Encoding.utf8) {
            var chars = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(
                cstr,
                CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)),
                &chars
            )
            return chars.map { String(format: "%02X", $0) }.reduce("", +)
        }
        return nil
    }
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.locale=Locale(identifier: "en_US")
        formatter.dateFormat="yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZZZZ"
        return formatter.date(from: self)!
    }
    //絵文字など(2文字分)も含めた文字数を返します
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    //正規表現の検索をします
    func pregMatch(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.count > 0
    }
    
    //正規表現の検索結果を利用できます
    func pregMatch(pattern: String, options: NSRegularExpression.Options = []) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return []
        }
        var matches: [String] = []
        let targetStringRange = NSRange(location: 0, length: self.count)
        let results = regex.matches(in: self, options: [], range: targetStringRange)
        for i in 0 ..< results.count {
            for j in 0 ..< results[i].numberOfRanges {
                let range = results[i].rangeAt(j)
                matches.append((self as NSString).substring(with: range))
            }
        }
        return matches
    }
    
    //正規表現の置換をします
    func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: with)
    }
    
    func replace(_ target: String, _ to: String) -> String{
        return self.replacingOccurrences(of: target, with: to)
    }
    
    func parseText2HTML() -> NSAttributedString? {
        if !self.replace("<p>","").replace("</p>","").contains("<") {
            return nil
        }
        if html2ascacheavail[self] ?? false {
            return html2ascache[self] ?? nil
        }
        
        // 受け取ったデータをUTF-8エンコードする
        let encodeData = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        // 表示データのオプションを設定する
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue as AnyObject
        ]
        
        // 文字列の変換処理
        var attributedString:NSAttributedString?
        attributedString = try? NSAttributedString(
            data: encodeData!,
            options: attributedOptions,
            documentAttributes: nil
        )
        html2ascache[self] = attributedString
        
        return attributedString
    }
    
    func emojify(custom_emoji: [JSON] = [], profile_emoji: [JSON] = []) -> String {
        var retstr = self
        retstr.pregMatch(pattern: ":.+?:").forEach { (emoji) in
            if emojidict[emoji].string != nil {
                retstr = retstr.replace(emoji, emojidict[emoji].string!)
            }
        }
        (custom_emoji + profile_emoji).forEach { (emoji) in
            print(emoji)
            if emoji["shortcode"].stringValue.count == 0 {
                return
            }
            let html = "<img src=\"\(emoji["url"].stringValue)\" style=\"height:1em;width:1em;\">"
            retstr = retstr.replace(":\(emoji["shortcode"].stringValue):", html)
                .replace(":@\(emoji["shortcode"].stringValue):", html)
        }
        return retstr
    }
    
    func format(_ params: CVarArg...) -> String{
        return String(format: self, arguments: params)
    }
    
    func trim(_ start: Int) -> String {
        return self.substring(with: self.index(self.startIndex, offsetBy:start)..<self.endIndex)
    }
    func trim(_ start: Int, _ length: Int) -> String {
        return self.substring(with: self.index(self.startIndex, offsetBy:start)..<self.index(self.startIndex, offsetBy: start + length))
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


extension UIDevice {
    var platform: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let mirror = Mirror(reflecting: systemInfo.machine)
        
        let characters = mirror.children
            .flatMap { $0.value as? Int8 }
            .filter { $0 != 0 }
            .map { Character(UnicodeScalar(UInt8($0))) }
        
        return String(characters)
    }
}

enum APIError: Error {
    case `nil`(String)
    case alreadyError () // すでにエラーをユーザーに伝えているときに使う
    case errorReturned(errorMessage: String, errorHttpCode: Int) // APIがまともにエラーを返してきた場合
    case unknownResponse(errorHttpCode: Int) // APIがJSONではない何かを返してきた場合
    case decodeFailed () // 画像のデコードに失敗したときのエラー
}

enum UserDefaultsName: String {
    case autoResizeSize = "autoResizeSize"
}

class DateUtils {
    class func dateFromString(_ string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    class func stringFromDate(_ date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

func numToCommaString(_ num: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = NumberFormatter.Style.decimal
    return formatter.string(from: num as NSNumber)!
}

var websockets:[WebSocket] = []
func allDisconnectWebSocket() {
    websockets.forEach { (socket) in
        print("disconnect "+socket.currentURL.absoluteString)
        socket.disconnect()
    }
    websockets = []
}

var defaultValues: [String: Any] = [
    "streaming_autoconnect": "always",
    "append_mediaurl": true,
    "new_account_via": "iMast",
    "follow_relationships_old": false,
    "timeline_username_fontsize": Float(17),
    "timeline_text_fontsize": Float(14),
    "timeline_icon_size": Float(48),
    "widget_format": "{clipboard}",
    "widget_filter": "",
    "nowplaying_format": "#nowplaying {title} - {artist} ({albumTitle})",
    "visibility_emoji": true,
    "thumbnail_height": Int(50),
    "webm_vlc_open": true,
]

func MastodonVersionStringToInt(_ versionStr_: String) -> Int {
    var versionStr = versionStr_
    var versionInt = 500
    if(versionStr.trim(0, 1) == "v") {
        versionStr = versionStr.trim(1)
    }
    var versionStrs = versionStr.components(separatedBy: ".")
    if versionStrs.count == 1 {
        versionStrs.append("0")
    }
    if versionStrs.count == 2 {
        versionStrs.append("0")
    }
    if versionStrs.count >= 4 {
        WARN("versionStrs.count is over 3!")
    }
    print(versionStrs)
    versionInt += (1000 * 100 * 100) * versionStrs[0].parseInt()
    versionInt += (1000 * 100) * versionStrs[1].parseInt()
    versionInt += (1000) * versionStrs[2].parseInt()
    let rc_match = versionStrs[2].pregMatch(pattern: "rc([0-9]+)") as [String]
    print("rc", rc_match)
    if rc_match.count >= 2 { // rc version
        let rc_ver = rc_match[1].parseInt()
        versionInt -= 400
        versionInt += rc_ver
    }
    print(versionInt)
    return versionInt
}

let VisibilityString = ["public", "unlisted", "private", "direct"]
let VisibilityLocalizedString = ["公開", "未収蔵", "非公開", "ダイレクト"]
let VisibilityDescriptionString = ["LTLやフォロワーのHTL等に流れます", "LTLやハッシュタグ検索には出ません", "あなたのフォロワーのみ見れます", "リプライを飛ばした対象の人にのみ見れます"]
let UserDefaultsAppGroup = UserDefaults.init(suiteName: "group.jp.pronama.imast")!
