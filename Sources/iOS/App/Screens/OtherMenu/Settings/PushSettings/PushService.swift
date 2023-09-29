//
//  PushService.swift
//  iMast
//
//  Created by rinsuki on 2018/07/15.
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

import Alamofire
import Foundation
import KeychainAccess
import iMastiOSCore

enum PushServiceError: Error {
    case networkError(message: String?)
    case responseError(message: String?, httpCode: Int)
    case unknownError
    case serverError(message: String, httpCode: Int)
    case notRegistered
}

struct PushServiceWrapper<T: Codable>: Codable {
    var result: T
}

struct PushServiceToken: Codable, Sendable, Identifiable {
    final class PushServiceTokenNotifyFlags: Codable, Sendable {
        var follow: Bool
        var followRequest: Bool
        var mention: Bool
        var boost: Bool
        var favourite: Bool

        @available(*, deprecated, message: "Do not use.")
        init() {
            fatalError("Swift 4.1 work around")
        }
    }
    var notify: PushServiceTokenNotifyFlags
    var acct: String
    var instance: String
    var userName: String
    var _id: String
    var id: String { _id }

    
    func update() async throws -> PushServiceToken {
        let result: PushServiceWrapper<PushServiceToken> = try await Alamofire.request(
            "https://imast-backend.rinsuki.net/push/api/v1/my-accounts/"+self._id,
            method: .put,
            parameters: ["notify": [
                "follow": self.notify.follow,
                "boost": self.notify.boost,
                "mention": self.notify.mention,
                "favourite": self.notify.favourite,
                "followRequest": self.notify.followRequest,
                // swiftlint:disable trailing_comma
            ]],
            encoding: JSONEncoding.default,
            headers: ["Authorization": try PushService.getAuthorizationHeader()]
        ).responseDecodable()
        return result.result
    }
    
    func delete() async throws {
        let result: PushServiceWrapper<String> = try await Alamofire.request(
            "https://imast-backend.rinsuki.net/push/api/v1/my-accounts/"+self._id,
            method: .delete,
            headers: ["Authorization": try PushService.getAuthorizationHeader()]
        ).responseDecodable()
    }
}

class PushService {

    static func getAuthorizationHeader() throws -> String {
        let time = Int(Date().timeIntervalSince1970)
        guard let userId = try Keychain_ForPushBackend.getString("userId"), let secret = try Keychain_ForPushBackend.getString("secret") else {
            throw PushServiceError.notRegistered
        }
        return "CustomV1 \(userId):\((secret + ":" + String(time)).sha256!.lowercased()):\(time)"
    }
    
    static func isRegistered() throws -> Bool {
        if try Keychain_ForPushBackend.getString("userId") == nil { return false }
        if try Keychain_ForPushBackend.getString("secret") == nil { return false }
        return true
    }
    
    static func register() async throws {
        let device = await UIDevice.current
        let params = [
            "deviceName": await device.platform,
            "deviceVersion": await device.systemVersion,
            "timestamp": Int(Date().timeIntervalSince1970),
        ] as Parameters
        class Response: Codable {
            var id: String
            var secret: String
        }
        let res: Response = try await Alamofire.request(
                "https://imast-backend.rinsuki.net/push/api/v1/create",
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default
        ).responseDecodable()
        try Keychain_ForPushBackend.set(res.id, key: "userId")
        try Keychain_ForPushBackend.set(res.secret, key: "secret")
    }
    
    static func updateDeviceToken(deviceToken: Data) {
        guard let auth = try? self.getAuthorizationHeader() else {
            return
        }
        #if DEBUG
        let isSandbox = true
        #else
        let isSandbox = false
        #endif
        var params: Parameters = [
            "isSandbox": isSandbox,
            "deviceToken": deviceToken.reduce("") { $0 + String(format: "%.2hhx", $1)},
        ]
        if let versionString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            params["buildNumber"] = Float(versionString)
        }
        Alamofire.request("https://imast-backend.rinsuki.net/push/api/v1/device-token", method: .put, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": auth])
    }
    
    static func getRegisterAccounts() async throws -> [PushServiceToken] {
        let res: PushServiceWrapper<[PushServiceToken]> = try await Alamofire.request(
            "https://imast-backend.rinsuki.net/push/api/v1/my-accounts",
            method: .get,
            headers: ["Authorization": try self.getAuthorizationHeader()]
        ).responseDecodable()
        return res.result
    }
    
    static func getAuthorizeUrl(host: String) async throws -> URL {
        class Wrapper: Codable { var url: URL }
        let res: Wrapper = try await Alamofire.request(
            "https://imast-backend.rinsuki.net/push/api/v1/get-url",
            method: .post,
            parameters: ["host": host],
            encoding: JSONEncoding.default,
            headers: ["Authorization": try self.getAuthorizationHeader()]
        ).responseDecodable()
        return res.url
    }
    
    static func unRegister() async throws {
        let res: PushServiceWrapper<String> = try await Alamofire.request(
            "https://imast-backend.rinsuki.net/push/api/v1/my-accounts",
            method: .delete,
            headers: ["Authorization": try self.getAuthorizationHeader()]
        ).responseDecodable()
        try self.deleteAuthInfo()
    }
    
    static func deleteAuthInfo() throws {
        try Keychain_ForPushBackend.remove("userId")
        try Keychain_ForPushBackend.remove("secret")
    }
}
