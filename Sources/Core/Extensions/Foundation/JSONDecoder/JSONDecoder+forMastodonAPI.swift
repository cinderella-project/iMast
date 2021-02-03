//
//  JSONDecoder+forMastodonAPI.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/10.
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
import Ikemen

private let jsISODateDecoder = JSONDecoder.DateDecodingStrategy.custom {
    let container = try $0.singleValueContainer()
    let str = try container.decode(String.self)
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZZZZ"
    if let d = f.date(from: str) {
        return d
    }
    // https://github.com/imas/mastodon/pull/200 への対処
    f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZZ"
    if let d = f.date(from: str) {
        return d
    }
    throw APIError.dateParseFailed(dateString: str)
}

extension JSONDecoder {
    public static let forMastodonAPI = JSONDecoder() ※ {
        $0.dateDecodingStrategy = jsISODateDecoder
    }
}
