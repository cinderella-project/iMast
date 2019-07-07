//
//  MastodonSearchResult.swift
//  iMast
//
//  Created by user on 2018/01/10.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Hydra

struct MastodonSearchResult: Codable {
    let accounts: [MastodonAccount]
    let posts: [MastodonPost]
    let hashtags: [String]
    enum CodingKeys: String, CodingKey {
        case accounts
        case posts = "statuses"
        case hashtags
    }
}

extension MastodonUserToken {
    func search(q: String, resolve: Bool = true) -> Promise<MastodonSearchResult> { 
        return self.get("search", params: ["q": q, "resolve": resolve]).then { res -> MastodonSearchResult in
            return try MastodonSearchResult.decode(json: res)
        }
    }
}
