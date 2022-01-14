//
//  UIViewController+openURL.swift
//  iMast
//
//  Created by rinsuki on 2019/04/21.
//  
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2019 rinsuki and other contributors.
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
//

import UIKit
import SafariServices
import iMastiOSCore

extension UIViewController {
    func open(url: URL, forceDisableUniversalLink: Bool = false) {
        if Defaults.useUniversalLink, forceDisableUniversalLink == false {
            UIApplication.shared.open(url, options: [
                .universalLinksOnly: true,
            ]) { result in
                if result == false {
                    // Universal Links クッションページスキップ処理
                    // TODO: 設定ファイルとして分離したい
                    // TODO: もしもの時のためにリモートでのキルスイッチを用意したほうがいいかもしれない
                    if Defaults.skipUniversalLinksCussionPage {
                        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                        var cussionPageSkipInfoFounds = false
                        if url.host == "poplinks.idolmaster-official.jp", url.path == "/snspost/launchpage.html" {
                            urlComponents.host = "imas-poplinks.jp"
                            urlComponents.path = "/snspost/launchapp.html"
                            cussionPageSkipInfoFounds = true
                        }
                        if cussionPageSkipInfoFounds {
                            UIApplication.shared.open(urlComponents.url!, options: [
                                .universalLinksOnly: true,
                            ]) { result in
                                if result == false {
                                    self.open(url: url, forceDisableUniversalLink: true)
                                }
                            }
                            return
                        }
                    }
                    self.open(url: url, forceDisableUniversalLink: true)
                }
            }
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}
