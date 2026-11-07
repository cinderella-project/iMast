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
    @Environment(\.openURL) private var open
    @StateObject private var errorReporter = ErrorReporter()
    let app: MastodonApp
    
    var body: some View {
        Form {
            Section {
                Button(action: { startAuthenticate(isEphemeralSession: false) }, label: {
                    Text(L10n.Login.Authorize.Method.safari)
                })
                    .accessibilityIdentifier("loginWithSafari")
                Button(action: { startAuthenticate(isEphemeralSession: true) }, label: {
                    Text(L10n.Login.Authorize.Method.safariEphemeral)
                })
                    .accessibilityIdentifier("loginWithSafari_Ephemeral")
                #if targetEnvironment(simulator)
                Button(action: { copyAuthorizeURL() }, label: {
                    Text("Simulator: copyAuthorizeURL")
                })
                #endif
            }
            Section(L10n.Login.Authorize.Tos.header) {
                OpenSafariButton(title: Text(L10n.Login.Authorize.Tos.rules), url: URL(string: "https://\(app.instance.hostName)/about/more")!, flag: true)
                OpenSafariButton(title: Text(L10n.Login.Authorize.Tos.termsOfService), url: URL(string: "https://\(app.instance.hostName)/terms")!, flag: false)
            }
            .modifier(OpenLinkInSafariVCModifier(role: .links))
        }
        .attach(errorReporter: errorReporter)
        .navigationTitle(L10n.Login.Authorize.title)
    }
    
    func startAuthenticate(isEphemeralSession: Bool) {
        let session = ASWebAuthenticationSession(url: app.getAuthorizeUrl(), callbackURLScheme: "imast") { url, error in
            if let url {
                open(url)
            } else if let error {
                if case ASWebAuthenticationSessionError.canceledLogin = error {
                    return
                }
                errorReporter.report(error)
            }
        }
        session.presentationContextProvider = errorReporter.view?.window?.windowScene
        session.prefersEphemeralWebBrowserSession = isEphemeralSession
        session.start()
    }
    
    #if targetEnvironment(simulator)
    func copyAuthorizeURL() {
        let url = app.getAuthorizeUrl()
        UIPasteboard.general.url = url
        print(url)
    }
    #endif
}

