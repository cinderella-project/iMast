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
    public var name: String
    var redirectUri: String
    public var instance: MastodonInstance
    var id: String
    
    init(instance: MastodonInstance, info: JSON, name: String, redirectUri: String) {
        self.instance = instance
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
    static public func initFromId(appId: String) -> MastodonApp {
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
    
    public func save() throws {
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
    }
    
    public func getAuthorizeUrl() -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = instance.hostName
        components.path = "/oauth/authorize"
        var queryItems: [URLQueryItem] = [
            .init(name: "client_id", value: clientId),
            .init(name: "redirect_uri", value: redirectUri),
            .init(name: "scope", value: "read write follow"),
            .init(name: "response_type", value: "code"),
            .init(name: "state", value: id),
        ]
        components.queryItems = queryItems
        return components.url!
    }
    
    public func authorizeWithCode(code: String) async throws -> MastodonUserToken {
        struct Response: Decodable {
            var access_token: String
        }
        
        let res: Response = try await Alamofire.request("https://\(self.instance.hostName)/oauth/token", method: .post, parameters: [
            "grant_type": "authorization_code",
            "redirect_uri": self.redirectUri,
            "client_id": self.clientId,
            "client_secret": self.clientSecret,
            "code": code,
            "state": self.id,
        ]).responseDecodable()
        
        return MastodonUserToken(app: self, token: res.access_token)
    }
}
