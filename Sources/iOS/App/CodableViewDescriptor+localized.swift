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
    
    func createViewController(with userToken: MastodonUserToken) -> UIViewController {
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
}
