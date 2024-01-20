//
//  MastodonInstance.swift
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

var mastodonInstanceInfoCache: [String: MastodonInstance.Info] = [:]

#if os(macOS)
public let defaultAppName = "iMast (macOS)"
private let website = URL(string: "https://cinderella-project.github.io/iMast/mac/")!
#else
public let defaultAppName = "iMast"
private let website = URL(string: "https://cinderella-project.github.io/iMast/")!
#endif

public class MastodonInstance {
    public struct Info: Codable, MastodonEndpointResponse {
        public let version: String
        public let urls: Urls
        
        public struct Urls: Codable {
            public let streamingApi: String
            
            enum CodingKeys: String, CodingKey {
                case streamingApi = "streaming_api"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case version
            case urls
        }
    }
    
    public var hostName: String
    public var url: URL {
        return URL(string: "https://\(self.hostName)")!
    }
        
    public init(hostName: String = "mastodon.social") {
        self.hostName = hostName.replacing(/.+@/, with: "").lowercased()
    }
    
    private func makeRequest<E: MastodonEndpointProtocol>(_ ep: E) throws -> URLRequest {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = "https"
        urlBuilder.host = hostName
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
        request.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    private func parseResponse<E: MastodonEndpointProtocol>(_ ep: E, data: Data, response: URLResponse) throws -> E.Response {
        if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
            if let error = try? JSONDecoder.forMastodonAPI.decode(MastodonErrorResponse.self, from: data) {
                throw APIError.errorReturned(errorMessage: error.error, errorHttpCode: response.statusCode)
            } else {
                throw APIError.unknownResponse(errorHttpCode: response.statusCode, errorString: .init(data: data, encoding: .utf8))
            }
        }
        return try E.Response.decode(
            data: data,
            httpHeaders: (response as! HTTPURLResponse).allHeaderFields as! [String: String]
        )
    }
    
    internal func request<E: MastodonEndpointProtocol>(_ ep: E, session: URLSession = .shared, requestModifier: (inout URLRequest) -> Void) async throws -> E.Response {
        var request = try makeRequest(ep)
        requestModifier(&request)
        let (data, response) = try await session.data(for: request)
        return try parseResponse(ep, data: data, response: response)
    }
    
    internal func request<E: MastodonAnonymousEndpointProtocol>(_ ep: E, session: URLSession = .shared) async throws -> E.Response {
        return try await request(ep, session: session) { _ in }
    }
    
    public func getInfo() async throws -> Info {
        if let cache = mastodonInstanceInfoCache[self.hostName] {
            return cache
        }
        let json = try await MastodonEndpoint.GetInstanceInfo().request(to: self)
        
        mastodonInstanceInfoCache[self.hostName] = json
        return json
    }
    
    public func createApp(name: String = defaultAppName, redirect_uri: String = "imast://callback/") async throws -> MastodonApp {
        let json = try await MastodonEndpoint.CreateApp(
            clientName: name,
            scopes: "read write follow",
            redirectUri: redirect_uri,
            website: website
        ).request(to: self)
        
        return MastodonApp(instance: self, info: json, name: name, redirectUri: redirect_uri)
    }
}

extension MastodonEndpoint {
    struct GetInstanceInfo: MastodonAnonymousEndpointProtocol {
        typealias Response = MastodonInstance.Info
        
        var endpoint: String { "/api/v1/instance" }
        var method: String { "GET" }
    }
    
    struct CreateApp: MastodonAnonymousEndpointProtocol, Encodable {
        struct Response: Codable, MastodonEndpointResponse {
            let clientId: String
            let clientSecret: String
            
            enum CodingKeys: String, CodingKey {
                case clientId = "client_id"
                case clientSecret = "client_secret"
            }
        }
        
        var endpoint: String { "/api/v1/apps" }
        var method: String { "POST" }
        
        var clientName: String
        var scopes: String
        var redirectUri: String
        var website: URL
        
        enum CodingKeys: String, CodingKey {
            case clientName = "client_name"
            case scopes
            case redirectUri = "redirect_uris"
            case website
        }
    }
}
