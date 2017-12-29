//
//  EventListener.swift
//  iMast
//
//  Created by user on 2017/12/29.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import Foundation

class Event<T> {
    struct EventListener<T> {
        var id: String
        var listener: (_: T) -> Void
        var event: Event<T>
    }
    var listeners: [String: (_: T) -> Void] = [:]
    
    @discardableResult
    func on(_ listenerFunc: @escaping (_: T) -> Void) -> EventListener<T> {
        var listenerId = genRandomString()
        while listeners[listenerId] != nil {
            listenerId = genRandomString()
        }
        let listener = EventListener(id: listenerId, listener: listenerFunc, event: self)
        listeners[listenerId] = listener.listener
        return listener
    }
    
    @discardableResult
    func onBackground(_ listenerFunc: @escaping (_: T) -> Void) -> EventListener<T> {
        return self.on { content in
            DispatchQueue(label: "jp.pronama.imast.eventlistener.background").async {
                listenerFunc(content)
            }
        }
    }
    func emit(_ content: T) {
        listeners.forEach { (arg) in
            let (_, listener) = arg
            listener(content)
        }
    }
    func unsubscribe(id: String) {
        listeners[id] = nil
    }
}
