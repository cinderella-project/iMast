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
            AttachmentCacheManager.initialize()
            Self.firstInitialize = true
        }
        super.init()
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
                                group.addTask { try await AttachmentCacheManager.fetchAttachment(from: URL(string: image)!) }
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
