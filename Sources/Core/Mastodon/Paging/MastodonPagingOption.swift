//
//  MastodonPagingOption.swift
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

public enum MastodonPagingOption {
    /// since\_id or min\_id
    case prev(String, isSinceId: Bool)
    /// max\_id
    case next(String)
    
    func addToQuery(_ to: inout [URLQueryItem]) {
        let name: String
        let val: String
        switch self {
        case .prev(let value, let isSinceId):
            name = isSinceId ? "since_id" : "min_id"
            val = value
        case .next(let value):
            name = "max_id"
            val = value
        }
        to.append(.init(name: name, value: val))
    }
}
