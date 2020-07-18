//
//  MastodonPostVisibility.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/05/26.
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

public enum MastodonPostVisibility: String, CaseIterable, Codable {
    case `public`
    case unlisted
    case `private`
    case direct
    
    public var localizedName: String {
        switch self {
        case .public:
            return "公開"
        case .unlisted:
            return "未収載"
        case .private:
            return "フォロワー限定"
        case .direct:
            return "ダイレクト"
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .public:
            return "LTLやフォロワーのHTL等に流れます"
        case .unlisted:
            return "LTLやハッシュタグ検索には出ません"
        case .private:
            return "あなたのフォロワーと、メンションを飛ばした対象の人のみ見れます"
        case .direct:
            return "メンションを飛ばした対象の人にのみ見れます"
        }
    }
    
    public var emoji: String? {
        switch self {
        case .public:
            return nil
        case .unlisted:
            return "🔓"
        case .private:
            return "🔒"
        case .direct:
            return "✉️"
        }
    }
}
