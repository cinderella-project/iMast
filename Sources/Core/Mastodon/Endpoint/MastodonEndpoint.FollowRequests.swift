//
//  MastodonEndpoint.FollowRequests.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/07/20.
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

extension MastodonEndpoint {
    public enum FollowRequests {
        public struct List: MastodonEndpointProtocol {
            public typealias Response = MastodonEndpointResponseWithPaging<[MastodonAccount]>
            
            public let endpoint = "/api/v1/follow_requests"
            public let method = "GET"
            public var query: [URLQueryItem] {
                var q = [URLQueryItem]()
                paging?.addToQuery(&q)
                return q
            }
            
            public var paging: MastodonPagingOption?
            
            public init(paging: MastodonPagingOption? = nil) {
                self.paging = paging
            }
        }
        
        public struct Judge: MastodonEndpointProtocol {
            public typealias Response = MastodonAccountRelationship
            
            public enum JudgeType: String {
                case authorize
                case reject
            }
            
            public var endpoint: String { "/api/v1/follow_requests/\(target.id.string)/\(judge.rawValue)" }
            public let method = "POST"
            
            public var target: MastodonAccount
            public var judge: JudgeType
            
            public init(target: MastodonAccount, judge: JudgeType) {
                self.target = target
                self.judge = judge
            }
        }
    }
}
