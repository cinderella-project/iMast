//
//  UserAgent.swift
//  iMast
//
//  Created by user on 2019/06/20.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import UIKit

let UserAgentString = "iMast/\((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)) (iOS/\((UIDevice.current.systemVersion)))"

