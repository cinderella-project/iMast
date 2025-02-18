//
//  NotificationService.swift
//  iMastNotifyService
//
//  Created by rinsuki on 2018/07/24.
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

import UserNotifications
import Hydra
import iMastiOSCore
import Intents
import SDWebImage
import os
import AVKit

enum NotificationServiceError: Error {
    case imageDataIsNil
}

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let logger = Logger(subsystem: "jp.pronama.iMastNotifyService", category: "NotificationService")
    
    static var firstInitialize = false
    
    override init() {
        if !Self.firstInitialize {
            ImageCacheUtils.sdWebImageInitializer(alsoMigrateOldFiles: false) // "old files" (from SDWebImage) isn't exist for notification service extension
            SDImageCache.shared.config.shouldCacheImagesInMemory = false
            URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0)
            Self.firstInitialize = true
        }
        super.init()
    }
    
    func fetchImageFromInternet(url: URL) async throws -> Data {
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
    
    class VideoLoader: NSObject, AVAssetResourceLoaderDelegate {
        let data: Data
        let logger = Logger(subsystem: "jp.pronama.iMastNotifyService", category: "VideoLoader")
        
        init(data: Data) {
            self.data = data
        }
        
        deinit {
            logger.debug("goodbye...")
        }
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            if let contentRequest = loadingRequest.contentInformationRequest {
                contentRequest.contentType = "video/mp4"
                contentRequest.contentLength = Int64(data.count)
                contentRequest.isByteRangeAccessSupported = true
            }
            
            if let dataRequest = loadingRequest.dataRequest {
                let subdata = data.subdata(in: Int(dataRequest.requestedOffset)..<Int(dataRequest.requestedOffset) + Int(dataRequest.requestedLength))
                logger.debug("requesting offset=\(dataRequest.requestedOffset), length=\(dataRequest.requestedLength), result=\(subdata.count)")
                dataRequest.respond(with: subdata)
                loadingRequest.finishLoading()
            }
            
            return true
        }
    }
    
    func fetchVideoFromInternet(url: URL) async throws -> Data {
        var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        req.setValue(UserAgentString, forHTTPHeaderField: "User-Agent")
        let (data, res) = try await URLSession.shared.data(for: req)
        if let res = res as? HTTPURLResponse {
            logger.debug("status=\(res.statusCode), contentType=\(res.value(forHTTPHeaderField: "Content-Type") ?? "(null)")")
        }
        
        logger.debug("got video data, try to get metadata...")
        
        let videoLoader = VideoLoader(data: data)
        let asset = AVURLAsset(url: URL(string: "x-memory://video.mp4")!) // .mp4 is really important
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
    
    func fetchAttachment(from url: URL) async throws -> UNNotificationAttachment {
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
    
    // swiftlint:disable cyclomatic_complexity
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // Modify the notification content here...
        
        self.bestAttemptContent?.threadIdentifier = ""
        if Defaults.groupNotifyAccounts, let receiveUser = request.content.userInfo["receiveUser"] as? [String] {
            self.bestAttemptContent?.threadIdentifier += "account=\(receiveUser.joined(separator: "@")),"
        }
        if let notifyType = request.content.userInfo["notifyType"] as? String {
            switch notifyType {
            case "reblog":
                if Defaults.groupNotifyTypeBoost {
                    self.bestAttemptContent?.threadIdentifier += "type=boost,"
                }
                if Defaults.useCustomBoostSound {
                    self.bestAttemptContent?.sound = .init(named: .init("custom-boost.caf"))
                }
            case "favourite":
                if Defaults.groupNotifyTypeFavourite {
                    self.bestAttemptContent?.threadIdentifier += "type=favourite,"
                }
                if Defaults.useCustomFavouriteSound {
                    self.bestAttemptContent?.sound = .init(named: .init("custom-favourite.caf"))
                }
            case "mention":
                if Defaults.groupNotifyTypeMention {
                    self.bestAttemptContent?.threadIdentifier += "type=mention,"
                }
            case "follow":
                if Defaults.groupNotifyTypeFollow {
                    self.bestAttemptContent?.threadIdentifier += "type=follow,"
                }
            case "unknown":
                if Defaults.groupNotifyTypeUnknown {
                    self.bestAttemptContent?.threadIdentifier += "type=unknown,"
                }
            case "information":
                self.bestAttemptContent?.threadIdentifier += "type=information,"
            default:
                print("whats this is", notifyType)
            }
        }
        print(self.bestAttemptContent?.threadIdentifier)
        
        let task = Task {
            try await withThrowingTaskGroup(of: Void.self) { group in
                if let images = request.content.userInfo["images"] as? [String] {
                    group.addTask {
                        try await withThrowingTaskGroup(of: UNNotificationAttachment.self) { group in
                            for image in images {
                                group.addTask { try await self.fetchAttachment(from: URL(string: image)!) }
                            }
                            self.logger.debug("since all tasks are added, wait for all tasks")
                            for try await attachment in group {
                                if let bestAttemptContent = self.bestAttemptContent {
                                    bestAttemptContent.attachments.append(attachment)
                                    self.logger.debug("attachment added, now \(bestAttemptContent.attachments.count) attachments")
                                } else {
                                    self.logger.warning("bestAttemptContent is nil")
                                }
                            }
                        }
                    }
                }
                if  let receiveUser = request.content.userInfo["receiveUser"] as? [String],
                    let upstreamId = request.content.userInfo["upstreamId"] as? String,
                    let userToken = try MastodonUserToken.findUserToken(userName: receiveUser[0], instance: receiveUser[1])
                {
                    group.addTask {
                        let notify = try await MastodonEndpoint.GetNotification(id: .string(upstreamId)).request(with: userToken)
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(notify)
                        let str = String(data: data, encoding: .utf8)
                        self.bestAttemptContent?.userInfo["upstreamObject"] = str
                        
                        if Defaults.communicationNotificationsEnabled,
                           let account = notify.account, notify.type == "mention",
                           let avatarURL = URL(string: account.avatarUrl)
                        {
                            let displayName: String = account.acct.contains("@") ? "@\(account.acct)" : "@\(account.acct)@\(userToken.app.instance.hostName)"
                            let nameOrScreenName = account.name.isEmpty ? account.screenName : account.name
                            let intent = INSendMessageIntent(
                                recipients: [],
                                outgoingMessageType: .outgoingMessageText,
                                content: nil,
                                speakableGroupName: nil,
                                conversationIdentifier: nil,
                                serviceName: "iMast",
                                sender: INPerson(
                                    personHandle: INPersonHandle(value: account.url, type: .unknown),
                                    nameComponents: nil,
                                    displayName: displayName,
                                    image: INImage(url: avatarURL),
                                    contactIdentifier: nil,
                                    customIdentifier: account.url,
                                    isMe: false,
                                    suggestionType: .socialProfile
                                ),
                                attachments: nil
                            )
                            let old = self.bestAttemptContent!
                            let new = try old.updating(from: intent).mutableCopy() as! UNMutableNotificationContent
                            self.bestAttemptContent = new
                        }
                    }
                }
            }
        }
        
        Task {
            do {
                _ = try await task.value
            } catch {
                logger.error("error: \(error)")
                if Defaults.showPushServiceError {
                    self.bestAttemptContent?.title = "Notification Service Error"
                    self.bestAttemptContent?.subtitle = ""
                    self.bestAttemptContent?.body = "\(error)"
                    self.bestAttemptContent?.attachments = []
                }
                self.bestAttemptContent?.userInfo["error"] = true
            }
            if let bestAttemptContent = self.bestAttemptContent {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        logger.warning("timeout")
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
