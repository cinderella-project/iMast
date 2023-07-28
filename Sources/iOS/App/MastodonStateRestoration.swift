//
//  MastodonStateRestoration.swift
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
import GRDB
import UIKit
import iMastiOSCore

public struct MastodonStateRestoration: PersistableRecord, Decodable, FetchableRecord {
    static public let databaseTableName: String = "state_restoration"
    
    public var systemPersistentIdentifier: String
    public var userId: String?
    public var displayingScreen: [String] = []

    public var userToken: MastodonUserToken? {
        get {
            guard let id = userId else { return nil }
            return MastodonUserToken.initFromId(id: id)
        }
        set(token) {
            userId = token?.id
        }
    }
    
    public func encode(to container: inout PersistenceContainer) {
        container["system_persistent_identifier"] = systemPersistentIdentifier
        container["user"] = userId
        if displayingScreen.contains(where: { $0.contains(".") }) {
            container["displaying_screen"] = "json:" + String(data: try! JSONEncoder().encode(displayingScreen), encoding: .utf8)!
        } else {
            container["displaying_screen"] = String(displayingScreen.joined(separator: "."))
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case systemPersistentIdentifier = "system_persistent_identifier"
        case userId = "user"
        case displayingScreen = "displaying_screen"
    }
    
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<MastodonStateRestoration.CodingKeys> = try decoder.container(keyedBy: MastodonStateRestoration.CodingKeys.self)
        
        self.systemPersistentIdentifier = try container.decode(String.self, forKey: MastodonStateRestoration.CodingKeys.systemPersistentIdentifier)
        self.userId = try container.decodeIfPresent(String.self, forKey: MastodonStateRestoration.CodingKeys.userId)
        let displayingScreen = try container.decode(String.self, forKey: MastodonStateRestoration.CodingKeys.displayingScreen)
        if displayingScreen.hasPrefix("json:") {
            let withoutPrefix = displayingScreen[displayingScreen.index(displayingScreen.startIndex, offsetBy: 5)...]
            self.displayingScreen = try JSONDecoder().decode([String].self, from: withoutPrefix.data(using: .utf8)!)
        } else {
            self.displayingScreen = displayingScreen.split(separator: ".").map { String($0) }
        }
        print("displayingScreen", displayingScreen, self.displayingScreen)
    }
    
    public init(systemPersistentIdentifier: String) {
        self.systemPersistentIdentifier = systemPersistentIdentifier
    }
}

extension UISceneSession {
    public var mastodonStateRestoration: MastodonStateRestoration {
        return try! dbQueue.inDatabase { db -> MastodonStateRestoration in
            if let record = try MastodonStateRestoration.fetchOne(db, key: [
                MastodonStateRestoration.CodingKeys.systemPersistentIdentifier.rawValue: persistentIdentifier,
            ]) {
                return record
            }
            let record = MastodonStateRestoration(systemPersistentIdentifier: persistentIdentifier)
            print("New Scene: \(persistentIdentifier)")
            try record.save(db)
            return record
        }
    }
}
