//
//  MastodonEndpointResponseWithPaging.swift
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

public struct MastodonEndpointResponseWithPaging<Content: MastodonEndpointResponse>: MastodonEndpointResponse {
    public var content: Content
    public var paging: MastodonPaging
    
    public static func decode(data: Data, httpHeaders: [String: String]) throws -> Self {
        Self.init(
            content: try Content.decode(data: data, httpHeaders: httpHeaders),
            paging: .init(headerString: httpHeaders["Link"] ?? "")
        )
    }
}
