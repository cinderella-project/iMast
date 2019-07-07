//
//  MastodonAttachments.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

struct MastodonAttachment: Codable {
    let id: MastodonID
    let type: MediaType
    let url: String
    let previewUrl: String
    let remoteUrl: String?
    let textUrl: String?
    
    enum MediaType: String, Codable {
        case video
        case gifv
        case image
        case audio
        case unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case url
        case previewUrl = "preview_url"
        case remoteUrl = "remote_url"
        case textUrl = "text_url"
    }
    
    @available(*, deprecated, message: "Do not use.")
    init() {
        fatalError("Swift 4.1 work around")
    }
}
