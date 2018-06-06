//
//  MastodonAttachments.swift
//  iMast
//
//  Created by user on 2018/01/09.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

class MastodonAttachment: Codable {
    let id: MastodonID
    let type: String
    let url: String
    let previewUrl: String
    let remoteUrl: String?
    let textUrl: String?
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
