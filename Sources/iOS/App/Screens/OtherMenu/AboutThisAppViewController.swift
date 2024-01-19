//
//  AboutThisAppViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/02/21.
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
import iMastiOSCore

class AboutThisAppViewController: UIViewController {
    
    enum Section {
        case app
        case author
        case translators
        case praise
    }
    
    enum Item: Hashable {
        case appInfo
        case externalLink(label: String, url: URL, useExternalBrowser: Bool)
        case tootWithHashtag
    }

    class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            let sectionIdentifier = snapshot().sectionIdentifiers[section]
            switch sectionIdentifier {
            case .app:
                return nil
            case .author:
                return L10n.Localizable.AboutThisApp.author
            case .translators:
                return L10n.Localizable.AboutThisApp.translators
            case .praise:
                return L10n.Localizable.AboutThisApp.praise
            }
        }
    }
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    lazy var dataSource = DataSource(tableView: tableView) { tableView, indexPath, item -> UITableViewCell? in
        switch item {
        case .appInfo:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "iMast"
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
            cell.detailTextLabel?.text = "Version \(version) (\(buildNumber))"
            return cell
        case .externalLink(let label, let url, _):
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = url.absoluteString
            cell.accessoryType = .disclosureIndicator
            return cell
        case .tootWithHashtag:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.Localizable.AboutThisApp.tootWithHashtag
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    override func loadView() {
        view = tableView
        title = L10n.Localizable.AboutThisApp.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
        tableView.delegate = self
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.app])
        snapshot.appendItems([.appInfo])
        snapshot.appendSections([.author])
        snapshot.appendItems([
            .externalLink(label: "りんすき / rinsuki", url: URL(string: "https://rinsuki.net/")!, useExternalBrowser: false),
        ])
        snapshot.appendSections([.translators])
        snapshot.appendItems([
            // TODO: 許可してくれた人リストから自動で生成してtranslated strings数でソート
            .externalLink(label: "夜楓Yoka", url: URL(string: "https://crowdin.com/profile/Yoka2627")!, useExternalBrowser: false), // 93
            .externalLink(label: "Satsuki Yanagi", url: URL(string: "https://crowdin.com/profile/u1-liquid")!, useExternalBrowser: false), // 74
            .externalLink(label: "public_yusuke", url: URL(string: "https://crowdin.com/profile/private-yusuke")!, useExternalBrowser: false), // 11
            .externalLink(label: "Liaizon Wakest", url: URL(string: "https://crowdin.com/profile/wakest")!, useExternalBrowser: false), // 6
            .externalLink(label: "硫酸鶏", url: URL(string: "https://crowdin.com/profile/acid_chicken")!, useExternalBrowser: false), // 2
        ])
        snapshot.appendSections([.praise])
        snapshot.appendItems([
            .externalLink(label: L10n.Localizable.AboutThisApp.starInGitHub, url: URL(string: "https://github.com/cinderella-project/iMast")!, useExternalBrowser: true),
            .externalLink(label: L10n.Localizable.AboutThisApp.reviewInAppStore, url: URL(string: "https://apps.apple.com/jp/app/imast/id1229461703?action=write-review")!, useExternalBrowser: true),
            .tootWithHashtag,
        ])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension AboutThisAppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if case .appInfo = dataSource.itemIdentifier(for: indexPath) {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .appInfo:
            return
        case .externalLink(_, let url, let useExternalBrowser):
            if useExternalBrowser {
                view.window?.windowScene?.open(url, options: nil, completionHandler: nil)
            } else {
                open(url: url)
            }
        case .tootWithHashtag:
            let vc = NewPostAccountSelectCushionViewController()
            vc.appendBottomString = " #imast_ios"
            present(ModalNavigationViewController(rootViewController: vc), animated: true, completion: nil)
            return
        }
    }
}
