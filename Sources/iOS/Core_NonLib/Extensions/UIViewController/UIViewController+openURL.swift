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
#if os(iOS)
import SafariServices
#endif
import iMastiOSCore

extension UIViewController {
    func open(url: URL, forceDisableUniversalLink: Bool = false) {
        if Defaults.useUniversalLink, forceDisableUniversalLink == false {
            UIApplication.shared.open(url, options: [
                .universalLinksOnly: true,
            ]) { result in
                if result == false {
                    self.open(url: url, forceDisableUniversalLink: true)
                }
            }
            return
        }
        #if os(visionOS)
        self.view.window?.windowScene?.open(url, options: nil)
        #else
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
        #endif
    }
}
