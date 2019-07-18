//
//  MastodonAttachments.swift
//  iMast
//
//  Created by user on 2018/01/09.
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

class MastodonAttachment: Codable {
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
