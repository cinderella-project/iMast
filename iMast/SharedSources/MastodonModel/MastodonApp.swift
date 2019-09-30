//
//  MastodonApp.swift
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
import Hydra
import Alamofire
import GRDB

public class MastodonApp {
    var clientId: String
    var clientSecret: String
    var name: String
    var redirectUri: String
    var instance: MastodonInstance
    var id: String
    
    init(instance: MastodonInstance, info: JSON, name: String, redirectUri: String) {
        self.instance = instance
        print(info)
        clientId = info["client_id"].stringValue
        clientSecret = info["client_secret"].stringValue
        self.name = name
        self.redirectUri = redirectUri
        self.id = genRandomString()
    }
    
    init(instance: MastodonInstance, clientId: String, clientSecret: String, name: String, redirectUri: String) {
        self.instance = instance
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.name = name
        self.redirectUri = redirectUri
        self.id = genRandomString()
    }
    static func initFromId(appId: String) -> MastodonApp {
        return try! dbQueue.inDatabase { db in
            let row = try Row.fetchOne(db, sql: "SELECT * from app where id=? LIMIT 1", arguments: [appId])!
            return initFromRow(row: row)
        }
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
                try db.execute(sql: "INSERT OR REPLACE INTO app (id, client_id, client_secret, name, redirect_uri, instance_hostname) VALUES (?,?,?,?,?,?)", arguments: [
                    self.id,
                    self.clientId,
                    self.clientSecret,
                    self.name,
                    self.redirectUri,
                    self.instance.hostName,
                ])
            }
            return true
        } catch {
            print(error)
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
                "state": self.id,
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
    
    func authorizeWithPassword(email: String, password: String) -> Promise<MastodonUserToken> {
        return Promise { resolve, reject, _ in
            Alamofire.request("https://\(self.instance.hostName)/oauth/token", method: .post, parameters: [
                "grant_type": "password",
                "username": email,
                "password": password,
                "client_id": self.clientId,
                "client_secret": self.clientSecret,
                "scope": "read write follow",
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
                    if let error = json["error"].string {
                        reject(APIError.errorReturned(errorMessage: error, errorHttpCode: json["_response_code"].intValue))
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
