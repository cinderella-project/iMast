//
//  AttachmentCacheManager.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2025/02/19.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

import Foundation
import SDWebImage
import AVFoundation
import os
import iMastiOSCore

enum AttachmentCacheManager {
    static var logger = Logger(subsystem: "jp.pronama.iMastNotifyService", category: "AttachmentCacheManager")
    
    static func initialize() {
        ImageCacheUtils.sdWebImageInitializer(alsoMigrateOldFiles: false) // "old files" (from SDWebImage) isn't exist for notification service extension
        SDImageCache.shared.config.shouldCacheImagesInMemory = false
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0)
        
        DispatchQueue.global(qos: .background).async {
            AttachmentCacheManager.clearOldCaches()
        }
    }
    
    /// Clean old cache files, `image-cache.*`
    static private func clearOldCaches() {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            logger.error("failed to get old cache directory")
            return
        }
        
        guard let enumerator = FileManager.default.enumerator(at: cacheDir, includingPropertiesForKeys: [.isRegularFileKey], options: []) else {
            logger.error("failed to get old cache directory enumerator")
            return
        }

        var count = 0
        var success = 0
        for case let url as URL in enumerator {
            guard url.lastPathComponent.hasPrefix("image-cache.") else {
//                logger.debug("not a regular file: \(url)")
                continue
            }
            do {
                guard try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else {
                    logger.debug("not a regular file: \(url)")
                    continue
                }
                count += 1
                try FileManager.default.removeItem(at: url)
            } catch {
                logger.error("failed to remove old cache file: \(error)")
                continue
            }
            success += 1
        }
        logger.info("found \(count) old cache files, \(success) files removed")
    }
    
    static func fetchImageFromInternet(url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { c in
            SDWebImageDownloader.shared.downloadImage(with: url, context: [
                .storeCacheType: SDImageCacheType.disk.rawValue, // we want to have disk cache (for passing to UNNotificationAttachment)
                .imageForceDecodePolicy: SDImageForceDecodePolicy.never.rawValue, // since we only need the file (for passing to UNNotificationAttachment), we don't need to decode the image
            ], progress: nil) { _image, data, error, success in
                if success, let data {
                    c.resume(returning: data)
                } else {
                    self.logger.error("failed to load image: \(error)")
                    c.resume(throwing: error!)
                }
            }
        }
    }
    
    
    static func fetchVideoFromInternet(url: URL) async throws -> Data {
        var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        req.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
        let (data, res) = try await URLSession.shared.data(for: req)
        if let res = res as? HTTPURLResponse {
            logger.debug("status=\(res.statusCode), contentType=\(res.value(forHTTPHeaderField: "Content-Type") ?? "(null)")")
        }
        
        logger.debug("got video data, try to get metadata...")
        
        let videoLoader = OnMemoryVideoLoader(data: data)
        let asset = AVURLAsset(url: URL(string: "x-memory://localhost/video.mp4")!) // .mp4 is really important
        asset.resourceLoader.setDelegate(videoLoader, queue: .global())
        do {
            _ = try await asset.load(.duration)
        } catch {
            logger.error("failed to get duration: \(error)")
            throw error
        }
        _ = videoLoader // retain the loader

        // it seems right as a video file, so return it
        logger.debug("successfly get duration (= right video data), return video data")
        return data
    }
    
    static func fetchAttachment(from url: URL) async throws -> UNNotificationAttachment {
        var destFileName = "imast.attachment." + url.absoluteString.sha256
        if url.pathExtension.count > 0 {
            destFileName += "." + url.pathExtension
        }
        let destURL = FileManager.default.temporaryDirectory.appending(component: destFileName)
        
        if FileManager.default.fileExists(atPath: destURL.path(percentEncoded: false)) {
            logger.debug("copied file is already exists (for some reason), try to delete")
            try FileManager.default.removeItem(at: destURL)
        }
        
        if let cachedURL = ImageCacheUtils.findCachedFile(for: url) {
            logger.debug("already cached, try to copy and return")
            // since copyItem (should) uses COPYFILE_CLONE (CoW if possible), more sustainable for flash storage
            try FileManager.default.copyItem(at: cachedURL, to: destURL)
            return try .init(identifier: destURL.lastPathComponent, url: destURL)
        }
        
        let data = url.pathExtension.lowercased() == "mp4"
            ? try await fetchVideoFromInternet(url: url)
            : try await fetchImageFromInternet(url: url)
        
        SDImageCache.shared.storeImageData(toDisk: data, forKey: SDWebImageManager.shared.cacheKey(for: url))
        
        if let cachedURL = ImageCacheUtils.findCachedFile(for: url) {
            logger.debug("downloaded and cached, try to copy and return")
            try FileManager.default.copyItem(at: cachedURL, to: destURL)
            return try .init(identifier: destURL.lastPathComponent, url: destURL)
        }
        
        // my opinion was wrong, so write it to disk
        logger.warning("downloaded but not cached, we will write it to disk (\(data.count) bytes)")
        try data.write(to: destURL)
        return try .init(identifier: destURL.lastPathComponent, url: destURL)
    }
    
    static func acquireImageLocalURL(from url: URL) async throws -> URL? {
        if let url = ImageCacheUtils.findCachedFile(for: url) {
            return url
        }
        
        let data = try await fetchImageFromInternet(url: url)
        
        SDImageCache.shared.storeImageData(toDisk: data, forKey: SDWebImageManager.shared.cacheKey(for: url))

        return ImageCacheUtils.findCachedFile(for: url)
    }
}
