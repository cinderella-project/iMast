//
//  ThirdpartyTrendTags.swift
//  iMast
//
//  Created by user on 2018/10/28.
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

class ThirdpartyTrendsTags: Codable {
    var updatedAt: Date
    var score: [String: Float]
    
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
