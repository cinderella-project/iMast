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
import Hydra

struct MastodonList: Codable {
    let id: MastodonID
    let title: String
}

extension MastodonUserToken {
    func lists() -> Promise<[MastodonList]> {
        return self.get("lists").then { res in
            return try res.arrayValue.map({try MastodonList.decode(json: $0)})
        }
    }
    func lists(joinedUser: MastodonAccount) -> Promise<[MastodonList]> {
        return self.get("accounts/\(joinedUser.id.string)/lists").then { res in
            return try res.arrayValue.map({try MastodonList.decode(json: $0)})
        }
    }
    func list(title: String) -> Promise<MastodonList> {
        return self.post("lists", params: ["title": title]).then { res in
            return try MastodonList.decode(json: res)
        }
    }
    func list(list: MastodonList, title: String) -> Promise<MastodonList> {
        return self.put("lists/\(list.id.string)", params: ["title": title]).then { res in
            return try MastodonList.decode(json: res)
        }
    }
    func list(list: MastodonList, addUserIds: [MastodonID]) -> Promise<Void> {
        return self.post("lists/\(list.id.string)/accounts", params: ["account_ids": addUserIds.map { $0.raw }]).then { _ in return }
    }
    func list(list: MastodonList, removeUserIds: [MastodonID]) -> Promise<Void> {
        return self.delete("lists/\(list.id.string)/accounts", params: ["account_ids": removeUserIds.map { $0.raw }]).then { _ in return }
    }
    
    func delete(list: MastodonList) -> Promise<Void> {
        return self.delete("lists/\(list.id.string)").then { res in
            return Void()
        }
    }
}
