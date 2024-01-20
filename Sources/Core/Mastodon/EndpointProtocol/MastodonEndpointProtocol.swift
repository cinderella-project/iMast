//
//  MastodonEndpointProtocol.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/03/09.
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
import Hydra

public protocol APIEndpointProtocol {
    associatedtype Response: APIEndpointResponse, Sendable
    
    /// e.g. "/api/v1/account". you need to percent-encoding on some characters.
    var endpoint: String { get }
    var method: String { get }

    var query: [URLQueryItem] { get }
    func body() throws -> (Data, contentType: String)?
}

extension APIEndpointProtocol {
    public var query: [URLQueryItem] { return [] }
    public func body() throws -> (Data, contentType: String)? {
        return nil
    }
}

public protocol JSONAPIEndpointProtocol: APIEndpointProtocol {}

extension JSONAPIEndpointProtocol where Self: Encodable {
    public func body() throws -> (Data, contentType: String)? {
        return (try JSONEncoder().encode(self), "application/json")
    }
}

public protocol APIEndpointResponse {
    static func decode(data: Data, httpHeaders: [String: String]) throws -> Self
}

public protocol JSONAPIEndpointResponse: APIEndpointResponse {}

extension JSONAPIEndpointResponse where Self: Decodable {
    public static func decode(data: Data, httpHeaders: [String: String]) throws -> Self {
        let decoder = JSONDecoder.forMastodonAPI
        return try decoder.decode(Self.self, from: data)
    }
}

extension Array: JSONAPIEndpointResponse, APIEndpointResponse where Self: Decodable, Element: JSONAPIEndpointResponse {
    public static func decode(data: Data, httpHeaders: [String: String]) throws -> Self {
        let decoder = JSONDecoder.forMastodonAPI
        return try decoder.decode(Self.self, from: data)
    }
}

public typealias MastodonEndpointResponse = JSONAPIEndpointResponse

public protocol MastodonEndpointProtocol: JSONAPIEndpointProtocol {}

extension MastodonEndpointProtocol {
    public func request(with token: MastodonUserToken, session: URLSession = .shared) async throws -> Self.Response {
        return try await token.request(self, session: session)
    }
    
    @available(*, deprecated, message: "Use native async/await version instead.")
    public func request(with token: MastodonUserToken) -> Promise<Self.Response> {
        return Promise { resolve, reject, context in
            Task {
                do {
                    resolve(try await request(with: token))
                } catch {
                    reject(error)
                }
            }
        }
    }
}

public protocol MastodonAnonymousEndpointProtocol: MastodonEndpointProtocol {}

extension MastodonAnonymousEndpointProtocol {
    public func request(to instance: MastodonInstance, session: URLSession = .shared) async throws -> Self.Response {
        return try await instance.request(self, session: session)
    }
}
