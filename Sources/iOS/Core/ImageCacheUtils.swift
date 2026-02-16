//
//  ImageCacheUtils.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2025/02/18.
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

import SDWebImage
import os
import Ikemen

public final class ImageCacheUtils {
    static var initialized = false
    
    public static let notOnConstrainedNetworkModifier = SDWebImageDownloaderRequestModifier { request in
        var request = request
        request.allowsConstrainedNetworkAccess = false
        return request
    }
    
    static func setUserAgent() {
        SDWebImageDownloader.shared.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
    }
    
    public static func sdWebImageInitializer(alsoMigrateOldFiles: Bool) {
        let logger = os.Logger(subsystem: "jp.pronama.imast.core.ImageCacheUtils", category: #function)
        guard !initialized else {
            logger.debug("Already initialized")
            return
        }

        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            logger.error("Failed to get container URL")
            setUserAgent()
            return
        }
        let containerCacheURL = containerURL.appending(path: "Library/Caches/")
        SDImageCache.defaultDiskCacheDirectory = containerCacheURL.appending(path: "SDWebImage_Shared").path(percentEncoded: false)
        setUserAgent()
        initialized = true

        // --- migrate (or delete) old SDWebImage cache dir ---
        
        let appCacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        guard let appCacheURL else {
            logger.warning("Failed to get app cache dir")
            return
        }
        let oldSDWebImageCacheDir = appCacheURL.appending(path: "com.hackemist.SDImageCache/default")

        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: oldSDWebImageCacheDir.path, isDirectory: &isDir) else {
            logger.info("Old SDWebImage cache dir not exists")
            return
        }
        guard isDir.boolValue else {
            logger.info("Old SDWebImage cache dir is not directory")
            return
        }
        guard alsoMigrateOldFiles else {
            logger.info("Since requestor doesn't want to migrate old files, just remove directory instead")
            do {
                try FileManager.default.removeItem(at: oldSDWebImageCacheDir)
            } catch {
                logger.error("Failed to remove old SDWebImage cache dir: \(error)")
            }
            return
        }
        let newSDWebImageCacheDir = SDImageCache.defaultDiskCacheDirectory.appending("/default")
        let currentSDWebImageCacheDir = SDImageCache.shared.diskCachePath
        guard currentSDWebImageCacheDir == newSDWebImageCacheDir else {
            logger.error("SDWebImage cache dir is mismatched")
            #if DEBUG
            logger.info("current: \(currentSDWebImageCacheDir)\nnew: \(newSDWebImageCacheDir)")
            fatalError()
            #else
            return
            #endif
        }
        let newSDWebImageCacheURL = URL(filePath: SDImageCache.defaultDiskCacheDirectory.appending("/default"), directoryHint: .isDirectory)
        let startTime = DispatchTime.now()
        guard let enumerator = FileManager.default.enumerator(
            at: oldSDWebImageCacheDir,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else {
            logger.error("Failed to get enumerator for old SDWebImage cache dir")
            return
        }
        var count = 0
        var failed = 0
        for case let url as URL in enumerator {
            #if DEBUG
            logger.debug("Moving \(url.path, privacy: .private)")
            #endif
            count += 1
            do {
                guard try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else {
                    logger.debug("Skip \(url.path, privacy: .private) because it's not a regular file")
                    failed += 1
                    continue
                }
            } catch {
                logger.error("Failed to get resource values for \(url.path, privacy: .private): \(error)")
                failed += 1
                continue
            }
            let newURL = newSDWebImageCacheURL.appending(path: url.lastPathComponent, directoryHint: .notDirectory)
            do {
                try FileManager.default.moveItem(at: url, to: newURL)
            } catch {
                let nsError = error as NSError
                if nsError.domain == NSCocoaErrorDomain, nsError.code == NSFileWriteFileExistsError {
                    logger.debug("File already exists at: \(newURL, privacy: .private), remove it")
                    try? FileManager.default.removeItem(at: url)
                    continue
                }
                logger.error("Failed to move \(url.path, privacy: .private) to \(newURL.path, privacy: .private): \(error)")
                failed += 1
            }
        }
        let endTime = DispatchTime.now()
        let usedTime = Decimal(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        logger.info("Migrated SDWebImage cache dir in \(usedTime)s, \(count) files target, \(failed) failed (= \(count - failed) success)")
    }
    
    public static func findCachedFile(for url: URL) -> URL? {
        guard let cacheKey = SDWebImageManager.shared.cacheKey(for: url) else {
            return nil
        }
        guard let cachePath = SDImageCache.shared.cachePath(forKey: cacheKey) else {
            return nil
        }
        print(cachePath)
        guard FileManager.default.fileExists(atPath: cachePath) else {
            return nil
        }
        return URL(fileURLWithPath: cachePath)
    }
}
