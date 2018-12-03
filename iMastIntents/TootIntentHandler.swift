//
//  TootIntentHandler.swift
//  iMastIntents
//
//  Created by user on 2018/12/03.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import Foundation

class TootIntentHandler: NSObject, TootIntentHandling {
    func handle(intent: TootIntent, completion: @escaping (TootIntentResponse) -> Void) {
        print(intent)
        var findUserToken: MastodonUserToken?, findFlag = false
        if let accountId = intent.accountId {
            findUserToken = MastodonUserToken.initFromId(id: accountId)
            findFlag = true
        }
        if let accountScreenName = intent.accountScreenName, let accountHostName = intent.accountHostName {
            findUserToken = (try? MastodonUserToken.findUserToken(userName: accountScreenName, instance: accountHostName)) ?? nil
            findFlag = true
        }
        
        if findFlag == false {
            findUserToken = MastodonUserToken.getLatestUsed()
        }
        
        guard let userToken = findUserToken else {
            completion(.init(code: .failureAccountError, userActivity: nil))
            return
        }
        
        userToken.newPost(status: intent.text ?? "").then { (post) in
            completion(.init(code: .success, userActivity: nil))
        }.catch { (error) in
            completion(.init(code: .failure, userActivity: nil))
        }
    }
}
