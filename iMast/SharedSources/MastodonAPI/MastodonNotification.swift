//
//  MastodonNotification.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
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
