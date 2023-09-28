//
//  MastodonList.swift
//  iMast
//
//  Created by rinsuki on 2018/01/12.
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

public struct MastodonList: Codable, MastodonEndpointResponse, Sendable {
    public init(id: MastodonID, title: String) {
        self.id = id
        self.title = title
    }
    
    public let id: MastodonID
    public let title: String
}

extension MastodonList: Hashable {
}

extension MastodonEndpoint {
    public struct MyLists: MastodonEndpointProtocol {
        public typealias Response = [MastodonList]
        public let endpoint = "/api/v1/lists"
        public let method = "GET"
        
        public init() {
        }
    }
    
    public struct JoinedLists: MastodonEndpointProtocol {
        public typealias Response = [MastodonList]
        public var endpoint: String { "/api/v1/accounts/\(accountId.string)/lists" }
        public let method = "GET"
        
        public var accountId: MastodonID
        
        public init(account: MastodonAccount) {
            accountId = account.id
        }
    }
    
    public struct CreateList: MastodonEndpointProtocol, Encodable {
        public init(title: String) {
            self.title = title
        }
        
        public typealias Response = MastodonList
        public let endpoint = "/api/v1/lists"
        public let method = "POST"
        
        public var title: String
    }
    
    public struct GetListFromId: MastodonEndpointProtocol {
        public init(id: MastodonID) {
            self.listId = id
        }
        
        public typealias Response = MastodonList
        public var endpoint: String { "/api/v1/lists/\(listId.string)" }
        public let method = "GET"
        
        public var listId: MastodonID
    }
    
    public struct UpdateList: MastodonEndpointProtocol, Encodable {
        public init(list: MastodonList, title: String) {
            self.listId = list.id
            self.title = title
        }
        
        public typealias Response = MastodonList
        public var endpoint: String { "/api/v1/lists/\(listId.string)" }
        public let method = "PUT"
        
        public var listId: MastodonID
        public var title: String
        
        enum CodingKeys: String, CodingKey {
            case title
        }
    }
    
    public struct AddAccountsToList: MastodonEndpointProtocol, Encodable {
        public init(list: MastodonList, accounts: [MastodonAccount]) {
            self.listId = list.id
            self.accountIds = accounts.map { $0.id }
        }
        
        public typealias Response = DecodableVoid
        public var endpoint: String { "/api/v1/lists/\(listId.string)/accounts" }
        public let method = "POST"
        
        public var listId: MastodonID
        public var accountIds: [MastodonID]
        
        enum CodingKeys: String, CodingKey {
            case accountIds = "account_ids"
        }
    }
    
    public struct DeleteAccountsFromList: MastodonEndpointProtocol, Encodable {
        public init(list: MastodonList, accounts: [MastodonAccount]) {
            self.listId = list.id
            self.accountIds = accounts.map { $0.id }
        }
        
        public typealias Response = DecodableVoid
        public var endpoint: String { "/api/v1/lists/\(listId.string)/accounts" }
        public let method = "DELETE"
        
        public var listId: MastodonID
        public var accountIds: [MastodonID]
        
        enum CodingKeys: String, CodingKey {
            case accountIds = "account_ids"
        }
    }
    
    public struct DeleteList: MastodonEndpointProtocol {
        public init(list: MastodonList) {
            self.listId = list.id
        }
        
        public typealias Response = DecodableVoid
        public var endpoint: String { "/api/v1/lists/\(listId.string)" }
        public let method = "DELETE"
        
        public var listId: MastodonID
    }
}
