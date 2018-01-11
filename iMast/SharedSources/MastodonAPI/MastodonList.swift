//
//  MastodonList.swift
//  iMast
//
//  Created by user on 2018/01/12.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Hydra

class MastodonList: Codable {
    let id: MastodonID
    let title: String
}

extension MastodonUserToken {
    func lists() -> Promise<[MastodonList]> {
        return self.get("lists").then { res in
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
    func delete(list: MastodonList) -> Promise<Void> {
        return self.delete("lists/\(list.id.string)").then { res in
            return Void()
        }
    }
}
