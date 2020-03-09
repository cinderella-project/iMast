//
//  MastodonNotification.swift
//  iMast
//
//  Created by rinsuki on 2018/01/09.
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
import Hydra

public struct MastodonNotification: Codable {
    public let id: MastodonID
    public let type: String
    public let status: MastodonPost?
    public let account: MastodonAccount?
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

extension MastodonUserToken {
    public func getNotification(id: MastodonID) -> Promise<MastodonNotification> {
        return self.get("notifications/"+id.string).then { res in
            return try MastodonNotification.decode(json: res)
        }
    }
}

extension MastodonEndpoint {
    public struct GetNotifications: MastodonEndpointProtocol {
        public typealias Response = [MastodonNotification]
        
        public let endpoint = "/api/v1/notifications"
        public let method = "GET"
        public var query: [URLQueryItem] {
            var q = [URLQueryItem]()
            if let limit = limit { q.append(.init(name: "limit", value: limit.description)) }
            for excludedType in excludedTypes {
                q.append(.init(name: "exclude_types[]", value: excludedType))
            }
            paging?.addToQuery(&q)
            return q
        }
        public let body: Data? = nil
        
        public var excludedTypes: [String]
        public var limit: Int?
        public var paging: MastodonPagingOption?
        
        public init(limit: Int? = nil, paging: MastodonPagingOption? = nil, excludedTypes: [String] = []) {
            self.limit = limit
            self.paging = paging
            self.excludedTypes = excludedTypes
        }

    }
}
