//
//  MastodonModel.swift
//  iMast
//
//  Created by rinsuki on 2017/04/24.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import GRDB
import Hydra

let fileURL = getFileURL()
let dbQueue = try! DatabaseQueue(path: fileURL.path)
func getFileURL() -> URL{
    let oldFileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.jp.pronama.imast")!.appendingPathComponent("imast.sqlite")
    let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.jp.pronama.imast")!.appendingPathComponent("Library/imast.sqlite")
    if !FileManager.default.fileExists(atPath: fileURL.path) && FileManager.default.fileExists(atPath: oldFileURL.path) {
        print("migrate: AppGroup -> AppGroup Library")
        try! FileManager.default.moveItem(atPath: oldFileURL.path, toPath: fileURL.path)
    }
    if !FileManager.default.fileExists(atPath: fileURL.path) && FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Library/imast.sqlite"){
        print("migrate: App Library -> AppGroup")
        try! FileManager.default.moveItem(atPath: NSHomeDirectory()+"/Library/imast.sqlite", toPath: fileURL.path)
    }
    return fileURL
}
func initDatabase() {
    try! dbQueue.inDatabase { db in
        print("--start db migrate")
        try db.execute("CREATE TABLE IF NOT EXISTS app (id text primary key, client_id text, client_secret text, redirect_uri text, instance_hostname text, name text)", arguments: nil)
        try db.execute("CREATE TABLE IF NOT EXISTS user (id text primary key, access_token text, instance_hostname text, app_id text, name text, screen_name text, avatar_url text, last_used int)", arguments: nil)
        print("--end db migrate")
    }
}

var mastodonInstanceInfoCache: [String:JSON] = [:]

public class MastodonInstance {
    var hostName: String
    var name: String?
    var description: String?
    var email: String?
        
    init(hostName: String = "mastodon.social") {
        self.hostName = hostName.pregReplace(pattern: ".+\\@", with: "")
    }
    
    func getInfo() -> Promise<JSON>{
        return Promise<JSON> { resolve, reject, _ in
            if mastodonInstanceInfoCache[self.hostName] != nil {
                resolve(mastodonInstanceInfoCache[self.hostName]!)
                return
            }
            Alamofire.request("https://\(self.hostName)/api/v1/instance").responseJSON { res in
                // print(res)
                if res.error != nil {
                    reject(res.error!)
                    return
                }
                if res.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                let json = JSON(res.result.value!)
                self.name = json["name"].string
                self.description = json["description"].string
                self.email = json["email"].string
                mastodonInstanceInfoCache[self.hostName] = json
                resolve(json)
            }
        }
    }
    
    func createApp(name: String = "iMast", redirect_uri:String = "imast://callback/") -> Promise<MastodonApp> {
        return Promise<MastodonApp> { resolve, reject, _ in
            var params = [
                "client_name": name,
                "scopes": "read write follow",
                "redirect_uris": redirect_uri,
            ]
            if name == "iMast" {
                params["website"] = "https://cinderella-project.github.io/iMast/"
            }
            Alamofire.request("https://\(self.hostName)/api/v1/apps", method: .post, parameters: params).responseJSON { res in
                if res.error != nil {
                    reject(res.error!)
                    return
                }
                if res.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                let json = JSON(res.result.value!)
                print(json)
                resolve(MastodonApp(instance: self, info: json, name: name, redirectUri: redirect_uri))
            }
        }
    }
}

public class MastodonApp {
    var clientId: String
    var clientSecret: String
    var name: String
    var redirectUri: String
    var instance: MastodonInstance
    var id: String
    
    init(instance:MastodonInstance, info: JSON, name: String, redirectUri: String) {
        self.instance = instance
        print(info)
        clientId = info["client_id"].stringValue
        clientSecret = info["client_secret"].stringValue
        self.name = name
        self.redirectUri = redirectUri
        self.id = genRandomString()
    }
    
