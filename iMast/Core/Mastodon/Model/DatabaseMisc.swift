//
//  DatabaseMisc.swift
//  iMast
//
//  Created by rinsuki on 2017/04/24.
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
import Alamofire
import SwiftyJSON
import GRDB
import Hydra

let fileURL = getFileURL()
public let dbQueue = try! DatabaseQueue(path: fileURL.path)
func getFileURL() -> URL {
    let oldFileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.jp.pronama.imast")!.appendingPathComponent("imast.sqlite")
    let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.jp.pronama.imast")!.appendingPathComponent("Library/imast.sqlite")
    if !FileManager.default.fileExists(atPath: fileURL.path) && FileManager.default.fileExists(atPath: oldFileURL.path) {
        print("migrate: AppGroup -> AppGroup Library")
        try! FileManager.default.moveItem(atPath: oldFileURL.path, toPath: fileURL.path)
    }
    if !FileManager.default.fileExists(atPath: fileURL.path) && FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Library/imast.sqlite") {
        print("migrate: App Library -> AppGroup")
        try! FileManager.default.moveItem(atPath: NSHomeDirectory()+"/Library/imast.sqlite", toPath: fileURL.path)
    }
    return fileURL
}
public func initDatabase() {
    var migrator = DatabaseMigrator()
    migrator.registerMigration("v1") { db in
        try db.execute(sql: "CREATE TABLE IF NOT EXISTS app (id text primary key, client_id text, client_secret text, redirect_uri text, instance_hostname text, name text)", arguments: [])
        try db.execute(sql: "CREATE TABLE IF NOT EXISTS user (id text primary key, access_token text, instance_hostname text, app_id text, name text, screen_name text, avatar_url text, last_used int)", arguments: [])
    }
    migrator.registerMigration("state_restoration") { db in
        try db.create(table: "state_restoration") { table in
            table.column("system_persistent_identifier", .text).primaryKey()
            table.column("user", .text).references("user", column: "id", onDelete: .restrict, onUpdate: .cascade, deferred: true)
            table.column("displaying_screen", .text)
        }
    }
    try! migrator.migrate(dbQueue)
}
