//
//  PushService.swift
//  iMast
//
//  Created by user on 2018/07/15.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import KeychainAccess
import PromiseKit

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

class PushServiceToken: Codable {
    class PushServiceTokenNotifyFlags: Codable {
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
    
    func update() -> Promise<PushServiceToken> {
        return Alamofire.request(
            "https://imast-backend.rinsuki.net/push/api/v1/my-accounts/"+self._id,
            method: .put,
            parameters: ["notify": [
                "follow": self.notify.follow,
                "boost": self.notify.boost,
                "mention": self.notify.mention,
                "favourite": self.notify.favourite,
                "followRequest": self.notify.followRequest,
            ]],
            encoding: JSONEncoding.default,
            headers: ["Authorization": try! PushService.getAuthorizationHeader()!]
        ).responseDecodable(PushServiceWrapper<PushServiceToken>.self).map { $0.result }
    }
    
    func delete() -> Promise<Void> {
        return Alamofire.request(
            "https://imast-backend.rinsuki.net/push/api/v1/my-accounts/"+self._id,
            method: .delete,
            headers: ["Authorization": try! PushService.getAuthorizationHeader()!]
        ).responseDecodable(PushServiceWrapper<String>.self).map { _ in ()}
    }
}

class PushService {
    
    static let keyChain = Keychain(service: "net.rinsuki.imast-backend.push").accessibility(.alwaysThisDeviceOnly)

    static func getAuthorizationHeader() throws -> String? {
        let time = Int(Date().timeIntervalSince1970)
        guard let userId = try self.keyChain.getString("userId"), let secret = try self.keyChain.getString("secret") else {
            return nil
        }
        return "CustomV1 \(userId):\((secret + ":" + String(time)).sha256!.lowercased()):\(time)"
    }
    
    static func isRegistered() throws -> Bool {
        if try self.keyChain.getString("userId") == nil { return false }
        if try self.keyChain.getString("secret") == nil { return false }
        return true
    }
    
    static func register() -> Promise<Void> {
        let params = [
            "deviceName": UIDevice.current.platform,
            "deviceVersion": UIDevice.current.systemVersion,
            "timestamp": Int(Date().timeIntervalSince1970),
        ] as Parameters
        class Response: Codable {
            var id: String
            var secret: String
        }
        return firstly {
            return Alamofire.request(
                "https://imast-backend.rinsuki.net/push/api/v1/create",
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default
            ).responseDecodable(Response.self)
        }.then { res -> Promise<Void> in
//            if response.statusCode != 200 {
//                func getMessage() -> String {
//                    guard let data = res.data else {
//                        return "(empty)"
//                    }
//                    return String(data: data, encoding: String.Encoding.utf8) ?? "(empty)"
//                }
//                rej(PushServiceError.serverError(message: getMessage(), httpCode: response.statusCode))
//                return
//            }
//            let json = JSON(data)
//            guard let userId = json["id"].string, let secret = json["secret"].string else {
//                rej(PushServiceError.unknownError)
//                return
//            }
            try! PushService.keyChain.set(res.id, key: "userId")
            try! PushService.keyChain.set(res.secret, key: "secret")
            
//            resolve(())
            return Promise.value(())
        }
    }
    
    static func updateDeviceToken(deviceToken: Data) {
        guard let auth = try! self.getAuthorizationHeader() else {
            return
        }
        let params: Parameters = [
            "isSandbox": isDebugBuild,
            "deviceToken": deviceToken.reduce("") { $0 + String(format: "%.2hhx", $1)}
        ]
        Alamofire.request("https://imast-backend.rinsuki.net/push/api/v1/device-token", method: .put, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": auth])
    }
    
    static func getRegisterAccounts() -> Promise<[PushServiceToken]> {
        typealias TokenList = [PushServiceToken]
        return firstly {
            Promise.value(try self.getAuthorizationHeader())
        }.then { auth -> Promise<PushServiceWrapper<TokenList>> in
            guard let auth = auth else {
                throw PushServiceError.notRegistered
            }
            return Alamofire.request(
                "https://imast-backend.rinsuki.net/push/api/v1/my-accounts",
                method: .get,
                headers: ["Authorization": auth]
            ).responseDecodable(PushServiceWrapper<TokenList>.self)
        }.map { $0.result }
    }
    
    static func getAuthorizeUrl(host: String) -> Promise<String> {
        class Wrapper: Codable { var url: String }
        return firstly {
            Promise.value(try self.getAuthorizationHeader())
        }.then { auth -> Promise<Wrapper> in
            guard let auth = auth else {
                throw PushServiceError.notRegistered
            }
            return Alamofire.request(
                "https://imast-backend.rinsuki.net/push/api/v1/get-url",
                method: .post,
                parameters: ["host": host],
                encoding: JSONEncoding.default,
                headers: ["Authorization": auth]
            ).responseDecodable(Wrapper.self)
        }.map { $0.url }
    }
    
    static func unRegister() -> Promise<Void> {
        return firstly {
            Promise.value(try self.getAuthorizationHeader())
        }.then { auth -> Promise<PushServiceWrapper<String>> in
            guard let auth = auth else {
                throw PushServiceError.notRegistered
            }
            return Alamofire.request(
                "https://imast-backend.rinsuki.net/push/api/v1/my-accounts",
                method: .delete,
                headers: ["Authorization": auth]
            ).responseDecodable(PushServiceWrapper<String>.self)
        }.map { result in
            try self.keyChain.remove("userId")
            try self.keyChain.remove("secret")
            return ()
        }
    }
}
