//
//  String+sha256.swift
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
import CommonCrypto

extension String {
    var sha256: String! {
        if let cstr = self.cString(using: String.Encoding.utf8) {
            var chars = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(
                cstr,
                CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)),
                &chars
            )
            return chars.map { String(format: "%02X", $0) }.reduce("", +)
        }
        return nil
    }
}
