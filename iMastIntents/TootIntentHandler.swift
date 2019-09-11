//
//  TootIntentHandler.swift
//  iMastIntents
//
//  Created by rinsuki on 2018/12/03.
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
import Intents
import KeychainAccess

class TootIntentHandler: NSObject, TootIntentHandling {
    func provideAccountOptions(for intent: TootIntent, with completion: @escaping ([Account]?, Error?) -> Void) {
        completion(MastodonUserToken.getAllUserTokens().map { $0.toIntentAccount() }, nil)
    }
    
    func resolveAccount(for intent: TootIntent, with completion: @escaping (AccountResolutionResult) -> Void) {
        if let account = intent.account {
            completion(.success(with: account))
        } else {
            try! Keychain().accessibility(.whenUnlockedThisDeviceOnly).set("testvalue", key: "test")
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
