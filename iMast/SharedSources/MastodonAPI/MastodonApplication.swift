//
//  MastodonApplication.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

class MastodonApplication: Codable {
    let name: String
    let website: String?
    enum CodingKeys: String, CodingKey {
        case name
        case website
    }
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}
