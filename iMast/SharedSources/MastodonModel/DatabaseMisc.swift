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
let dbQueue = try! DatabaseQueue(path: fileURL.path)
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
func initDatabase() {
    var migrator = DatabaseMigrator()
    migrator.registerMigration("v1") { db in
        try db.execute("CREATE TABLE IF NOT EXISTS app (id text primary key, client_id text, client_secret text, redirect_uri text, instance_hostname text, name text)", arguments: nil)
        try db.execute("CREATE TABLE IF NOT EXISTS user (id text primary key, access_token text, instance_hostname text, app_id text, name text, screen_name text, avatar_url text, last_used int)", arguments: nil)
    }
    try! migrator.migrate(dbQueue)
}

var imageCache: [String: UIImage] = [:]
var imageResizeCache: [String: [Int: UIImage]] = [:]

@available(*, unavailable)
public func getImage(url: String, size: Int = -1) -> Promise<UIImage> {
    return Promise(in: .background) { resolve, reject, _ in
        let resizedImagePath = NSHomeDirectory() + "/Library/Caches/image/" + url.sha256 + "_resize_\(String(size))_scale_"+UIScreen.main.scale.description
        if size>0 {
            if let resizedImageCache = imageResizeCache[url]?[size] {
                resolve(resizedImageCache)
                return
            }
            if FileManager.default.fileExists(atPath: resizedImagePath) {
                print("Get From Storage(with resized image):"+url)
                do {
                    if let resizedCacheImage = UIImage(data: try Data(contentsOf: URL(fileURLWithPath: resizedImagePath), options: NSData.ReadingOptions.mappedIfSafe)) {
                        if imageResizeCache[url] == nil {
                            imageResizeCache[url] = [:]
                        }
                        imageResizeCache[url]![size] = resizedCacheImage
                        resolve(resizedCacheImage)
                        return
                    }
                } catch {
                    print(error)
                    
                }
            }
        }
        if let cacheImage = imageCache[url] {
            resolve(cacheImage)
            return
        }
        var img: UIImage!
        var imgData = Data()
        var isInternet = false
        if FileManager.default.fileExists(atPath: NSHomeDirectory() + "/Library/Caches/image/" + url.sha256) {
            print("Get From Storage:"+url)
            img = UIImage(data: (try? Data(contentsOf: URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/image/" + url.sha256), options: NSData.ReadingOptions.mappedIfSafe)) ?? Data())
            if img == nil {
                try? FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Library/Caches/image/" + url.sha256)
            }
        }
        if img == nil {
            print("Get From Server:"+url)
            imgData = try Data(contentsOf: URL(string: url)!, options: NSData.ReadingOptions.mappedIfSafe)
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
            reject(APIError.decodeFailed)
            return
        }
        if isInternet {
            try? imgData.write(to: URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/image/" + url.sha256))
        }
        imageCache.updateValue(img!, forKey: url)
        if size > 0 {
            if let resizedImageCache = imageResizeCache[url]?[size] {
                img = resizedImageCache
            } else {
                let resizedSize = CGSize(width: size, height: size)
                UIGraphicsBeginImageContextWithOptions(resizedSize, false, UIScreen.main.scale)
                img?.draw(in: CGRect(origin: .zero, size: resizedSize))
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
    
public func genRandomString() -> String {
    return (Date().timeIntervalSince1970*1000).description.sha256 + (arc4random().description.sha256)
}

public func genState(hostName: String) {
    return
}
