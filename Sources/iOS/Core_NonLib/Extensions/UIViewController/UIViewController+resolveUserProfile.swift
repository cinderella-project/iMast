//
//  UIViewController+resolveUserProfile.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/11/06.
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
import iMastiOSCore

extension UIViewController {
    func resolveUserProfile(userToken: MastodonUserToken, url: URL) {
        let alert = UIAlertController(title: "ユーザー検索中", message: "\(url.absoluteString)\n\nしばらくお待ちください", preferredStyle: .alert)
        var canceled = false
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            canceled = true
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "強制的にSafariで開く", style: .default, handler: { [weak self] _ in
            canceled = true
            alert.dismiss(animated: true, completion: nil)
            self?.open(url: url)
        }))
        Task { [weak self] in
            do {
                let result = try await userToken.search(q: url.absoluteString, resolve: true)
                await MainActor.run {
                    guard let strongSelf = self else { return }
                    if canceled { return }
                    alert.dismiss(animated: true) {
                        if let account = result.accounts.first {
                            let newVC = UserProfileTopViewController.instantiate(account, environment: userToken)
                            strongSelf.navigationController?.pushViewController(newVC, animated: true)
                        } else {
                            strongSelf.open(url: url)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}
