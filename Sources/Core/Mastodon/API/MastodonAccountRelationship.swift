//
//  MastodonAccountRelationship.swift
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

public struct MastodonAccountRelationship: Codable, MastodonEndpointResponse, Sendable {
    let id: MastodonID
    public let following: Bool
    public var showing_reblogs: Bool {
        return self.showing_reblogs_ ?? self.following
    }
    private let showing_reblogs_: Bool?
    public let followed_by: Bool
    public let blocking: Bool
    public let muting: Bool
    public var muting_notifications: Bool {
        return self.muting_notifications_ ?? self.muting
    }
    private let muting_notifications_: Bool?
    public let requested: Bool
    public let domain_blocking: Bool = false
    enum CodingKeys: String, CodingKey {
        case id
        case following
        case showing_reblogs_ = "showing_reblogs"
        case followed_by
        case blocking
        case muting
        case muting_notifications_ = "muting_notifications"
        case requested
        case domain_blocking
    }
}
