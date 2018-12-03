//
//  IntentHandler.swift
//  iMastIntents
//
//  Created by user on 2018/12/02.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any? {
        switch intent {
        case is TootIntent:
            return TootIntentHandler()
        default:
            return nil
        }
    }
}
