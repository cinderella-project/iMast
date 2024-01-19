//
//  UIViewController+showFromTimeline.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/08/30.
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

#if !os(visionOS)
fileprivate class SheetHeightResolver {
    static let shared = SheetHeightResolver()
    
    var currentHeight: CGFloat = 0
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(valueUpdated(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(valueUpdated(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func valueUpdated(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        currentHeight = keyboardFrame.height
//        print("update height", currentHeight)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        currentHeight = 0
//        print("keyboard hide...")
    }
    
    func resolver(_ context: UISheetPresentationControllerDetentResolutionContext) -> CGFloat? {
//        print("recalc...")
        return max(200, context.maximumDetentValue - 180 - currentHeight)
    }
}
#endif

extension UIViewController {
    func showFromTimeline(_ viewController: UIViewController) {
        if Defaults.openAsHalfModalFromTimeline, traitCollection.verticalSizeClass != .compact {
            let navigationController = UINavigationController()
            if let sheet = navigationController.sheetPresentationController {
                #if !os(visionOS)
                sheet.detents = [.custom(resolver: SheetHeightResolver.shared.resolver)]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                #endif
                sheet.prefersEdgeAttachedInCompactHeight = false
                navigationController.presentationController?.overrideTraitCollection = .init(verticalSizeClass: .compact)
                navigationController.setViewControllers([viewController], animated: false)

                let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: viewController, action: #selector(close))
                if viewController.navigationItem.leftBarButtonItems != nil {
                    viewController.navigationItem.leftBarButtonItems?.insert(closeItem, at: 0)
                } else if let leftBarButtonItem = viewController.navigationItem.leftBarButtonItem {
                    viewController.navigationItem.leftBarButtonItem = nil
                    viewController.navigationItem.leftBarButtonItems = [closeItem, leftBarButtonItem]
                } else {
                    viewController.navigationItem.leftBarButtonItems = [closeItem]
                }
                present(navigationController, animated: true)
                return
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}
