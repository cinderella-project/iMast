//
//  AddAccountAcquireTokenViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/06/21.
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

import UIKit
import SnapKit
import Ikemen
import iMastiOSCore
import SDWebImage

class AddAccountAcquireTokenViewController: UIViewController {
    let app: MastodonApp
    let code: String
    
    let indicator = UIActivityIndicatorView(style: .large)
    let currentStatusText = UILabel() ※ {
        $0.textColor = .secondaryLabel
        $0.text = L10n.Login.AcquireTokenProgress.fetchingToken
    }
    
    init(app: MastodonApp, code: String) {
        self.app = app
        self.code = code
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(indicator)
        indicator.startAnimating()
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.addSubview(currentStatusText)
        currentStatusText.snp.makeConstraints { make in
            make.centerX.equalTo(indicator.snp.centerX)
            make.top.equalTo(indicator.snp.bottom).offset(8)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var task: Task<Void, Never>?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if task == nil {
            task = Task {
                do {
                    currentStatusText.text = L10n.Login.AcquireTokenProgress.fetchingToken
                    let userToken = try await app.authorizeWithCode(code: code)
                    currentStatusText.text = L10n.Login.AcquireTokenProgress.fetchingProfile
                    _ = try await userToken.getUserInfo(cache: false)
                    try userToken.save()
                    userToken.use()
                    currentStatusText.text = L10n.Login.AcquireTokenProgress.almostDone
                    // 画像を遅延ロードするのはダサいので適当にpreloadしておく、コケても最悪アプリを再起動してもらえばログインできているはず
                    if let avatarUrlString = userToken.avatarUrl, let avatarUrl = URL(string: avatarUrlString) {
                        await withCheckedContinuation { c in
                            SDWebImagePrefetcher.shared.prefetchURLs([avatarUrl], progress: nil) { _, _ in
                                c.resume()
                            }
                        }
                    }
                    let nextVC = AddAccountSuccessViewController()
                    nextVC.userToken = userToken
                    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    navigationController?.pushViewController(nextVC, animated: true)
                } catch {
                    errorReport(error: error) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
}
