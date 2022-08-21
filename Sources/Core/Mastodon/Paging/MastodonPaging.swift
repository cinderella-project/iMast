//
//  MastodonPaging.swift
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

public struct MastodonPaging {
    static let nextIdExpression = /max_id=([0-9a-zA-Z_-]+)/
    static let prevIdExpression = /(since|min)_id=([0-9a-zA-Z_-]+)/
    
    var prevIsSinceId: Bool = false
    var prevId: String?
    var nextId: String?
    
    public var prev: MastodonPagingOption? {
        guard let prevId = prevId else { return nil }
        return .prev(prevId, isSinceId: prevIsSinceId)
    }
    public var next: MastodonPagingOption? {
        get {
            guard let nextId = nextId else { return nil }
            return .next(nextId)
        }
        set {
            switch newValue {
            case .none:
                nextId = nil
            case .some(.next(let id)):
                nextId = id
            case .some(.prev):
                fatalError()
            }
        }
    }
    
    public init() {
    }
    
    public mutating func override(with: MastodonPagingOption?) {
        guard let with = with else { return }
        switch with {
        case .prev(let id, let isSinceId):
            prevId = id
            prevIsSinceId = isSinceId
        case .next(let id):
            nextId = id
        }
    }
    
    init(headerString: String) {
        if let nextId = try? Self.nextIdExpression.firstMatch(in: headerString)?.output.1 {
            self.nextId = String(nextId)
        }
        if let captures = try? Self.prevIdExpression.firstMatch(in: headerString)?.output {
            prevIsSinceId = captures.1 == "since"
            prevId = String(captures.2)
        }
    }
}
