//
//  ReadmoreView.swift
//  iMast
//
//  Created by rinsuki on 2018/07/28.
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
import SnapKit
import iMastiOSCore
import Ikemen

class ReadmoreView: UIView {
    enum State {
        case moreLoadable
        case allLoaded
        case loading
        case withError
    }
    
    var lastError: Error?
    
    private let button = UIButton()
    private let indicator = UIActivityIndicatorView()
    weak var target: AnyObject?
    var action: Selector?
    
    @Published var state: State = .moreLoadable {
        didSet {
            DispatchQueue.mainSafeSync {
                button.isHidden = state == .loading
                if state == .loading {
                    indicator.startAnimating()
                } else {
                    indicator.stopAnimating()
                }
                if state != .loading {
                    let isError = state == .withError
                    button.isEnabled = state != .allLoaded
                    button.setTitle(isError ? L10n.Localizable.Error.title : L10n.Localizable.readmore, for: .normal)
                    button.setTitleColor(isError ? .systemRed : tintColor, for: .normal)
                }
                if state != .withError {
                    lastError = nil
                }
            }
        }
    }
    
    init() {
        super.init(frame: .init(x: 0, y: 0, width: 320, height: 44))
        addSubview(button)
        addSubview(indicator)
        button.snp.makeConstraints { make in
            make.center.size.equalTo(safeAreaLayoutGuide)
            make.height.greaterThanOrEqualTo(44)
            make.height.equalTo(44).priority(.low)
        }
        button.setTitle(L10n.Localizable.nothingMore, for: .disabled)
        button.setTitleColor(.systemGray, for: .disabled)
        button.setTitle(L10n.Localizable.readmore, for: .normal)
        button.setTitleColor(tintColor, for: .normal)
        button.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
        indicator.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
        }
        indicator.style = .medium
        indicator.hidesWhenStopped = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTableView(_ tableView: UITableView) {
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = []
        tableView.tableFooterView = self
    }
    
    @objc func readMoreTapped() {
        if state == .withError {
            if let error = lastError {
                viewController?.errorReport(error: error)
            }
            state = .moreLoadable
        } else {
            if let action = action {
                _ = target?.perform(action)
            }
        }
    }
    
    @available(iOS 17.0, *)
    func makeUIContentUnavailableConfiguration() -> UIContentUnavailableConfiguration? {
        switch state {
        case .loading:
            return UIContentUnavailableConfiguration.loading()
        case .withError:
            if let error = lastError as? NSError {
                var config = UIContentUnavailableConfiguration.empty()
                config.image = .init(systemName: "bolt.horizontal.fill")
                config.text = error.localizedFailureReason ?? error.localizedDescription
                config.secondaryText = error.localizedRecoverySuggestion
                
                var button = UIButton.Configuration.borderedProminent()
                #if !os(visionOS)
                if #available(iOS 26.0, *) {
                    button = .prominentGlass()
                }
                #endif
                button.image = UIImage(systemName: "arrow.clockwise")
                button.imagePlacement = .leading
                button.imagePadding = 8
                button.title = L10n.Localizable.refetch
                config.button = button
                
                config.buttonProperties.role = .primary
                config.buttonProperties.primaryAction = UIAction { [weak self] _ in
                    if let action = self?.action {
                        _ = self?.target?.perform(action)
                    }
                }
                
                config.secondaryButton = .plain() ※ {
                    $0.title = "詳細を見る"
                }
                config.secondaryButtonProperties.primaryAction = UIAction { [weak self] _ in
                    self?.viewController?.presentErrorDetailReport(error: error)
                }
                return config
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
