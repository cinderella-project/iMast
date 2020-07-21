//
//  MastodonEndpoint.Relationship.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/07/21.
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
    public enum Relationship {
        public struct Get: MastodonEndpointProtocol {
            public typealias Response = [MastodonAccountRelationship]
            public let endpoint = "/api/v1/accounts/relationships"
            public let method = "GET"
            public var query: [URLQueryItem] {
                ids.map { URLQueryItem(name: "id[]", value: $0.string) }
            }
            
            var ids: [MastodonID]
            
            public init(ids: [MastodonID]) {
                self.ids = ids
            }
            
            public init(accounts: [MastodonAccount]) {
                self.ids = accounts.map { $0.id }
            }
        }
        
        public struct Follow: MastodonEndpointProtocol {
            public typealias Response = MastodonAccountRelationship
            public var endpoint: String { "/api/v1/accounts/\(target.id.string)/follow" }
            public let method = "POST"
            
            var target: MastodonAccount
            
            public init(target: MastodonAccount) {
                self.target = target
            }
        }
        
        public struct Unfollow: MastodonEndpointProtocol {
            public typealias Response = MastodonAccountRelationship
            public var endpoint: String { "/api/v1/accounts/\(target.id.string)/unfollow" }
            public let method = "POST"
            
            var target: MastodonAccount
            
            public init(target: MastodonAccount) {
                self.target = target
            }
        }
        
        public struct Mute: MastodonEndpointProtocol {
            public typealias Response = MastodonAccountRelationship
            public var endpoint: String { "/api/v1/accounts/\(target.id.string)/mute" }
            public let method = "POST"
            
            var target: MastodonAccount
            
            public init(target: MastodonAccount) {
                self.target = target
            }
        }
        
        public struct Unmute: MastodonEndpointProtocol {
            public typealias Response = MastodonAccountRelationship
            public var endpoint: String { "/api/v1/accounts/\(target.id.string)/unmute" }
            public let method = "POST"
            
            var target: MastodonAccount
            
            public init(target: MastodonAccount) {
                self.target = target
            }
        }
        
        public struct Block: MastodonEndpointProtocol {
            public typealias Response = MastodonAccountRelationship
            public var endpoint: String { "/api/v1/accounts/\(target.id.string)/block" }
            public let method = "POST"
            
            var target: MastodonAccount
            
            public init(target: MastodonAccount) {
                self.target = target
            }
        }
        
        public struct Unblock: MastodonEndpointProtocol {
            public typealias Response = MastodonAccountRelationship
            public var endpoint: String { "/api/v1/accounts/\(target.id.string)/unblock" }
            public let method = "POST"
            
            var target: MastodonAccount
            
            public init(target: MastodonAccount) {
                self.target = target
            }
        }
    }
}
