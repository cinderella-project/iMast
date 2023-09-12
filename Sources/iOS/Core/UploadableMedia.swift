//
//  UploadableMedia.swift
//  iMast
//
//  Created by rinsuki on 2018/11/08.
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
import UIKit
import Ikemen

public struct UploadableMedia {
    public init(format: UploadableMedia.MeidaFormat, data: Data, url: URL?, thumbnailImage: UIImage) {
        self.format = format
        self.data = data
        self.url = url
        self.thumbnailImage = thumbnailImage
    }
    
    public enum MeidaFormat {
        case jpeg
        case png
        case mp4
    }
    public let format: UploadableMedia.MeidaFormat
    public let data: Data
    public let url: URL?
    public let thumbnailImage: UIImage
    
    public func toUploadableData() -> Data {
        let newSize = Defaults.autoResizeSize
        if newSize != 0, self.format == .jpeg || self.format == .png {
            let newSizeFloat = CGFloat(newSize)
            // 画像の縮小と再圧縮
            guard let image = UIImage(data: self.data) else {
                return self.data
            }
            var width = image.size.width
            var height = image.size.height
            if width > height { // 横長
                if image.size.width > newSizeFloat { // リサイズする必要がある
                    height = height / (width / newSizeFloat)
                    width = CGFloat(newSize)
                }
            } else if width < height { // 縦長
                if image.size.width > newSizeFloat { // リサイズする必要がある
                    width = width / (height / newSizeFloat)
                    height = CGFloat(newSize)
                }
            } else { // 正方形
                if width > newSizeFloat {
                    width = CGFloat(newSize)
                    height = CGFloat(newSize)
                }
            }
            print(width, height)
            let size = CGSize(width: floor(width), height: floor(height))
            let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat() ※ {
                $0.scale = 1.0
                $0.opaque = format == .png
                $0.preferredRange = .standard
            })
            let result = renderer.image { context in
                image.draw(in: context.format.bounds)
            }
            return (self.format == .png ? result.pngData() : result.jpegData(compressionQuality: 1.0))!
        }
        return self.data
    }
    
    public func getMimeType() -> String {
        switch self.format {
        case .jpeg:
            return "image/jpeg"
        case .png:
            return "image/png"
        case .mp4:
            return "video/mp4"
        }
    }
}
