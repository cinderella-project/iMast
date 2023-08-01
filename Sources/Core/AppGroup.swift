//
//  AppGroup.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/16.
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
import KeychainAccess

#if os(macOS)
public let appGroupIdentifier = "4XKKKM86RN.jp.pronama.imast"
#else
public let appGroupIdentifier = "group.jp.pronama.imast"
#endif

// Old version of iMast only reading from non-App Group keychain, so we need to set both keychain(s).
public let Keychain_ForAccessToken_Legacy = Keychain(service: "jp.pronama.imast.access-token").accessibility(.afterFirstUnlock)
public let Keychain_ForAccessToken_New = Keychain(service: "jp.pronama.imast.access-token", accessGroup: appGroupIdentifier).accessibility(.afterFirstUnlock)

#if !targetEnvironment(macCatalyst)
public let Keychain_ForPushBackend = Keychain(service: "net.rinsuki.imast-backend.push").accessibility(.alwaysThisDeviceOnly)
#else
public let Keychain_ForPushBackend = Keychain(service: "net.rinsuki.imast-backend.push").accessibility(.afterFirstUnlockThisDeviceOnly)
#endif
