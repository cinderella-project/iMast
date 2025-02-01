//
//  EmojiToAdaptiveImageGlyph.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2024/11/08.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2024 rinsuki and other contributors.
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

// Heavily thanks to Zenmoji by noppe https://github.com/noppefoxwolf
// Licensed under MIT license, https://github.com/noppefoxwolf/Zenmoji/tree/cd86805ab3fc715a43cfaa7a7a37134d3a1951b2

// Zenmoji resizing image to multiple variants (maybe Apple Genmoji also does? didn't confirmed currently since I don't have a device installed iOS 18.2)
// but iOS 18.0 accepts even with one variant.
// also, in Mastodon, emoji (file) size is pretty limited
// so **i guess** we don't need to create small size

import UIKit
#if RESIZE_IMAGE_FOR_ADAPTIVE_GLYPH
import Accelerate
#endif


#if RESIZE_IMAGE_FOR_ADAPTIVE_GLYPH
private let imageSizes = [160, 40, 64, 96, 320]
#endif

@available(iOSApplicationExtension 18.0, *)
func emojiToAdaptiveImageGlyph(image: CGImage) throws -> NSAdaptiveImageGlyph {
    let destData = NSMutableData()
#if RESIZE_IMAGE_FOR_ADAPTIVE_GLYPH
    let imageVariantsCount = imageSizes.count
#else
    let imageVariantsCount = 1
#endif
    print("NSAdaptiveImageGlyph.contentType.identifier", NSAdaptiveImageGlyph.contentType.identifier)
    let dest = CGImageDestinationCreateWithData(
        destData, NSAdaptiveImageGlyph.contentType.identifier as CFString,
        imageVariantsCount,
        nil
    )!
    let uuid = UUID().uuidString

#if RESIZE_IMAGE_FOR_ADAPTIVE_GLYPH
    // preparing resize for vImage
    let format = vImage_CGImageFormat(
        bitsPerComponent: 8, bitsPerPixel: 32,
        colorSpace: nil,
        bitmapInfo: .init(rawValue: CGImageAlphaInfo.first.rawValue),
        version: 0,
        decode: nil, renderingIntent: .defaultIntent
    )
    var sourceBuffer = try vImage_Buffer(cgImage: image, format: format)
    defer {
        sourceBuffer.data.deallocate()
    }
    
    for size in imageSizes {
        var destBuffer = try vImage_Buffer(width: size, height: size, bitsPerPixel: 32)
        defer {
            destBuffer.data.deallocate()
        }
        
        // TODO: check errors
        vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, .init(kvImageHighQualityResampling))
        
        let resizedImage = try destBuffer.createCGImage(format: format)
        
        let metadata = CGImageMetadataCreateMutable()
        CGImageMetadataSetValueWithPath(metadata, nil, "tiff:TileLength" as CFString, size as CFNumber)
        CGImageMetadataSetValueWithPath(metadata, nil, "tiff:TileWidth" as CFString, size as CFNumber)
        CGImageMetadataSetValueWithPath(metadata, nil, "tiff:DocumentName" as CFString, uuid as CFString)
        CGImageDestinationAddImageAndMetadata(dest, resizedImage, metadata, nil)
        print("added \(size) \(resizedImage)")
    }
#else
    let metadata = CGImageMetadataCreateMutable()
    CGImageMetadataSetValueWithPath(metadata, nil, "tiff:TileLength" as CFString, image.height as CFNumber)
    CGImageMetadataSetValueWithPath(metadata, nil, "tiff:TileWidth" as CFString, image.width as CFNumber)
    CGImageMetadataSetValueWithPath(metadata, nil, "tiff:DocumentName" as CFString, uuid as CFString)
    CGImageDestinationAddImageAndMetadata(dest, image, metadata, nil)
#endif
    CGImageDestinationFinalize(dest)
    
    let destURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appending(path: "emoji.bin")
    try (destData as Data).write(to: destURL)
    print(destURL.absoluteString)

    return .init(imageContent: destData as Data)
}
