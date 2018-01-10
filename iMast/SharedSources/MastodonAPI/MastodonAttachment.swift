//
//  MastodonAttachments.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

class MastodonAttachment: Codable {
    let id: String
    let type: String
    let url: String
    let previewUrl: String
    let originalUrl: String
    let textUrl: String
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case url
        case previewUrl = "preview_url"
        case originalUrl = "original_url"
        case textUrl = "text_url"
    }
}