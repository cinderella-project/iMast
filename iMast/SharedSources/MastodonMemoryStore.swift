//
//  MastodonMemoryStore.swift
//  iMast
//
//  Created by user on 2019/07/09.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import Notifwift

class MastodonMemoryStore<T: MastodonMemoryStorable> {
    private let notificationCenter = NotificationCenter()
    fileprivate(set) var container: [MastodonID: T] = [:]
    fileprivate var chain: [MastodonID: [MastodonID]] = [:]

    func addObserver(observer: Any, selector: Selector, id: MastodonID) {
        self.notificationCenter.addObserver(
            observer,
            selector: selector,
            name: .init(id.string),
            object: nil
        )
    }
    
    func removeObserver(observer: Any, id: MastodonID) {
        self.notificationCenter.removeObserver(observer, name: .init(id.string), object: nil)
    }
    
    func change(obj: T) {
        print("changed", self, obj.id)
        let isFirst = container[obj.id] == nil
        container[obj.id] = obj
        if isFirst {
            obj.setChain(store: self)
        }
        self.notificationCenter.post(name: .init(obj.id.string), object: obj)
        obj.changeChain(store: self)
    }
    
    /// 通知チェーンに追加する。
    /// from が更新されたら、ブーストで投稿を含んでいる to も更新されるイメージ。
    /// - Parameter from: 通知チェーンの発火元
    /// - Parameter to: 通知チェーンの通知先
    fileprivate func addChain(from: MastodonID, to: MastodonID) {
        if from == to {
            fatalError("INFINITIE LOOP YEAAAAAAAAAAH")
        }
        print("\(from.string) -> \(to.string)")
        var chainArr = self.chain[from] ?? []
        chainArr.append(to)
        self.chain[from] = chainArr
    }
}

protocol MastodonMemoryStorable: MastodonIDAvailable {
    func changeChain(store: MastodonMemoryStore<Self>)
    
    func setChain(store: MastodonMemoryStore<Self>)
}

extension MastodonPost: MastodonMemoryStorable {
    func changeChain(store: MastodonMemoryStore<MastodonPost>) {
        for chain in store.chain[self.id] ?? [] {
            var boost = store.container[chain]!
            if boost.repost?.value.id == self.id {
                boost.repost = .value(self)
            }
            store.change(obj: boost)
        }
    }
    
    func setChain(store: MastodonMemoryStore<MastodonPost>) {
        if let orig = self.repost?.value {
            store.addChain(from: orig.id, to: self.id)
        }
    }
}

class MastodonMemoryStoreContainer {
    let post = MastodonMemoryStore<MastodonPost>()
}

fileprivate var MastodonMemoryStoreArray: [String: MastodonMemoryStoreContainer] = [:]

extension MastodonMemoryStoreContainer {
    static subscript(index: MastodonUserToken) -> MastodonMemoryStoreContainer {
        let store: MastodonMemoryStoreContainer
        guard let id = index.id else {
            fatalError("MastodonUserToken.id is nil")
        }
        if let currentStore = MastodonMemoryStoreArray[id] {
            store = currentStore
        } else {
            store = MastodonMemoryStoreContainer()
            MastodonMemoryStoreArray[id] = store
        }
        return store
    }
}

extension MastodonUserToken {
    var memoryStore: MastodonMemoryStoreContainer {
        return MastodonMemoryStoreContainer[self]
    }
}
