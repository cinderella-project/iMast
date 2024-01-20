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

struct PushServiceWrapper<T: Decodable>: Decodable, JSONAPIEndpointResponse {
    var result: T
}

protocol PushServiceEndpointProtocol: JSONAPIEndpointProtocol {
    var httpMethod: HTTPMethod { get }
}

extension PushServiceEndpointProtocol {
    var method: String { httpMethod.rawValue }
}

struct PushServiceToken: Codable, Sendable, Identifiable {
    struct PushServiceTokenNotifyFlags: Codable, Sendable {
        var follow: Bool
        var followRequest: Bool
        var mention: Bool
        var boost: Bool
        var favourite: Bool
    }
    var notify: PushServiceTokenNotifyFlags
    var acct: String
    var instance: String
    var userName: String
    var _id: String
    var id: String { _id }

    
    func update() async throws -> PushServiceToken {
        return try await PushService.send(withAuth: true, PushService.Endpoints.UpdatePushSettingsPerToken(
            tokenId: _id,
            notify: notify
        )).result
    }
    
    func delete() async throws {
        let res = try await PushService.send(withAuth: true, PushService.Endpoints.DeletePushSettingsToken(tokenId: _id))
        assert(res.result == "success")
    }
}

enum PushService {
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
    
    static func send<E: PushServiceEndpointProtocol>(withAuth: Bool, _ ep: E) async throws -> E.Response {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = "https"
        urlBuilder.host = "imast-backend.rinsuki.net"
        urlBuilder.percentEncodedPath = ep.endpoint
        urlBuilder.queryItems = ep.query
        if urlBuilder.queryItems?.count == 0 {
            urlBuilder.queryItems = nil
        }
        var request = URLRequest(url: urlBuilder.url!)
        request.httpMethod = ep.method
        if let (body, contentType) = try ep.body() {
            request.httpBody = body
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        let bundleIdentifier = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String) ?? "(null)"
        let bundleReadableVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "(null)"
        let buildNumber = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "(null)"
        request.setValue("iMast/\(bundleReadableVersion) (\(bundleIdentifier); build:\(buildNumber); \(UserAgentPlatformString) \(UserAgentPlatformVersionString)) PushService", forHTTPHeaderField: "User-Agent")

        if withAuth {
            request.setValue(try getAuthorizationHeader(), forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)

        if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
            throw APIError.unknownResponse(errorHttpCode: response.statusCode, errorString: .init(data: data, encoding: .utf8))
        }
        return try E.Response.decode(
            data: data,
            httpHeaders: (response as! HTTPURLResponse).allHeaderFields as! [String: String]
        )
    }
    
    static func register() async throws {
        let device = await UIDevice.current
        let request = await MainActor.run {
            return Endpoints.Register(deviceName: device.platform, deviceVersion: device.systemVersion, timestamp: Int(Date().timeIntervalSince1970))
        }
        let res = try await send(withAuth: false, request)
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
        let buildNumber = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String).map { Int($0) } ?? nil
        Task {
            try await send(withAuth: true, Endpoints.UpdateDeviceToken(
                isSandbox: isSandbox,
                deviceToken: deviceToken.reduce("") { $0 + String(format: "%.2hhx", $1)},
                buildNumber: buildNumber
            ))
        }
    }
    
    static func getRegisterAccounts() async throws -> [PushServiceToken] {
        return try await send(withAuth: true, Endpoints.GetRegisteredAccount()).result
    }
    
    static func getAuthorizeUrl(host: String) async throws -> URL {
        return try await send(withAuth: true, Endpoints.GetAuthorizeURL(host: host)).url
    }
    
    static func unRegister() async throws {
        let result = try await send(withAuth: true, Endpoints.Unregister())
        assert(result.result == "success")
        try self.deleteAuthInfo()
    }
    
    static func deleteAuthInfo() throws {
        try Keychain_ForPushBackend.remove("userId")
        try Keychain_ForPushBackend.remove("secret")
    }
    
    enum Endpoints {
        struct Register: PushServiceEndpointProtocol, Encodable {
            struct Response: Codable, JSONAPIEndpointResponse {
                var id: String
                var secret: String
            }
            
            var endpoint: String { "/push/api/v1/create" }
            var httpMethod: HTTPMethod { .post }
            
            var deviceName: String
            var deviceVersion: String
            var timestamp: Int
            
            enum CodingKeys: String, CodingKey {
                case deviceName
                case deviceVersion
                case timestamp
            }
        }
        
        struct UpdateDeviceToken: PushServiceEndpointProtocol, Encodable {
            typealias Response = DecodableVoid
            
            var endpoint: String { "/push/api/v1/device-token" }
            var httpMethod: HTTPMethod { .put }
            
            var isSandbox: Bool
            var deviceToken: String
            var buildNumber: Int?
            
            enum CodingKeys: String, CodingKey {
                case isSandbox
                case deviceToken
                case buildNumber
            }
        }
        
        struct GetRegisteredAccount: PushServiceEndpointProtocol {
            typealias Response = PushServiceWrapper<[PushServiceToken]>
            
            var endpoint: String { "/push/api/v1/my-accounts" }
            var httpMethod: HTTPMethod { .get }
        }
        
        struct GetAuthorizeURL: PushServiceEndpointProtocol, Encodable {
            struct Response: Decodable, JSONAPIEndpointResponse {
                let url: URL
            }
            
            var endpoint: String { "/push/api/v1/get-url" }
            var httpMethod: HTTPMethod { .post }
            
            let host: String
            
            enum CodingKeys: String, CodingKey {
                case host
            }
        }
        
        struct Unregister: PushServiceEndpointProtocol {
            typealias Response = PushServiceWrapper<String>
            
            var endpoint: String { "/push/api/v1/my-accounts" }
            var httpMethod: HTTPMethod { .delete }
        }
        
        struct UpdatePushSettingsPerToken: PushServiceEndpointProtocol, Encodable {
            typealias Response = PushServiceWrapper<PushServiceToken>
            
            var endpoint: String { "/push/api/v1/my-accounts/" + tokenId }
            var httpMethod: HTTPMethod { .put }
            
            let tokenId: String
            var notify: PushServiceToken.PushServiceTokenNotifyFlags
            
            enum CodingKeys: String, CodingKey {
                case notify
            }
        }
        
        struct DeletePushSettingsToken: PushServiceEndpointProtocol {
            typealias Response = PushServiceWrapper<String>
            
            var endpoint: String { "/push/api/v1/my-accounts/" + tokenId }
            var httpMethod: HTTPMethod { .delete }
            
            let tokenId: String
        }
    }
}
