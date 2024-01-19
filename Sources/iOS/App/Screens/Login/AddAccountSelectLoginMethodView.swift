//
//  AddAccountSelectLoginMethodView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/09/24.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

import SwiftUI
import iMastiOSCore
import AuthenticationServices

struct AddAccountSelectLoginMethodView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @Environment(\.openURL) private var open
    let app: MastodonApp
    
    var body: some View {
        Form {
            Section {
                Button(action: { startAuthenticate(isEphemeralSession: false) }, label: {
                    Text(L10n.Login.Authorize.Method.safari)
                })
                Button(action: { startAuthenticate(isEphemeralSession: true) }, label: {
                    Text(L10n.Login.Authorize.Method.safariEphemeral)
                })
            }
            Section(L10n.Login.Authorize.Tos.header) {
                OpenSafariButton(title: Text(L10n.Login.Authorize.Tos.rules), url: URL(string: "https://\(app.instance.hostName)/about/more")!, flag: true)
                OpenSafariButton(title: Text(L10n.Login.Authorize.Tos.termsOfService), url: URL(string: "https://\(app.instance.hostName)/terms")!, flag: false)
            }
            .modifier(OpenLinkInSafariVCModifier())
        }
        .navigationTitle(L10n.Login.Authorize.title)
    }
    
    func startAuthenticate(isEphemeralSession: Bool) {
        Task {
            let url = try await webAuthenticationSession.authenticate(
                using: app.getAuthorizeUrl(), callbackURLScheme: "imast", preferredBrowserSession: isEphemeralSession ? .ephemeral : .shared
            )
            open(url)
        }
    }
}