    init(instance:MastodonInstance, clientId: String, clientSecret: String, name: String, redirectUri: String) {
        self.instance = instance
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.name = name
        self.redirectUri = redirectUri
        self.id = genRandomString()
    }
    static func initFromId(appId: String) -> MastodonApp {
        var app:MastodonApp?
        try! dbQueue.inDatabase { db in
            let row = try (try Row.fetchCursor(db, "SELECT * from app where id=? LIMIT 1", arguments: [appId])).next()!
            app = initFromRow(row: row)
        }
        return app!
    }
    static func initFromRow(row: Row) -> MastodonApp {
        let app = MastodonApp(
            instance: MastodonInstance(hostName: row["instance_hostname"]),
            clientId: row["client_id"],
            clientSecret: row["client_secret"],
            name: row["name"],
            redirectUri: row["redirect_uri"]
        )
        app.id = row["id"]
        return app
    }
    
    @discardableResult
    func save() -> Bool {
        do {
            try dbQueue.inDatabase { db in
                try db.execute("INSERT OR REPLACE INTO app (id, client_id, client_secret, name, redirect_uri, instance_hostname) VALUES (?,?,?,?,?,?)", arguments: [
                    self.id,
                    self.clientId,
                    self.clientSecret,
                    self.name,
                    self.redirectUri,
                    self.instance.hostName
                ])
            }
            return true
        } catch (let e) {
            print(e)
            return false
        }
    }
    
    func getAuthorizeUrl() -> String {
        return "https://\(instance.hostName)/oauth/authorize?client_id=\(clientId)&redirect_uri=\(self.redirectUri)&scope=read+write+follow&response_type=code&state="+self.id
    }
    
    func authorizeWithCode(code: String) -> Promise<MastodonUserToken> {
        return Promise<MastodonUserToken> { resolve, reject, _ in
            Alamofire.request("https://\(self.instance.hostName)/oauth/token", method: .post, parameters: [
                "grant_type": "authorization_code",
                "redirect_uri": self.redirectUri,
                "client_id": self.clientId,
                "client_secret": self.clientSecret,
                "code": code,
                "state": self.id
            ]).responseJSON { res in
                if res.result.value == nil {
                    reject(APIError.nil("res.response.value"))
                    return
                }
                if res.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                let json = JSON(res.result.value!)
                print(json)
                resolve(MastodonUserToken(app: self, token: json["access_token"].stringValue))
            }
        }
    }
    
    func authorizeWithPassword(email: String, password: String) -> Promise<MastodonUserToken>{
        return Promise() { resolve, reject, _ in
            Alamofire.request("https://\(self.instance.hostName)/oauth/token", method: .post, parameters: [
                "grant_type": "password",
                "username": email,
                "password": password,
                "client_id": self.clientId,
                "client_secret": self.clientSecret,
                "scope": "read write follow"
            ]).responseJSON { response in
                if ((response.response?.url?.absoluteString) ?? "").contains("/auth/sign_in") { // MastodonのAPIはクソ!w
                    reject(APIError.errorReturned(errorMessage: "Emailかパスワードが誤っています", errorHttpCode: -1))
                    return
                }
                if response.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                var json = JSON(response.result.value!)
                json["_response_code"].int = response.response?.statusCode ?? 599
                print(json)
                if json["_response_code"].intValue >= 400 {
                    if json["error"].string != nil {
                        reject(APIError.errorReturned(errorMessage: json["error"].stringValue, errorHttpCode: json["_response_code"].intValue))
                        return
                    } else {
                        reject(APIError.unknownResponse(errorHttpCode: json["_response_code"].intValue))
                        return
                    }
                }
                if json["access_token"].string == nil {
                    reject(APIError.nil("access_token"))
                    return
                }
                resolve(MastodonUserToken(app: self, token: json["access_token"].stringValue))
            }
        }
    }
}

public class MastodonUserToken {
    var id: String?
    var token: String
    var app: MastodonApp
    var name: String?
    var screenName: String?
    var avatarUrl: String?
    
    
    init(app: MastodonApp, token: String) {
        self.app = app
        self.token = token
        self.id = genRandomString()
    }
    
    func getHeader() -> [String: String] {
        print("iMast/\((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)) (iOS/\((UIDevice.current.systemVersion)))")
        return [
            "Authorization": "Bearer "+token,
            "Accept-Language": "en-US,en",
            "User-Agent": "iMast/\((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)) (iOS/\((UIDevice.current.systemVersion)))",
        ]
    }
    
