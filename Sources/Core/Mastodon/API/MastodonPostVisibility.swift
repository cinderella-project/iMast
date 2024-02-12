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
#if canImport(UIKit)
import UIKit
#endif

public enum MastodonPostVisibility: String, CaseIterable, Codable, Sendable, Identifiable {
    case `public`
    case unlisted
    case `private`
    case direct
    
    public var id: String {
        rawValue
    }
    
    public var localizedName: String {
        switch self {
        case .public:
            return CoreL10n.Visibility.Title.public
        case .unlisted:
            return CoreL10n.Visibility.Title.unlisted
        case .private:
            return CoreL10n.Visibility.Title.private
        case .direct:
            return CoreL10n.Visibility.Title.direct
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
    
    public var sfSymbolsName: String {
        switch self {
        case .public:
            return "globe"
        case .unlisted:
            return "lock.open.fill"
        case .private:
            return "lock.fill"
        case .direct:
            return "envelope.fill"
        }
    }
    
    #if canImport(UIKit)
    public var uiImage: UIImage? {
        return UIImage(systemName: sfSymbolsName)
    }
    #endif
}
