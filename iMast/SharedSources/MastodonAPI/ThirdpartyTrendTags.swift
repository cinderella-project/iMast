//
//  ThirdpartyTrendTags.swift
//  iMast
//
//  Created by user on 2018/10/28.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import Foundation
import Hydra

struct ThirdpartyTrendsTags: Codable {
    let updatedAt: Date
    let score: [String: Float]
    
    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case score
    }
}

extension MastodonUserToken {
    func getTrendTags() -> Promise<ThirdpartyTrendsTags> {
        return self.get("trend_tags").then { res -> ThirdpartyTrendsTags in
            return try ThirdpartyTrendsTags.decode(json: res)
        }
    }
}
