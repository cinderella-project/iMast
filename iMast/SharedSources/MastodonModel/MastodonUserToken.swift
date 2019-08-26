//
//  MastodonUserToken.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/08/24.
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

import Foundation
import SwiftyJSON
import Alamofire
import Hydra
import GRDB

public class MastodonUserToken: Equatable {
    var id: String?
    var token: String
    var app: MastodonApp
    var name: String?
    var screenName: String?
    var avatarUrl: String?
    
    var acct: String {
        return "\(self.screenName ?? "")@\(self.app.instance.hostName)"
    }
    
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
    
    static func initFromId(id: String) -> MastodonUserToken? {
        return try! dbQueue.inDatabase { db in
            guard let row = try Row.fetchOne(db, "SELECT * from user where id=? LIMIT 1", arguments: [id]) else {
                return nil
            }
            let approw = try Row.fetchOne(db, "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])!
            let app = MastodonApp.initFromRow(row: approw)
            return initFromRow(row: row, app: app)
        }
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
        do {
            return try dbQueue.inDatabase { db in
                if let row = try Row.fetchOne(db, "SELECT * from user ORDER BY last_used DESC LIMIT 1") {
                    let approw = try Row.fetchOne(db, "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])!
                    let app = MastodonApp.initFromRow(row: approw)
                    return initFromRow(row: row, app: app)
                }
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    static func findUserToken(userName: String, instance: String) throws -> MastodonUserToken? {
        return try dbQueue.inDatabase { db -> MastodonUserToken? in
            guard let row = try Row.fetchOne(db, "SELECT * FROM user WHERE screen_name=? AND app_id IN (SELECT id FROM app WHERE instance_hostname = ?) ORDER BY last_used DESC LIMIT 1", arguments: [userName, instance]) else {
                return nil
            }
            guard let approw = try Row.fetchOne(db, "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]]) else {
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
                let rows = try Row.fetchAll(db, "SELECT * from user ORDER BY last_used DESC")
                for row in rows {
                    let approw = try Row.fetchOne(db, "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])!
                    let app = MastodonApp.initFromRow(row: approw)
                    usertokens.append(initFromRow(row: row, app: app))
                }
            }
        } catch {
            print(error)
            return []
        }
        return usertokens
    }
    
    @discardableResult
    func save() -> Bool {
        print("save", self.screenName ?? "undefined screenName")
        do {
            try dbQueue.inDatabase { db in
                let idFound = try Row.fetchOne(db, "SELECT * from user WHERE id=? ORDER BY last_used DESC LIMIT 1", arguments: [
                    self.id,
                    ]) != nil
                try db.execute(!idFound ?
                    "INSERT INTO user (app_id, access_token, name, screen_name, avatar_url, instance_hostname, id) VALUES (?,?,?,?,?,?,?)"
                :   "UPDATE user SET app_id=?,access_token=?,name=?,screen_name=?,avatar_url=?,instance_hostname=? WHERE id=?", arguments: [
                    self.app.id,
                    self.token,
                    self.name ?? self.screenName,
                    self.screenName,
                    self.avatarUrl,
                    self.app.instance.hostName,
                    self.id,
                ])
            }
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    @discardableResult
    func use() -> Bool {
        do {
            try dbQueue.inDatabase { db in
                try db.execute("UPDATE user SET last_used=? WHERE id=?", arguments: [
                    Date().timeIntervalSince1970,
                    self.id,
                ])
            }
            return true
        } catch {
            print(error)
            return false
        }
        
    }
    
    @discardableResult
    func delete() -> Bool {
        do {
            try dbQueue.inDatabase { db in
                try db.execute("DELETE FROM user WHERE id=?", arguments: [
                    self.id,
                ])
            }
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    static var verifyCredentialsCache: [String: JSON] = [:]
    
    func getUserInfo(cache: Bool = false) -> Promise<JSON> {
        if cache, let cacheObj = MastodonUserToken.verifyCredentialsCache[self.acct] {
            return Promise.init(resolved: cacheObj)
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
                MastodonUserToken.verifyCredentialsCache[self.acct] = response
            }
            return Promise.init(resolved: response)
        }
    }
    
    func get(_ endpoint: String, params: [String: Any]? = nil) -> Promise<JSON> {
        return Promise<JSON> { resolve, reject, _ in
            print("GET", endpoint)
            Alamofire.request("https://\(self.app.instance.hostName)/api/v1/"+endpoint, parameters: params, headers: self.getHeader()).responseJSON { response in
                switch response.result {
                case .success(let value):
                    var json = JSON(value)
                    json["_response_code"].int = response.response?.statusCode ?? 599
                    resolve(json)
                    return
                case .failure(let error):
                    reject(error)
                    return
                }
            }
        }
    }
    
    func getWithCursorWrapper(_ endpoint: String, params: [String: Any]? = nil) -> Promise<MastodonCursorWrapper<JSON>> {
        return Promise<MastodonCursorWrapper<JSON>> { resolve, reject, _ in
            print("GET", endpoint)
            Alamofire.request("https://\(self.app.instance.hostName)/api/v1/"+endpoint, parameters: params, headers: self.getHeader()).responseJSON { response in
                if response.result.value == nil {
                    reject(APIError.nil("response.result.value"))
                    return
                }
                var json = JSON(response.result.value!)
                json["_response_code"].int = response.response?.statusCode ?? 599
                var maxId: MastodonID?
                var sinceId: MastodonID?
                if let linkHeader = (response.response?.allHeaderFields["Link"] as? String) {
                    if let maxIdStr = linkHeader.pregMatch(pattern: "max_id=(\\d+)").safe(1) {
                        maxId = MastodonID(string: maxIdStr)
                    }
                    if let sinceIdStr = linkHeader.pregMatch(pattern: "since_id=(\\d+)").safe(1) {
                        sinceId = MastodonID(string: sinceIdStr)
                    }
                }
                resolve(MastodonCursorWrapper(result: json,
                                              max: maxId,
                                              since: sinceId
                ))
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
    
    func upload(file: Data, mimetype: String, filename: String = "imast_upload_file") -> Promise<JSON> {
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
                        print("UploadError", encodingError)
                        reject(encodingError)
                        break
                    }
                }
            )
        }
    }
    
    public static func == (lhs: MastodonUserToken, rhs: MastodonUserToken) -> Bool {
        return lhs.id == rhs.id
    }
}