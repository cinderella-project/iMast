//
//  MastodonUserToken+toIntentAccount.swift
//  
//
//  Created by user on 2019/06/21.
//

import Foundation

extension MastodonUserToken {
    func toIntentAccount() -> Account {
        let account = Account(identifier: self.id, display: self.acct + " (via " + self.app.name + ")")
        account.acct = self.acct
        account.via = self.app.name
        return account
    }
}
