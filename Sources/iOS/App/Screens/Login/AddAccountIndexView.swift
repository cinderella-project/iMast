//
//  AddAccountIndexView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/06/17.
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

class AddAccountIndexViewController: UIHostingController<_AddAccountIndexView> {
    init() {
        super.init(rootView: .init(errorReport: nil))
        rootView = .init(errorReport: { [weak self] in
            self?.errorReport(error: $0)
        })
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AddAccountIndexViewModel: ObservableObject {
    let latestToken: MastodonUserToken? = MastodonUserToken.getLatestUsed()
    weak var view: UIView?
    
    func cancel() {
        guard let latestToken else {
            return
        }
        view?.window?.changeRootVC(Defaults.newFirstScreen ? TopViewController() : MainTabBarController.instantiate((), environment: latestToken), reversed: true)
    }
    
    struct WindowAcquireView: UIViewRepresentable {
        typealias UIViewType = UIView
        let viewModel: AddAccountIndexViewModel
        
        func makeUIView(context: Context) -> UIViewType {
            let view = UIView()
            viewModel.view = view
            return view
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
        }
    }
}

struct _AddAccountIndexView: View {
    @StateObject var viewModel = AddAccountIndexViewModel()
    @State var instance: String = ""
    @State var loginState: LoginState?
    @State var loginTask: Task<Void, Never>?
    @State var path: NavigationPath = .init()
    let errorReport: ((Error) -> Void)?
    
    enum LoginState {
        case fetchingServerInfo
        case registeringApplication
        case pleaseAuthorize
        
        var description: String {
            switch self {
            case .fetchingServerInfo:
                return "\(L10n.Login.ProgressDialog.fetchingServerInfo) (1/4)"
            case .registeringApplication:
                return "\(L10n.Login.ProgressDialog.registeringApplication) (2/4)"
            case .pleaseAuthorize:
                return "\(L10n.Login.ProgressDialog.pleaseAuthorize) (3/4)"
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section(L10n.Login.pleaseInputMastodonInstance) {
                    TextField("インスタンス", text: $instance, prompt: Text("mastodon.example"))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .disabled(loginState != nil)
                }
                Section {
                    Button {
                        loginTask = Task {
                            await startLogin()
                        }
                    } label: {
                        Text(L10n.Login.loginButton)
                    }
                    .disabled(instance.count == 0 || loginState != nil)
                    .accessibility(identifier: "loginButton")
                    #if DEBUG
                    Button {
                        if let app = try? MastodonApp.debugGetOne() {
                            path.append(app)
                        }
                    } label: {
                        Text("Debug: Use Latest App")
                    }
                    #endif
                } footer: {
                    if let loginState = loginState {
                        Text(loginState.description)
                    }
                }
            }
            .navigationDestination(for: MastodonApp.self, destination: { app in
                AddAccountSelectLoginMethodView(app: app)
            })
            .navigationTitle(L10n.Login.title)
            .toolbar {
                if viewModel.latestToken != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewModel.cancel()
                        }, label: {
                            Text(L10n.Localizable.cancel)
                        })
                    }
                }
            }
            .background {
                AddAccountIndexViewModel.WindowAcquireView(viewModel: viewModel)
            }
            .onAppear {
                loginTask?.cancel()
                loginTask = nil
                loginState = nil
            }
        }
    }
    
    @MainActor func setLoginState(_ newState: LoginState?) {
        loginState = newState
    }
    
    func startLogin() async {
        do {
            await setLoginState(.fetchingServerInfo)
            let instance = MastodonInstance(hostName: instance)
            _ = try await instance.getInfo()
            await setLoginState(.registeringApplication)
            let app = try await instance.createApp(name: Defaults.newAccountVia)
            try app.save()
            await setLoginState(.pleaseAuthorize)
            await MainActor.run {
                path.append(app)
            }
        } catch {
            if Task.isCancelled {
                return
            }
            loginState = nil
            await MainActor.run {
                errorReport?(error)
            }
        }
    }
}

struct _AddAccountIndexView_Previews: PreviewProvider {
    static var previews: some View {
        _AddAccountIndexView(errorReport: nil)
    }
}
