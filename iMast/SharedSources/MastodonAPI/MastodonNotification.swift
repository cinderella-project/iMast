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
    func getNoficitaions() -> Promise<[MastodonNotification]> {
        return self.get("notifications").then { res in
            return try res.arrayValue.map { try MastodonNotification.decode(json: $0) }
        }
    }
    func getNoficitaions(sinceId: MastodonID) -> Promise<[MastodonNotification]> {
        return self.get("notifications", params: ["since_id": sinceId.raw]).then { res in
            return try res.arrayValue.map { try MastodonNotification.decode(json: $0) }
        }
    }
}
