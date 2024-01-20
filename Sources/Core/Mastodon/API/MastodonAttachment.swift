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

public struct MastodonAttachment: Codable, Sendable, MastodonEndpointResponse {
    public let id: MastodonID
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

public protocol MultipartEndpointProtocol {
    func multipartBody() throws -> [(name: String, file: (name: String, contentType: String)?, data: Data)]
}

extension MastodonEndpointProtocol where Self: MultipartEndpointProtocol {
    public func body() throws -> (Data, contentType: String)? {
        var estimatedLength = 0
        let contents = try multipartBody()
        
        let boundary: String = {
            while true {
                let uuid = UUID().uuidString
                let uuidData = uuid.data(using: .ascii)!
                var notCapable = false
                for content in contents {
                    if content.data.range(of: uuidData) != nil {
                        notCapable = true
                    }
                }
                if !notCapable {
                    return uuid
                }
            }
        }()
        let boundaryInBody = "--\(boundary)\r\n".data(using: .ascii)!

        let headerCount = boundaryInBody.count + 45

        for content in contents {
            estimatedLength += content.name.count
            estimatedLength += content.data.count
            if let file = content.file {
                estimatedLength += file.name.count + file.contentType.count + 29
            }
        }
        estimatedLength += headerCount * contents.count
        estimatedLength += boundaryInBody.count + 2

        var buffer = Data(capacity: estimatedLength)
        for content in contents {
            buffer.append(boundaryInBody)
            buffer.append("Content-Disposition: form-data; name=\"\(content.name)\"".data(using: .ascii)!)
            if let file = content.file {
                buffer.append("; filename=\"\(file.name)\"\r\nContent-Type: \(file.contentType)".data(using: .ascii)!)
            }
            buffer.append("\r\n\r\n".data(using: .ascii)!)
            buffer.append(content.data)
            buffer.append("\r\n".data(using: .ascii)!)
        }
        buffer.append("--\(boundary)--\r\n".data(using: .ascii)!)
        
        #if DEBUG
        print("estimatedLength diff", estimatedLength, buffer.count, estimatedLength - buffer.count)
        #endif
        
        return (buffer, "multipart/form-data; boundary=\(boundary)")
    }
}

extension MastodonEndpoint {
    public struct UploadMediaV1: MastodonEndpointProtocol, MultipartEndpointProtocol {
        public typealias Response = MastodonAttachment
        
        public var endpoint: String { "/api/v1/media" }
        public var method: String { "POST" }
        
        public let file: Data
        public let mimeType: String
        public let fileName: String = "imast_upload_file"
        
        public init(file: Data, mimeType: String) {
            self.file = file
            self.mimeType = mimeType
        }
        
        public func multipartBody() throws -> [(name: String, file: (name: String, contentType: String)?, data: Data)] {
            return [
                (name: "file", file: (name: fileName, contentType: mimeType), data: file),
            ]
        }
    }
}
