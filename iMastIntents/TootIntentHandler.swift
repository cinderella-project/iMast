//
//  TootIntentHandler.swift
//  iMastIntents
//
//  Created by user on 2018/12/03.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import Foundation
import Intents

class TootIntentHandler: NSObject, TootIntentHandling {
    func provideAccountOptions(for intent: TootIntent, with completion: @escaping ([Account]?, Error?) -> Void) {
        completion(MastodonUserToken.getAllUserTokens().map { $0.toIntentAccount() }, nil)
    }
    
    func resolveAccount(for intent: TootIntent, with completion: @escaping (AccountResolutionResult) -> Void) {
        if let account = intent.account {
            completion(.success(with: account))
        } else {
            completion(.disambiguation(with:
                MastodonUserToken.getAllUserTokens().map { $0.toIntentAccount() }
            ))
        }
    }
    
    func resolveText(for intent: TootIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.text {
            completion(.success(with: text))
        } else {
            completion(.success(with: ""))
        }
    }
    
    func handle(intent: TootIntent, completion: @escaping (TootIntentResponse) -> Void) {
        print(intent)
        var findUserToken: MastodonUserToken?, findFlag = false
        
        if let account = intent.account {
            findFlag = true
            if let identifier = account.identifier {
                findUserToken = MastodonUserToken.initFromId(id: identifier)
            } else if let acct = account.acct {
                let splitted = acct.split(separator: "@")
                findUserToken = try? MastodonUserToken.findUserToken(
                    userName: String(splitted.first!), instance: String(splitted.last!)
                )
            }
        }
        
        if findFlag == false {
            findUserToken = MastodonUserToken.getLatestUsed()
        }
        
        guard let userToken = findUserToken else {
            print("failed to fetch")
            completion(.init(code: .failureAccountError, userActivity: nil))
            return
        }
        
        userToken.newPost(status: intent.text ?? "").then { (post) in
            completion(.init(code: .success, userActivity: nil))
        }.catch { (error) in
            print(error)
            completion(.init(code: .failure, userActivity: nil))
        }
    }
}
