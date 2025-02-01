//
//  CodableViewDescriptor+localized.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/07/29.
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

import Foundation
import UIKit
import iMastiOSCore
import Mew

extension CodableViewDescriptor {
    var localizedLongTitle: String {
        switch self {
        case .home:
            return L10n.Localizable.homeTimeline
        case .notifications:
            return L10n.Localizable.notifications
        case .local:
            return L10n.Localizable.localTimeline
        case .federated:
            return L10n.Localizable.federatedTimeline
        case .homeAndLocal:
            return "Home + Local"
        case .list(id: _, title: let title):
            return title
        }
    }
    
    var localizedShortTitle: String {
        switch self {
        case .home:
            return L10n.Localizable.HomeTimeline.short
        case .notifications:
            return L10n.Localizable.notifications
        case .local:
            return L10n.Localizable.LocalTimeline.short
        case .federated:
            return L10n.Localizable.FederatedTimeline.short
        case .homeAndLocal:
            return "Home + Local"
        case .list(id: _, title: let title):
            return title
        }
    }
    
    var systemImageName: String {
        // TODO: Switch to filled images in next major release
        switch self {
        case .home:
            return "house"
        case .notifications:
            return "bell"
        case .local:
            return "person.2"
        case .federated:
            return "server.rack"
        case .homeAndLocal:
            return "display.2"
        case .list(id: _, title: _):
            return "list.bullet"
        }
    }
    
    var systemImage: UIImage? {
        return UIImage(systemName: systemImageName)
    }
    
    private func _internal_createViewController(with userToken: MastodonUserToken) -> UIViewController {
        switch self {
        case .home:
            return HomeTimelineViewController.instantiate(.plain, environment: userToken)
        case .notifications:
            return NotificationTableWrapperViewController.instantiate(environment: userToken)
        case .local:
            return LocalTimelineViewController.instantiate(.plain, environment: userToken)
        case .federated:
            return FederatedTimelineViewController.instantiate(.plain, environment: userToken)
        case .homeAndLocal:
            return HomeAndLocalTimelineViewController.instantiate(.plain, environment: userToken)
        case .list(id: let id, title: let title):
            let vc = ListTimelineViewController.instantiate(.plain, environment: userToken)
            vc.list = .init(id: .string(id), title: title)
            return vc
        }
    }
    
    func createViewController(with userToken: MastodonUserToken, store: Int? = nil) -> UIViewController {
        let vc = _internal_createViewController(with: userToken)
        if let store = store {
            vc.navigationItem.titleMenuProvider = { [weak vc, weak userToken] suggestions in
                guard let vc = vc, let userToken = userToken else {
                    return UIMenu()
                }
                return UIMenu(children: createTitleMenuFromUserToken(vc: vc, userToken: userToken, store: store))
            }
        }
        return vc
    }
}

private func createTitleMenuFromUserToken(vc: UIViewController, userToken: MastodonUserToken, store: Int) -> [UIMenuElement] {
    let descriptors: [CodableViewDescriptor] = [.home, .notifications, .local, .federated, .homeAndLocal]
    let makeAction = { [weak vc, weak userToken] (descriptor: CodableViewDescriptor) in
        return UIAction(title: descriptor.localizedShortTitle, image: descriptor.systemImage) { [weak vc, weak userToken] (_: UIAction) in
            guard let vc = vc, let userToken = userToken else {
                return
            }
            let newVC = descriptor.createViewController(with: userToken, store: store)
            vc.navigationController?.setViewControllers([newVC], animated: true)
            vc.navigationController?.tabBarItem.title = descriptor.localizedShortTitle
            vc.navigationController?.tabBarItem.image = descriptor.systemImage
            do {
                try userToken.setSelectedTab(index: store, descriptor: descriptor)
            } catch {
                DispatchQueue.main.async {
                    newVC.errorReport(error: error)
                }
            }
        }
    }
    
    var elements: [UIMenuElement] = descriptors.map { makeAction($0) }
    elements.append(UIMenu(title: L10n.Localizable.lists, image: UIImage(systemName: "list.bullet"), children: [
        UIDeferredMenuElement({ [weak userToken] callback in
            Task { [weak userToken] in
                var items: [UIMenuElement] = []
                if let userToken = userToken {
                    items.append(contentsOf: ((try? await MastodonEndpoint.MyLists().request(with: userToken)) ?? []).map { makeAction(.list(id: $0.id.string, title: $0.title)) })
                }
                await MainActor.run { [items] in
                    callback(items)
                }
            }
        })
    ]))
    
    return elements
}
