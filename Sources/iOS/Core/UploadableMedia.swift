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
import iMastiOSCore

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
            // 画像の縮小と再圧縮
            guard let image = UIImage(data: self.data) else {
                return self.data
            }
            var width = image.size.width
            var height = image.size.height
            if image.size.width > image.size.height { // 横長
                if image.size.width > CGFloat(newSize) { // リサイズする必要がある
                    height = height / (width / CGFloat(newSize))
                    width = CGFloat(newSize)
                }
            } else if image.size.width < image.size.height { // 縦長
                if image.size.width > CGFloat(newSize) { // リサイズする必要がある
                    width = width / (height / CGFloat(newSize))
                    height = CGFloat(newSize)
                }
            } else { // 正方形
                width = CGFloat(newSize)
                height = CGFloat(newSize)
            }
            print(width, height)
            UIGraphicsBeginImageContext(CGSize(width: floor(width), height: floor(height)))
            image.draw(in: CGRect(x: 0, y: 0, width: floor(width), height: floor(height)))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            guard let result = newImage else {
                return self.data
            }
            return ((self.format == .png ? result.pngData() : result.jpegData(compressionQuality: 1.0))!)
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
