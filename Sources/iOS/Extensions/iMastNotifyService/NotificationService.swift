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

enum NotificationServiceError: Error {
    case imageDataIsNil
}

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    func fetchFromInternet(url: URL) -> Promise<URL> {
        return Promise<URL>(in: .background) { resolve, reject, _ in
            let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let urlHashed = "image-cache." + url.absoluteString.sha256
            var pathExt = url.pathExtension
            if pathExt != "" {
                pathExt = "." + pathExt
            }
            let copyDest = cacheDirectory.appendingPathComponent(urlHashed + pathExt)
            let tempDest = cacheDirectory.appendingPathComponent(urlHashed + ".temp" + pathExt)
            
            if FileManager.default.fileExists(atPath: copyDest.path) { // もしもうキャッシュがあるんだったら
                if !FileManager.default.fileExists(atPath: tempDest.path) {
                    try FileManager.default.copyItem(at: copyDest, to: tempDest)
                }
                resolve(tempDest) // それを返す
                return
            }
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0)
            let session = URLSession(configuration: sessionConfig)
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    return reject(error)
                }
                do {
                    guard let data = data else {
                        return reject(NotificationServiceError.imageDataIsNil)
                    }
                    try data.write(to: copyDest)
                    if !FileManager.default.fileExists(atPath: tempDest.path) {
                        try data.write(to: tempDest)
                    }
                    resolve(tempDest)
                } catch {
                    reject(error)
                }
            }
            task.resume()
        }
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
        
        var promise: [Promise<Void>] = []
        promise.append(asyncPromise {
            // get attachment images
            if let images = request.content.userInfo["images"] as? [String] {
                let imageUrls = try await all(images.map { self.fetchFromInternet(url: URL(string: $0)!) }).wait()
                for imageUrl in imageUrls {
                    self.bestAttemptContent?.attachments.append(try UNNotificationAttachment(identifier: imageUrl.path, url: imageUrl, options: nil))
                }
            }
        })
        promise.append(asyncPromise {
            if  let receiveUser = request.content.userInfo["receiveUser"] as? [String],
                let upstreamId = request.content.userInfo["upstreamId"] as? String {
                guard let userToken = try MastodonUserToken.findUserToken(userName: receiveUser[0], instance: receiveUser[1]) else {
                    return
                }

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
        })
        
        let promiseAll = all(promise)
        
        promiseAll.catch { error in
            if Defaults.showPushServiceError {
                self.bestAttemptContent?.title = "Notification Service Error"
                self.bestAttemptContent?.subtitle = ""
                self.bestAttemptContent?.body = "\(error)"
                self.bestAttemptContent?.attachments = []
            }
            self.bestAttemptContent?.userInfo["error"] = true
        }.always {
            if let bestAttemptContent = self.bestAttemptContent {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        print("timeout")
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
