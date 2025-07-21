//
//  iMastExtensionKit.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2025/07/01.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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
import ExtensionKit

public struct SocialUser: Codable {
    public var uri: String
    public var acct: String
    
    public init(uri: String, acct: String) {
        self.uri = uri
        self.acct = acct
    }
}

public struct SocialPost: Codable {
    public var uri: String
    public var author: SocialUser
    
    public init(uri: String, author: SocialUser) {
        self.uri = uri
        self.author = author
    }
}

public enum PostActionResult: Codable {
    case composeReply(text: String)
}

public protocol _SocialExtension: AnyObject, Sendable, AppExtension {
    
}

extension _SocialExtension {
}

public protocol PostActionExtension: _SocialExtension {
    func performAction(for post: SocialPost) -> PostActionResult?
}

extension PostActionExtension {
    public var configuration: ConnectionHandler {
        return ConnectionHandler { request in
            request.accept { [weak self] (post: SocialPost) in
                return self?.performAction(for: post)
            }
        }
    }
}