    func getIntVersion() -> Promise<Int> {
        return self.app.instance.getInfo().then { (res) -> Int in
            return MastodonVersionStringToInt(res["version"].stringValue)
        }
    }
    
    static func initFromId(id: String) -> MastodonUserToken {
        var usertoken:MastodonUserToken?
        try! dbQueue.inDatabase { db in
            let row = try (try Row.fetchCursor(db, "SELECT * from user where id=? LIMIT 1", arguments: [id])).next()!
            let approw = try (try Row.fetchCursor(db, "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])).next()!
            let app = MastodonApp.initFromRow(row: approw)
            usertoken = initFromRow(row: row, app: app)
        }
        return usertoken!
    }
    
    
    static func initFromRow(row: Row, app: MastodonApp) -> MastodonUserToken {
        let usertoken = MastodonUserToken(
            app: app,
            token: row["access_token"]
        )
        usertoken.id = row["id"]
        usertoken.name = row["name"]
        usertoken.screenName = row["screen_name"]
        usertoken.avatarUrl = row["avatar_url"]
        return usertoken
    }

    static func getLatestUsed() -> MastodonUserToken? {
        var usertoken:MastodonUserToken?
        do {
            try dbQueue.inDatabase { db in
                let row = try (try Row.fetchCursor(db, "SELECT * from user ORDER BY last_used DESC LIMIT 1")).next()
                if row != nil {
                    let approw = try (try Row.fetchCursor(db, "SELECT * from app where id=? LIMIT 1", arguments: [row!["app_id"]])).next()!
                    let app = MastodonApp.initFromRow(row: approw)
                    usertoken = initFromRow(row: row!, app: app)
                }
            }
        } catch (let e) {
            print(e)
            return nil
        }
        return usertoken
    }
    
    static func findUserToken(userName: String, instance: String) throws -> MastodonUserToken? {
        return try dbQueue.inDatabase { db -> MastodonUserToken? in
            guard let row = try (try Row.fetchCursor(db, "SELECT * FROM user WHERE screen_name=? AND app_id IN (SELECT id FROM app WHERE instance_hostname = ?) ORDER BY last_used DESC LIMIT 1", arguments: [userName, instance])).next() else {
                return nil
            }
            guard let approw = try (try Row.fetchCursor(db, "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])).next() else {
                return nil
            }
            let app = MastodonApp.initFromRow(row: approw)
            return initFromRow(row: row, app: app)
        }
    }
    
    static func getAllUserTokens() -> [MastodonUserToken] {
        var usertokens: [MastodonUserToken] = []
        do {
            try dbQueue.inDatabase { db in
                let rows = try Row.fetchCursor(db, "SELECT * from user ORDER BY last_used DESC")
                while let row = try rows.next() {
                    let approw = try (try Row.fetchCursor(db, "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])).next()!
                    let app = MastodonApp.initFromRow(row: approw)
                    usertokens.append(initFromRow(row: row, app: app))
                }
            }
        } catch (let e) {
            print(e)
            return []
        }
        return usertokens
    }
    
    @discardableResult
    func save() -> Bool {
        print("save",self.screenName ?? "undefined screenName")
        do {
            try dbQueue.inDatabase { db in
                let idFound = try (try Row.fetchCursor(db, "SELECT * from user WHERE id=? ORDER BY last_used DESC LIMIT 1",arguments: [
                    self.id
                    ])).next() != nil
                try db.execute(!idFound ?
                    "INSERT INTO user (app_id, access_token, name, screen_name, avatar_url, instance_hostname, id) VALUES (?,?,?,?,?,?,?)"
                :   "UPDATE user SET app_id=?,access_token=?,name=?,screen_name=?,avatar_url=?,instance_hostname=? WHERE id=?", arguments: [
                    self.app.id,
                    self.token,
                    self.name ?? self.screenName,
                    self.screenName,
                    self.avatarUrl,
                    self.app.instance.hostName,
                    self.id
                ])
            }
            return true
        } catch (let e) {
            print(e)
            return false
        }
    }
    
    @discardableResult
    func use() -> Bool {
        do {
            try dbQueue.inDatabase { db in
                try db.execute("UPDATE user SET last_used=? WHERE id=?", arguments: [
                    Date().timeIntervalSince1970,
                    self.id
                ])
            }
            return true
        } catch (let e) {
            print(e)
            return false
        }
        
    }
    
    @discardableResult
    func delete() -> Bool {
        do {
            try dbQueue.inDatabase { db in
                try db.execute("DELETE FROM user WHERE id=?", arguments: [
                    self.id
                ])
            }
            return true
        } catch (let e) {
            print(e)
            return false
        }
    }
    
    static var verifyCredentialsCache: [String: JSON] = [:]
    
    func getUserInfo(cache:Bool = false) -> Promise<JSON> {
        if cache && MastodonUserToken.verifyCredentialsCache["\(self.screenName ?? "")@\(self.app.instance.hostName)"] != nil {
            return Promise.init(resolved: MastodonUserToken.verifyCredentialsCache["\(self.screenName ?? "")@\(self.app.instance.hostName)"]!)
        }
        return self.get("accounts/verify_credentials").then { (response) -> Promise<JSON> in
            self.name = response["display_name"].string
            if self.name == nil || self.name?.count == 0 {
                self.name = response["name"].string
            }
            self.screenName = response["username"].string
            self.avatarUrl = response["avatar"].string
            if (self.avatarUrl != nil) && (self.avatarUrl?.count)! >= 1 && self.avatarUrl?[(self.avatarUrl?.startIndex)!] == "/" { // ホスト名がない！！！
                self.avatarUrl = "https://"+self.app.instance.hostName+self.avatarUrl!
            }
            if response["error"].isEmpty {
                MastodonUserToken.verifyCredentialsCache["\(self.screenName ?? "")@\(self.app.instance.hostName)"] = response
            }
            return Promise.init(resolved: response)
        }
    }
    
    func get(_ endpoint: String, params: [String: Any]? = nil) -> Promise<JSON> {
        return Promise<JSON> { resolve, reject, _ in
            print("GET", endpoint)
            Alamofire.request("https://\(self.app.instance.hostName)/api/v1/"+endpoint, parameters: params, headers: self.getHeader()).responseJSON { response in
                if response.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                var json = JSON(response.result.value!)
                json["_response_code"].int = response.response?.statusCode ?? 599
                resolve(json)
            }
        }
    }

    func post(_ endpoint: String, params: [String: Any]? = nil) -> Promise<JSON> {
        return Promise<JSON> { resolve, reject, _ in
            Alamofire.request("https://\(self.app.instance.hostName)/api/v1/"+endpoint, method: .post, parameters: params, headers: self.getHeader()).responseJSON { response in
                if response.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                var json = JSON(response.result.value!)
                json["_response_code"].int = response.response?.statusCode ?? 599
                resolve(json)
            }
        }
    }
    
    func put(_ endpoint: String, params: [String: Any]? = nil) -> Promise<JSON> {
        return Promise<JSON> { resolve, reject, _ in
            Alamofire.request("https://\(self.app.instance.hostName)/api/v1/"+endpoint, method: .put, parameters: params, headers: self.getHeader()).responseJSON { response in
                if response.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                var json = JSON(response.result.value!)
                json["_response_code"].int = response.response?.statusCode ?? 599
                resolve(json)
            }
        }
    }
    
    func delete(_ endpoint: String, params: [String: Any]? = nil) -> Promise<JSON> {
        return Promise<JSON> { resolve, reject, _ in
            Alamofire.request("https://\(self.app.instance.hostName)/api/v1/"+endpoint, method: .delete, parameters: params, headers: self.getHeader()).responseJSON { response in
                if response.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                var json = JSON(response.result.value!)
                json["_response_code"].int = response.response?.statusCode ?? 599
                resolve(json)
            }
        }
    }
    
    func upload(file: Data, mimetype: String, filename:String = "imast_upload_file") -> Promise<JSON> {
        return Promise<JSON> { resolve, reject, _ in
            Alamofire.upload(
                multipartFormData: { (multipartFormData) in
                    multipartFormData.append(file, withName: "file", fileName: filename, mimeType: mimetype)
                },
                to: "https://\(self.app.instance.hostName)/api/v1/media",
                method: .post,
                headers: self.getHeader(),
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        print(upload)
                        upload.responseJSON { response in
                            var json: JSON = JSON("{}")
                            if response.result.value == nil {
                                if response.response?.statusCode == 413 { // メディアデカすぎ
                                    json = JSON(parseJSON: "{}")
                                    json["error"] = JSON("画像が大きすぎます")
                                } else {
                                    reject(APIError.nil("response.result.value"))
                                    return
                                }
                            } else {
                                json = JSON(response.result.value!)
                            }
                            json["_response_code"] = JSON(response.response?.statusCode ?? 599)
                            resolve(json)
                        }
                    case .failure(let encodingError):
                        print("UploadError",encodingError)
                        reject(encodingError)
                        break
                    }
                }
            )
        }
    }
    
}

var imageCache: [String:UIImage] = [:]
var imageResizeCache: [String:[Int:UIImage]] = [:]

@available(*, unavailable)
public func getImage(url: String, size:Int = -1) -> Promise<UIImage> {
    return Promise(in: .background) { resolve, reject, _ in
        let resizedImagePath = NSHomeDirectory() + "/Library/Caches/image/" + url.sha256 + "_resize_\(String(size))_scale_"+UIScreen.main.scale.description
        if size>0 {
            if imageResizeCache[url]?[size] != nil{
                resolve(imageResizeCache[url]![size]!)
                return
            }
            if FileManager.default.fileExists(atPath:resizedImagePath) {
                print("Get From Storage(with resized image):"+url)
                do {
                    let resizedCacheImage = UIImage(data:try Data(contentsOf: URL(fileURLWithPath: resizedImagePath),options:NSData.ReadingOptions.mappedIfSafe))
                    if resizedCacheImage != nil {
                        if imageResizeCache[url] == nil {
                            imageResizeCache[url] = [:]
                        }
                        imageResizeCache[url]![size] = resizedCacheImage!
                        resolve(resizedCacheImage!)
                        return
                    }
                } catch {
                    print(error)
                    
                }
            }
        }
        if((imageCache[url] ?? nil) != nil) {
            resolve(imageCache[url]!)
            return
        }
        var img: UIImage!
        var imgData = Data()
        var isInternet = false
        if FileManager.default.fileExists(atPath: NSHomeDirectory() + "/Library/Caches/image/" + url.sha256) {
            print("Get From Storage:"+url)
            img = UIImage(data: (try? Data(contentsOf: URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/image/" + url.sha256),options:NSData.ReadingOptions.mappedIfSafe)) ?? Data())
            if img == nil {
                try? FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Library/Caches/image/" + url.sha256)
            }
        }
        if img == nil {
            print("Get From Server:"+url)
            imgData = try Data(contentsOf: URL(string: url)!,options:NSData.ReadingOptions.mappedIfSafe)
            img = UIImage(data: imgData)
            isInternet = true
            do {
                if !FileManager.default.fileExists(atPath: NSHomeDirectory() + "/Library/Caches/image") {
                    try FileManager.default.createDirectory(atPath: NSHomeDirectory() + "/Library/Caches/image", withIntermediateDirectories: false, attributes: nil)
                }
            } catch {
                print(error)
            }
        }
        if img == nil {
            print("Error Image Decode Failed:"+url)
            reject(APIError.decodeFailed())
            return
        }
        if isInternet {
            try? imgData.write(to: URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/image/" + url.sha256))
        }
        imageCache.updateValue(img!, forKey: url)
        if size > 0 {
            if imageResizeCache[url]?[size] != nil {
                img = imageResizeCache[url]![size]!
            } else {
                let resizedSize = CGSize(width: size, height:size)
                UIGraphicsBeginImageContextWithOptions(resizedSize, false, UIScreen.main.scale)
                img?.draw(in:CGRect(origin: .zero, size:resizedSize))
                img = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                if imageResizeCache[url] == nil {
                    imageResizeCache[url] = [:]
                }
                imageResizeCache[url]![size] = img
            }
        }
        resolve(img!)
    }
}
    
public func genRandomString() -> String{
    return (Date().timeIntervalSince1970*1000).description.sha256 + (arc4random().description.sha256)
}

public func genState(hostName: String) {
    return
}
