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
}

extension MastodonUserToken {
    func getNoficitaions(sinceId: MastodonID? = nil) -> Promise<[MastodonNotification]> {
        var params: [String: Any] = [:]
        if let sinceId = sinceId {
            params["since_id"] = sinceId.raw
        }
        return self.get("notifications", params: params).then { res in
            return try res.arrayValue.map { try MastodonNotification.decode(json: $0) }
        }
    }
}
