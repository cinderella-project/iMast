//
//  MastodonVersionStringToInt.swift
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

public func MastodonVersionStringToInt(_ versionStr_: String) -> Int {
    var versionStr = versionStr_
    var versionInt = 500
    if versionStr.trim(0, 1) == "v" {
        versionStr = versionStr.trim(1)
    }
    var versionStrs = versionStr.components(separatedBy: ".")
    if versionStrs.count == 1 {
        versionStrs.append("0")
    }
    if versionStrs.count == 2 {
        versionStrs.append("0")
    }
    if versionStrs.count >= 4 {
        print("versionStrs.count is over 3!")
    }
    print(versionStrs)
    versionInt += (1000 * 100 * 100) * versionStrs[0].parseInt()
    versionInt += (1000 * 100) * versionStrs[1].parseInt()
    versionInt += (1000) * versionStrs[2].parseInt()
    if let rc_match = versionStrs[2].firstMatch(of: /rc([0-9+])/) {
        print("rc", rc_match)
        let rc_ver = Int(rc_match.output.1) ?? 0
        versionInt -= 400
        versionInt += rc_ver
    }
    print(versionInt)
    return versionInt
}
