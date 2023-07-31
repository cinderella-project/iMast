//
//  NotificationTableWrapperViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/03/05.
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

import UIKit
import Mew
import iMastiOSCore
import Ikemen

class NotificationTableWrapperViewController: UIViewController, Instantiatable {
    typealias Input = Void
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum FilterType: CaseIterable {
        case all
        case mention
        case reaction
        case follow
        
        var name: String {
            switch self {
            case .all:
                return "All"
            case .mention:
                return "Mention"
            case .reaction:
                return "Reaction"
            case .follow:
                return "Follow"
            }
        }
    }
    
    let segmentedControl = UISegmentedControl(items: FilterType.allCases.map { $0.name }) ※ { v in
        v.selectedSegmentIndex = 0
        v.addTarget(self, action: #selector(changeFilter), for: .valueChanged)
    }
    lazy var toolBar = UIToolbar() ※ { b in
        b.items = [
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            .init(customView: segmentedControl),
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        ]
        b.frame.size.height = 44
        b.delegate = self
    }
    
    let containerView = ContainerView()
    lazy var notificationVC: NotificationTableViewController = .instantiate([], environment: environment)
    
    override func loadView() {
        view = UIView()
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(44)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Localizable.notifications
        additionalSafeAreaInsets.top = toolBar.frame.height
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.largeTitleDisplayMode = .never
        changeContainer()
    }
    
    func changeContainer() {
        if containerView.arrangedSubviews.count > 0 {
            containerView.removeArrangedViewController(notificationVC)
            let includeTypes: [NotificationTableViewController.NotificationType]
            switch FilterType.allCases[segmentedControl.selectedSegmentIndex] {
            case .all:
                includeTypes = NotificationTableViewController.NotificationType.allCases
            case .mention:
                includeTypes = [.mention]
            case .reaction:
                includeTypes = [.reblog, .favourite]
            case .follow:
                includeTypes = [.follow]
            }
            notificationVC = .instantiate(NotificationTableViewController.NotificationType.reverse(types: includeTypes), environment: environment)
        }
        containerView.addArrangedViewController(notificationVC, parentViewController: self)
    }
    
    @objc func changeFilter() {
        print(segmentedControl.selectedSegmentIndex)
        changeContainer()
    }
}

extension NotificationTableWrapperViewController: UIToolbarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
