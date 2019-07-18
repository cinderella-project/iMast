//
//  MastodonNotification.swift
//  iMast
//
//  Created by user on 2018/01/09.
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

class MastodonNotification: Codable {
    let id: MastodonID
    let type: String
    let status: MastodonPost?
    let account: MastodonAccount?
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}

extension MastodonUserToken {
    func getNoficitaions(limit: Int? = nil, sinceId: MastodonID? = nil, maxId: MastodonID? = nil) -> Promise<[MastodonNotification]> {
        var params: [String: Any] = [:]
        if let limit = limit {
            params["limit"] = limit
        }
        if let sinceId = sinceId {
            params["since_id"] = sinceId.raw
        }
        if let maxId = maxId {
            params["max_id"] = maxId.raw
        }
        return self.get("notifications", params: params).then { res in
            return try res.arrayValue.map { try MastodonNotification.decode(json: $0) }
        }
    }
    
    func getNotification(id: MastodonID) -> Promise<MastodonNotification> {
        return self.get("notifications/"+id.string).then { res in
            return try MastodonNotification.decode(json: res)
        }
    }
}
