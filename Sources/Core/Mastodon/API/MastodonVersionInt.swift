//
//  MastodonVersionInt.swift
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

public struct MastodonVersionInt {
    let version: Int
    
    public init(_ versionStr_: String) {
        var versionStr = versionStr_
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
        let rcVer: Substring? = versionStrs[2].firstMatch(of: /rc([0-9+])/)?.output.1
        self.init(major: versionStrs[0].parseInt(), minor: versionStrs[1].parseInt(), patch: versionStrs[2].parseInt(), rc: rcVer.map { Int($0) } ?? nil)
    }
    
    @inline(__always) init(major: Int, minor: Int, patch: Int, rc: Int?) {
        version =
            (major * (1000 * 100 * 100)) +
            (minor * (1000 * 100)) +
            (patch * 1000) +
            ((rc ?? 400) - 400)
    }
    
    @inline(__always) public func supportingFeature(_ feature: MastodonVersionFeature) -> Bool {
        return feature.version.version <= version
    }
    
    var readableString: String {
        let major: Int = version / 1000 / 100 / 100
        let minor: Int = version / 1000 / 100 % 100
        let patch: Int = version / 1000 % 100
        let rc: Int = version % 1000
        return "v\(major).\(minor).\(patch)\(rc != 400 ? "rc\(rc)" : "")"
    }
}

public struct MastodonVersionFeature {
    @inline(__always) public static let pinnedPosts = MastodonVersionFeature(major: 1, minor: 6, patch: 0, rc: 1)
    @inline(__always) public static let list = MastodonVersionFeature(major: 2, minor: 1, patch: 0, rc: 1)
    @inline(__always) public static let v2Search = MastodonVersionFeature(major: 2, minor: 4, patch: 1, rc: nil)
    @inline(__always) public static let accessTokenInWebSocketProtocol = MastodonVersionFeature(major: 2, minor: 8, patch: 4, rc: nil)
    @inline(__always) public static let bookmark = MastodonVersionFeature(major: 3, minor: 1, patch: 0, rc: nil)
    @inline(__always) public static let multipleStreamOnWebSocket = MastodonVersionFeature(major: 3, minor: 1, patch: 0, rc: nil)
    @inline(__always) public static let editPost = MastodonVersionFeature(major: 3, minor: 5, patch: 0, rc: 1)
    
    let version: MastodonVersionInt
    
    @inline(__always) init(major: Int, minor: Int, patch: Int, rc: Int?) {
        version = .init(major: major, minor: minor, patch: patch, rc: rc)
    }
    
    @inline(__always) public var readableString: String {
        return version.readableString
    }
}
