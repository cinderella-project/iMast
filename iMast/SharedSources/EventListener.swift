//
//  EventListener.swift
//  iMast
//
//  Created by rinsuki on 2017/12/29.
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
        let uniqueId = genRandomString()
        return self.on { content in
            DispatchQueue(label: "jp.pronama.imast.eventlistener.background."+uniqueId).async {
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
