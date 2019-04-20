//
//  UIViewController+openURL.swift
//  iMast
//
//  Created by user on 2019/04/21.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
    func open(url: URL, forceDisableUniversalLink: Bool = false) {
        if Defaults[.useUniversalLink], forceDisableUniversalLink == false {
            UIApplication.shared.open(url, options: [
                .universalLinksOnly: true,
            ]) { result in
                if result == false {
                    self.open(url: url, forceDisableUniversalLink: true)
                }
            }
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}
