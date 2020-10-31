//
//  ChangeAppIconViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/10/31.
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

class ChangeAppIconViewController: UIViewController, UITableViewDelegate {
    let tableView = UITableView()
    
    enum Section {
        case onlyOne
    }
    
    enum Item: CaseIterable {
        case `default`
        case old
        case trueDark
    }
    
    lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var state = cell.defaultContentConfiguration()
        switch item {
        case .default:
            state.image = UIImage(named: "AppIcon")
            state.text = L10n.Preferences.General.AppIcons.Default.title
            state.secondaryText = L10n.Preferences.General.AppIcons.Default.description
        case .old:
            state.image = UIImage(named: "AppIcon-Old")
            state.text = L10n.Preferences.General.AppIcons.Old.title
            state.secondaryText = L10n.Preferences.General.AppIcons.Old.description
        case .trueDark:
            state.image = UIImage(named: "AppIcon-TrueDark")
            state.text = L10n.Preferences.General.AppIcons.TrueDark.title
            state.secondaryText = L10n.Preferences.General.AppIcons.TrueDark.description
        }
        cell.contentConfiguration = state
        return cell
    }
    
    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = L10n.Preferences.General.AppIcons.title
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.onlyOne])
        snapshot.appendItems(Item.allCases)
        dataSource.apply(snapshot)
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.setAlternateIconName("AppIcon-Old") { (err) in
            print(err)
        }
    }
}
