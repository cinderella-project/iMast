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
import XCGLogger
import ActionClosurable

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
    func alertWithPromise(title: String = "", message: String = "") -> Promise<Void> {
        print("alert", title, message)
        return Promise<Void>(in: .main) { resolve, reject, _ in
            print("alert", title, message)
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                resolve(Void())
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func confirm(title: String = "", message: String = "", okButtonMessage: String = "OK", style: UIAlertAction.Style = .default, cancelButtonMessage: String = "キャンセル") -> Promise<Bool> {
        return Promise<Bool>(in: .main) { resolve, reject, _ in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
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
    
    func errorWithPromise(errorMsg: String = "不明なエラー") -> Promise<Void> {
        let promise = alertWithPromise(
            title: "内部エラー",
            message: "あれ？何かがおかしいようです。\nこのメッセージは通常このアプリにバグがあるときに表示されます。\nもしよければ、下のエラーメッセージを開発者にお伝え下さい。\nエラーメッセージ: \(errorMsg)\n同じことをしようとしてもこのエラーが出る場合は、アプリを再起動してみてください。"
        ).then {}
        return promise
    }
    func error(errorMsg: String = "") {
        errorWithPromise(errorMsg: errorMsg).then {}
    }
    
    func apiErrorWithPromise(_ errorMsg: String? = nil, _ httpNumber: Int? = nil) -> Promise<Void> {
        let errorMessage: String = String(format: "エラーメッセージ:\n%@ (%@)\n\nエラーメッセージに従っても解決しない場合は、アプリを再起動してみてください。", arguments: [
            errorMsg ?? "不明なエラー(iMast)",
            String(httpNumber ?? -1),
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
    
    func errorReport(error: Error) {
        let alert = UIAlertController(title: "エラー", message: "エラーが発生しました。\n\n\(error.localizedDescription)", preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "詳しい情報を見る", style: .default, handler: { _ in
            let vc = UIViewController()
            let textView = UITextView()
            let navVC = UINavigationController(rootViewController: vc)

            vc.view = textView
            vc.title = "エラー詳細"
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, closure: { _ in
                navVC.dismiss(animated: true, completion: nil)
            })

            textView.text = "\(error)"
            
            textView.font = UIFont(name: "Menlo", size: 15)
            textView.adjustsFontForContentSizeCategory = true
            textView.isEditable = false

            self.present(navVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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

extension UIApplication {
    var viewController: UIViewController? {
        var vc = self.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        return vc
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
var html2ascache: [String: NSAttributedString?] = [:]
var html2ascacheavail: [String: Bool] = [:]
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
        formatter.locale=Locale(identifier: "en_US_POSIX")
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
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
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
                let range = results[i].range(at: j)
                matches.append((self as NSString).substring(with: range))
            }
        }
        return matches
    }
    
    //正規表現の置換をします
    func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        // swiftlint:disable force_try
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.count), withTemplate: with)
    }
    
    func replace(_ target: String, _ to: String) -> String {
        return self.replacingOccurrences(of: target, with: to)
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

extension UIDevice {
    var platform: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let mirror = Mirror(reflecting: systemInfo.machine)
        
        let characters = mirror.children
            .compactMap { $0.value as? Int8 }
            .filter { $0 != 0 }
            .map { Character(UnicodeScalar(UInt8($0))) }
        
        return String(characters)
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

class DateUtils {
    class func dateFromString(_ string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string)!
    }
    
    class func stringFromDate(_ date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

func numToCommaString(_ num: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = NumberFormatter.Style.decimal
    return formatter.string(from: num as NSNumber)!
}

/*
var defaultValues: [String: Any] = [
    "streaming_autoconnect": "always",
    "append_mediaurl": true,
    "new_account_via": "iMast",
    "follow_relationships_old": false,
    "timeline_username_fontsize": Double(17),
    "timeline_text_fontsize": Double(14),
    "timeline_icon_size": Double(48),
    "widget_format": "{clipboard}",
    "widget_filter": "",
    "nowplaying_format": "#nowplaying {title} - {artist} ({albumTitle})",
    "visibility_emoji": true,
    "thumbnail_height": Int(50),
    "webm_vlc_open": true,
]
*/

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

extension DefaultsKeys {
    static let streamingAutoConnect = DefaultsKey<String>("streaming_autoconnect", default: "always")
    static let appendMediaUrl = DefaultsKey<Bool>("append_mediaurl", default: true)
    static let newAccountVia = DefaultsKey<String>("new_account_via", default: "iMast")
    static let followRelationshipsOld = DefaultsKey<Bool>("follow_relationships_old", default: false)

    static let timelineUsernameFontsize = DefaultsKey<Double>("timeline_username_fontsize", default: 14)
    static let timelineTextFontsize = DefaultsKey<Double>("timeline_text_fontsize", default: 15)
    static let timelineIconSize = DefaultsKey<Double>("timeline_icon_size", default: 48)
    static let visibilityEmoji = DefaultsKey<Bool>("visibility_emoji", default: true)
    static let thumbnailHeight = DefaultsKey<Double>("thumbnail_height", default: 50)
    static let timelineNurunuruMode = DefaultsKey<Bool>("timeline_nurunuru_mode", default: false)
    static let timelineTextBold = DefaultsKey<Bool>("timeline_text_bold", default: false)
    static let pinnedTootLinesLimit = DefaultsKey<Double>("pinned_toot_lines_limit", default: 0)
    static let inReplyToEmoji = DefaultsKey<Bool>("in_reply_to_emoji", default: true)
    static let acctAbbr = DefaultsKey<Bool>("acct_abbr", default: true)
    static let postFabEnabled = DefaultsKey<Bool>("post_fab_enabled", default: true)
    static let postFabLocation = DefaultsKey<PostFabLocation>("post_fab_location", default: .rightBottom)

    static let webmVlcOpen = DefaultsKey<Bool>("webm_vlc_open", default: true)
    static let useAVPlayer = DefaultsKey<Bool>("use_avplayer", default: true)
    static let useUniversalLink = DefaultsKey<Bool>("use_universal_link", default: true)

    static let widgetFormat = DefaultsKey<String>("widget_format", default: "{clipboard}")
    static let widgetFilter = DefaultsKey<String>("widget_filter")

    static let nowplayingFormat = DefaultsKey<String>("nowplaying_format", default: "#nowplaying {title} - {artist} ({albumTitle})")
    static let autoResizeSize = DefaultsKey<Int>("autoResizeSize", default: 0)
    static let usingDefaultVisibility = DefaultsKey<Bool>("using_default_visibility", default: false)

    static let shareNoTwitterTracking = DefaultsKey<Bool>("share_no_twitter_tracking", default: true)
    static let deleteTootTeokure = DefaultsKey<Bool>("delete_toot_teokure", default: false)
    static let usingNowplayingFormatInShareGooglePlayMusicUrl = DefaultsKey<Bool>("using_nowplaying_format_in_share_google_play_music_url", default: false)

    static let showPushServiceError = DefaultsKey<Bool>("show_push_service_error", default: false)
    
    static let groupNotifyAccounts = DefaultsKey<Bool>("group_notify_accounts", default: true)
    static let groupNotifyTypeBoost = DefaultsKey<Bool>("group_notify_type_boost", default: false)
    static let groupNotifyTypeFavourite = DefaultsKey<Bool>("group_notify_type_favourite", default: false)
    static let groupNotifyTypeMention = DefaultsKey<Bool>("group_notify_type_mention", default: false)
    static let groupNotifyTypeFollow = DefaultsKey<Bool>("group_notify_type_follow", default: false)
    static let groupNotifyTypeUnknown = DefaultsKey<Bool>("group_notify_type_unknown", default: false)
    
    static let newHtmlParser = DefaultsKey<Bool>("new_html_parser", default: true)
    static let notifyTabInfiniteScroll = DefaultsKey<Bool>("notify_tab_infinite_scroll", default: false)
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

extension Array {
    func safe(_ index: Index) -> Element? {
        if self.count <= index || index < 0 {
            return nil
        }
        return self[index]
    }
}

func MastodonVersionStringToInt(_ versionStr_: String) -> Int {
    var versionStr = versionStr_
    var versionInt = 500
    if versionStr.trim(0, 1) == "v" {
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
let VisibilityLocalizedString = ["公開", "未収載", "フォロワー限定", "ダイレクト"]
let VisibilityDescriptionString = ["LTLやフォロワーのHTL等に流れます", "LTLやハッシュタグ検索には出ません", "あなたのフォロワーと、メンションを飛ばした対象の人のみ見れます", "メンションを飛ばした対象の人にのみ見れます"]
let UserDefaultsAppGroup = UserDefaults.init(suiteName: "group.jp.pronama.imast")!
var Defaults = UserDefaultsAppGroup
