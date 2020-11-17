//
//  MastodonAttachments.swift
//  iMast
//
//  Created by rinsuki on 2018/01/09.
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

public struct MastodonAttachment: Codable {
    let id: MastodonID
    public let type: MediaType
    public let url: String
    public let previewUrl: String?
    let remoteUrl: String?
    public let textUrl: String?
    
    public enum MediaType: String, Codable {
        case video
        case gifv
        case image
        case audio
        case unknown
        
        public var shouldUseMediaPlayer: Bool {
            switch self {
            case .video, .gifv, .audio:
                return true
            default:
                return false
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case url
        case previewUrl = "preview_url"
        case remoteUrl = "remote_url"
        case textUrl = "text_url"
    }

}
