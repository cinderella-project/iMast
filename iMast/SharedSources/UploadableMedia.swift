//
//  UploadableMedia.swift
//  iMast
//
//  Created by user on 2018/11/08.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import Foundation
import UIKit

struct UploadableMedia {
    enum MeidaFormat {
        case jpeg
        case png
        case mp4
    }
    let format: UploadableMedia.MeidaFormat
    let data: Data
    let url: URL?
    let thumbnailImage: UIImage
    
    func toUploadableData() -> Data {
        let newSize = Defaults[.autoResizeSize]
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
    
    func getMimeType() -> String {
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
