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
import KeychainAccess

public class MastodonUserToken: Equatable {
    public var id: String?
    public var token: String
    public var tokenAvailable: Bool {
        token.count > 0
    }
    public var app: MastodonApp
    public var name: String?
    public var screenName: String?
    public var avatarUrl: String?
    
    public var acct: String {
        return "\(self.screenName ?? "")@\(self.app.instance.hostName)"
    }
    
    init(app: MastodonApp, token: String) {
        self.app = app
        self.token = token
        self.id = genRandomString()
    }
    
    func getHeader() -> [String: String] {
        print(UserAgentString)
        return [
            "Authorization": "Bearer "+token,
            "Accept-Language": "en-US,en",
            "User-Agent": UserAgentString,
        ]
    }
    
    public func getIntVersion() -> Promise<Int> {
        return self.app.instance.getInfo().then { (res) -> Int in
            return MastodonVersionStringToInt(res["version"].stringValue)
        }
    }
    
    static public func initFromId(id: String) -> MastodonUserToken? {
        return try! dbQueue.inDatabase { db in
            guard let row = try Row.fetchOne(db, sql: "SELECT * from user where id=? LIMIT 1", arguments: [id]) else {
                return nil
            }
            let approw = try Row.fetchOne(db, sql: "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])!
            let app = MastodonApp.initFromRow(row: approw)
            return initFromRow(row: row, app: app)
        }
    }
    
    static func initFromRow(row: Row, app: MastodonApp) -> MastodonUserToken {
        let accessToken: String = row["access_token"] ?? (try? Keychain_ForAccessToken.get(row["id"])) ?? ""
        let usertoken = MastodonUserToken(
            app: app,
            token: accessToken
        )
        usertoken.id = row["id"]
        usertoken.name = row["name"]
        usertoken.screenName = row["screen_name"]
        usertoken.avatarUrl = row["avatar_url"]
        return usertoken
    }

    static public func getLatestUsed() -> MastodonUserToken? {
        do {
            return try dbQueue.inDatabase { db in
                if let row = try Row.fetchOne(db, sql: "SELECT * from user ORDER BY last_used DESC LIMIT 1") {
                    let approw = try Row.fetchOne(db, sql: "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])!
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
    
    static public func findUserToken(userName: String, instance: String) throws -> MastodonUserToken? {
        return try dbQueue.inDatabase { db -> MastodonUserToken? in
            guard let row = try Row.fetchOne(db, sql: "SELECT * FROM user WHERE screen_name=? AND app_id IN (SELECT id FROM app WHERE instance_hostname = ?) ORDER BY last_used DESC LIMIT 1", arguments: [userName, instance]) else {
                return nil
            }
            guard let approw = try Row.fetchOne(db, sql: "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]]) else {
                return nil
            }
            let app = MastodonApp.initFromRow(row: approw)
            return initFromRow(row: row, app: app)
        }
    }
    
    static public func getAllUserTokens() -> [MastodonUserToken] {
        do {
            return try dbQueue.inDatabase { db in
                return try getAllUserTokens(in: db)
            }
        } catch {
            print(error)
            return []
        }
    }
    
    static public func getAllUserTokens(in db: Database) throws -> [MastodonUserToken] {
        var usertokens: [MastodonUserToken] = []
        let rows = try Row.fetchAll(db, sql: "SELECT * from user ORDER BY last_used DESC")
        for row in rows {
            let approw = try Row.fetchOne(db, sql: "SELECT * from app where id=? LIMIT 1", arguments: [row["app_id"]])!
            let app = MastodonApp.initFromRow(row: approw)
            usertokens.append(initFromRow(row: row, app: app))
        }
        return usertokens
    }
    
    public func save() throws {
        print("save", self.screenName ?? "undefined screenName")
        try dbQueue.inDatabase { db in
            try save(in: db)
        }
    }
    
    public func save(in db: Database) throws {
        var token: String? = self.token
        #if os(macOS) // TODO: 6.0 あたりで iOS でも Keychain を使うようにする
        if let id = self.id, self.tokenAvailable {
            try Keychain_ForAccessToken.set(self.token, key: id)
            token = nil
        }
        #endif
        let idFound = try Row.fetchOne(db, sql: "SELECT * from user WHERE id=? ORDER BY last_used DESC LIMIT 1", arguments: [
            self.id,
            ]) != nil
        try db.execute(sql: !idFound ?
            "INSERT INTO user (app_id, access_token, name, screen_name, avatar_url, instance_hostname, id) VALUES (?,?,?,?,?,?,?)"
        :   "UPDATE user SET app_id=?,access_token=?,name=?,screen_name=?,avatar_url=?,instance_hostname=? WHERE id=?", arguments: [
            self.app.id,
            token,
            self.name ?? self.screenName,
            self.screenName,
            self.avatarUrl,
            self.app.instance.hostName,
            self.id,
        ])
    }
    
    @discardableResult
    public func use() -> Bool {
        do {
            try dbQueue.inDatabase { db in
                try db.execute(sql: "UPDATE user SET last_used=? WHERE id=?", arguments: [
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
    
    public func delete() throws {
        try dbQueue.inDatabase { db in
            try db.beginTransaction()
            try db.execute(sql: "DELETE FROM state_restoration WHERE user=?", arguments: [
                self.id,
            ])
            try db.execute(sql: "DELETE FROM user WHERE id=?", arguments: [
                self.id,
            ])
            try db.commit()
        }
    }
    
    static var verifyCredentialsCache: [String: JSON] = [:]
    
    public func getUserInfo(cache: Bool = false) async throws -> JSON {
        if cache, let cacheObj = MastodonUserToken.verifyCredentialsCache[self.acct] {
            return cacheObj
        }
        let response = try await getJSON("accounts/verify_credentials")
        self.name = response["display_name"].string
        if self.name == nil || self.name?.isEmpty == true {
            self.name = response["name"].string
        }
        self.screenName = response["username"].string
        self.avatarUrl = response["avatar"].string
        if let avatarUrl = self.avatarUrl, !avatarUrl.isEmpty, avatarUrl.first == "/" { // ホスト名がない！！！
            self.avatarUrl = "https://"+self.app.instance.hostName+self.avatarUrl!
        }
        if response["error"].isEmpty {
            MastodonUserToken.verifyCredentialsCache[self.acct] = response
        }
        return response
    }
    
    internal func request<E: MastodonEndpointProtocol>(_ ep: E) async throws -> E.Response {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = "https"
        urlBuilder.host = app.instance.hostName
        urlBuilder.percentEncodedPath = ep.endpoint
        urlBuilder.queryItems = ep.query
        if urlBuilder.queryItems?.count == 0 {
            urlBuilder.queryItems = nil
        }
        let headers = getHeader()
        var request = URLRequest(url: try urlBuilder.asURL())
        request.httpMethod = ep.method
        if let (body, contentType) = try ep.body() {
            request.httpBody = body
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        print(request.httpMethod!, request.url!)
        let (data, response) = try await URLSession.shared.data(for: request)
        return try E.Response.decode(
            data: data,
            httpHeaders: (response as! HTTPURLResponse).allHeaderFields as! [String: String]
        )
    }
    
    @available(*, deprecated)
    func getJSON(_ endpoint: String, params: [URLQueryItem] = []) async throws -> JSON {
        print("GET", endpoint)
        
        var urlBuilder = URLComponents(url: URL(string: endpoint, relativeTo: URL(string: "https://\(self.app.instance.hostName)/api/v1/")!)!, resolvingAgainstBaseURL: true)!
        urlBuilder.queryItems = params
        if urlBuilder.queryItems?.count == 0 {
            urlBuilder.queryItems = nil
        }
        let headers = getHeader()
        var request = URLRequest(url: try urlBuilder.asURL())
        print(request.url)
        request.httpMethod = "GET"
        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        print(request.httpMethod!, request.url!)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
            do {
                let error = try JSONDecoder.forMastodonAPI.decode(MastodonErrorResponse.self, from: data)
                throw APIError.errorReturned(errorMessage: error.error, errorHttpCode: response.statusCode)
            } catch {
                throw APIError.unknownResponse(errorHttpCode: response.statusCode, errorString: .init(data: data, encoding: .utf8))
            }
        }
        return try JSON(data: data)
    }
    
    public func upload(file: Data, mimetype: String, filename: String = "imast_upload_file") async throws -> MastodonAttachment {
        let request = try await withCheckedThrowingContinuation { continuation in
            Alamofire.upload(
                multipartFormData: { (multipartFormData) in
                    multipartFormData.append(file, withName: "file", fileName: filename, mimeType: mimetype)
                },
                to: "https://\(self.app.instance.hostName)/api/v1/media",
                method: .post,
                headers: self.getHeader()
            ) { encodingResult in
                switch encodingResult {
                case .success(let request, _, _):
                    continuation.resume(returning: request)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        let (data, urlRes): (Data, HTTPURLResponse) = try await withCheckedThrowingContinuation { continuation in
            request.responseData { res in
                switch res.result {
                case .success(let data):
                    let urlRes = res.response!
                    continuation.resume(returning: (data, urlRes))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        if urlRes.statusCode < 300 {
            do {
                return try JSONDecoder.forMastodonAPI.decode(MastodonAttachment.self, from: data)
            } catch {
                throw error
            }
        } else {
            if let error = try? JSONDecoder().decode(MastodonErrorResponse.self, from: data).error {
                throw APIError.errorReturned(errorMessage: error, errorHttpCode: urlRes.statusCode)
            } else {
                throw APIError.unknownResponse(errorHttpCode: urlRes.statusCode, errorString: .init(data: data, encoding: .utf8))
            }
        }
    }
    
    public static func == (lhs: MastodonUserToken, rhs: MastodonUserToken) -> Bool {
        return lhs.id == rhs.id
    }
}
