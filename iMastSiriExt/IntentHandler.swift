//
//  IntentHandler.swift
//  iMastSiriExt
//
//  Created by user on 2018/01/18.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, INSendMessageIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    // MARK: - INSendMessageIntentHandling
    
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INPersonResolutionResult]) -> Void) {
        let notRequired = INPersonResolutionResult.notRequired()
        completion([notRequired])
    }
    
    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    
    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
        completion(response)
    }
    
    // Handle the completed intent (required).
    
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Implement your application logic to send a message here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        MastodonUserToken.getLatestUsed()!.newPost(status: intent.content ?? "test").then { res in
            print(res)
            let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
            completion(response)
        }.catch { err in
            print(err)
            let response = INSendMessageIntentResponse(code: .failure, userActivity: userActivity)
            completion(response)
        }
    }
    
}

