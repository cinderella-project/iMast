//
//  UserAgent.swift
//  iMast
//
//  Created by rinsuki on 2019/06/20.
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

#if canImport(AppKit)
    import AppKit
    private let macVersion = ProcessInfo.processInfo.operatingSystemVersion
    public let UserAgentPlatformVersionString = "\(macVersion.majorVersion).\(macVersion.minorVersion)\(macVersion.patchVersion > 0 ? ".\(macVersion.patchVersion)" : "")"
#else
    import UIKit
    public let UserAgentPlatformVersionString = UIDevice.current.systemVersion
#endif

#if os(macOS)
    public let UserAgentPlatformString = "macOS"
#elseif os(iOS)
    public let UserAgentPlatformString = "iOS"
#elseif os(visionOS)
    public let UserAgentPlatformString = "visionOS"
#endif

public let UserAgentString = "iMast/\((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)) (\(UserAgentPlatformString)/\(UserAgentPlatformVersionString))"
