//
//  TootIntent.swift
//  
//
//  Created by user on 2022/08/25.
//

import Foundation
import AppIntents
import iMastiOSCore
import os.log

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct TootIntent: AppIntent, CustomIntentMigratedAppIntent {
    static let log = Logger(subsystem: "jp.pronama.iMast.iMastAppIntents", category: "AccountActivity")
    
    static let intentClassName = "TootIntent"
    static let persistentIdentifier: String = "TootIntent"

    static var title: LocalizedStringResource = "Create Post"
    static var description = IntentDescription("")

    @Parameter(title: .init("toot.parameters.account", defaultValue: "Account", table: "AppIntents.strings"))
    var account: AccountEntity

    @Parameter(title: .init(.init("toot.parameters.text"), table: "AppIntents"))
    var text: String
    
    @Parameter(title: .init("toot.parameters.visibility", defaultValue: "Visibility", table: "AppIntents"))
    var visibility: TootVisibility?

    static var parameterSummary: some ParameterSummary {
        Summary("Post \(\.$text) in \(\.$account)", table: "AppIntents.strings") {
            \.$visibility
        }
    }

    func perform() async throws -> some IntentResult {
//        TootIntent.log.info("Perform: Get UserToken...")
        let userToken = try account.getUserToken()
//        TootIntent.log.info("Perform: Sending...")
        var request = MastodonEndpoint.CreatePost(status: text)
        if let visibility {
            request.visibility = .init(rawValue: visibility.rawValue)
        }

        let post = try await request.request(with: userToken)
//        TootIntent.log.info("Perform: Done...")
        return .result()
    }
}

enum TootVisibility: String, AppEnum {
    static let persistentIdentifier: String = "TootVisibility"
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Visibility"
    
    static var caseDisplayRepresentations: [TootVisibility: DisplayRepresentation] = [
        .public: .init(title: .init("visibility.public", defaultValue: "Public", table: "AppIntents"), image: .init(systemName: "globe")),
        .unlisted: .init(title: .init("visibility.unlisted", defaultValue: "Unlisted", table: "AppIntents"), image: .init(systemName: "lock.open.fill")),
        .private: .init(title: .init("visibility.private", defaultValue: "Private", table: "AppIntents"), image: .init(systemName: "lock.fill")),
        .direct: .init(title: .init("visibility.direct", defaultValue: "Direct", table: "AppIntents"), image: .init(systemName: "envelope.fill")),
    ]
    
//        static var typeDisplayName: LocalizedStringResource
    
    case `public`
    case unlisted
    case `private`
    case direct
}
