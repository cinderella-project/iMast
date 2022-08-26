//
//  AccountEntity.swift
//  
//
//  Created by user on 2022/08/25.
//

import Foundation
import AppIntents
import iMastiOSCore
import KeychainAccess
import os.log
import Darwin

private let characterSetForEscape = CharacterSet(["%", "|"]).inverted

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct AccountEntity: AppEntity {
    static let log = Logger(subsystem: "jp.pronama.iMast.iMastAppIntents", category: "AccountActivity")
    static let persistentIdentifier: String = "AccountEntity"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Account")

    @Property(title: "via")
    var via: String

    @Property(title: "acct")
    var acct: String
    
    var internalID: String
    var isLocalAccount: Bool
    var viaMatched: Bool
    var needsReconfigure: Bool

    struct AccountQuery: EntityQuery {
        func entities(for identifiers: [AccountEntity.ID]) async throws -> [AccountEntity] {
            try Keychain().accessibility(.whenUnlockedThisDeviceOnly).set("testvalue", key: "test")
//            AccountEntity.log.warning("queued by these ids (\(identifiers.count)):\n\(identifiers.joined(separator: "\n"))")
            let userTokens = MastodonUserToken.getAllUserTokens()
            return identifiers.compactMap { id in
                let idComponents = id.split(separator: "|").map { $0.removingPercentEncoding! }
                if idComponents.safe(0) == "v1" {
                    if let id = idComponents.safe(3), let userToken = MastodonUserToken.initFromId(id: id) {
                        return .init(from: userToken, isLocalAccount: true)
                    }
                    if
                        let acct = idComponents.safe(1),
                        let via = idComponents.safe(2),
                        let userToken = userTokens.first(where: { $0.acct == acct && $0.app.name == via })
                    {
                        return .init(from: userToken, originalID: id, viaMatched: true)
                    }
                    if
                        let acct = idComponents.safe(1),
                        let userToken = userTokens.first(where: { $0.acct == acct })
                    {
                        return .init(from: userToken, originalID: id)
                    }
                } else if idComponents.count == 1 {
                    if let userToken = MastodonUserToken.initFromId(id: id) {
                        return .init(from: userToken, originalID: id, isLocalAccount: true)
                    }
                }
                return nil
            }
        }

        func suggestedEntities() async throws -> [AccountEntity] {
            AccountEntity.log.info("queued suggested entities!")
            return MastodonUserToken.getAllUserTokens().map { .init(from: $0, isLocalAccount: true) }
        }
    }
    static var defaultQuery = AccountQuery()

    var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    var displayRepresentation: DisplayRepresentation {
        if isLocalAccount {
            if needsReconfigure {
                return DisplayRepresentation(
                    title: .init("account.needsreconfig", defaultValue: "@\(acct) - 別デバイスで同じショートカットを利用するには再度同じアカウントを選択してください", table: "AppIntents")
                )
            }
            return DisplayRepresentation(
                title: "@\(acct)",
                subtitle: "via \(via)"
            )
        } else if viaMatched {
            return DisplayRepresentation(
                title: .init("account.title.anotherdevice.withvia", defaultValue: "@\(acct) (別デバイスで指定, via \(via))", table: "AppIntents"),
                subtitle: .init("account.subtitle.anotherdevice.withvia", defaultValue: "via \(via) (別デバイスで指定)", table: "AppIntents")
            )
        } else {
            return DisplayRepresentation(
                title: .init("account.title.anotherdevice", defaultValue: "@\(acct) (別デバイスで指定)", table: "AppIntents"),
                subtitle: .init("account.subtitle.anotherdevice", defaultValue: "(別デバイスで指定)", table: "AppIntents")
            )
        }
    }

    init(from userToken: MastodonUserToken, originalID: String? = nil, isLocalAccount: Bool = false, viaMatched: Bool = false) {
//        AccountEntity.log.warning("Init AccountActivity... originalID=\(originalID ?? "(null)"), viaMatched=\(viaMatched), userToken: (id=\(userToken.id ?? "(null)"), acct=\(userToken.acct), app.name=\(userToken.app.name))")
        id = originalID ?? [
            "v1",
            userToken.acct,
            userToken.app.name,
            userToken.id!
        ].map { $0.addingPercentEncoding(withAllowedCharacters: characterSetForEscape)! }.joined(separator: "|")
        needsReconfigure = originalID != nil && isLocalAccount
        self.isLocalAccount = isLocalAccount
        self.viaMatched = isLocalAccount || viaMatched
        internalID = userToken.id!
        acct = userToken.acct
        via = userToken.app.name
    }
    
    enum FindAccountError: Error {
        case failedToFindUserToken(id: String)
    }
    
    func getUserToken(userTokens: [MastodonUserToken] = MastodonUserToken.getAllUserTokens()) throws -> MastodonUserToken {
        let idComponents = id.split(separator: "|").map { $0.removingPercentEncoding! }
        if idComponents.safe(0) == "v1" {
            if let id = idComponents.safe(3), let userToken = MastodonUserToken.initFromId(id: id) {
                return userToken
            }
            if
                let acct = idComponents.safe(1),
                let via = idComponents.safe(2),
                let userToken = userTokens.first(where: { $0.acct == acct && $0.app.name == via })
            {
                return userToken
            }
            if
                let acct = idComponents.safe(1),
                let userToken = userTokens.first(where: { $0.acct == acct })
            {
                return userToken
            }
        } else if idComponents.count == 1 {
            if let userToken = MastodonUserToken.initFromId(id: id) {
                return userToken
            }
        }
        AccountEntity.log.error("failed to find user token...")
        throw FindAccountError.failedToFindUserToken(id: id)
    }
}
