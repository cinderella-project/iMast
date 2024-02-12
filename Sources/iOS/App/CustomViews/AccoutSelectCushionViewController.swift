//
//  AccoutSelectCushionViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/02/22.
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

class AccoutSelectCushionBaseViewController: UIViewController {
    enum Section {
        case onlyOne
    }
    
    let accounts = MastodonUserToken.getAllUserTokens()
    let tableView = UITableView()
    lazy var dataSource = UITableViewDiffableDataSource<Section, Int>(tableView: tableView) { tableView, indexPath, item -> UITableViewCell? in
        let account = self.accounts[item]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = account.name
        cell.detailTextLabel?.text = "@\(account.acct) (via \(account.app.name))"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var snapshot = dataSource.plainSnapshot()
        snapshot.appendSections([.onlyOne])
        snapshot.appendItems(accounts.enumerated().map { $0.offset })
        dataSource.apply(snapshot)
        tableView.delegate = self
        title = L10n.Localizable.chooseAccount
    }
    
    func showVC(userToken: MastodonUserToken) {
        print("nothing")
    }
}

extension AccoutSelectCushionBaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let index = dataSource.itemIdentifier(for: indexPath) else { return }
        let userToken = accounts[index]
        showVC(userToken: userToken)
    }
}

class AccountSelectCushionViewController<T: UIViewController & Instantiatable>: AccoutSelectCushionBaseViewController, Instantiatable where T.Environment == MastodonUserToken {
    typealias Input = T.Input
    typealias Environment = Void
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
    
    override func showVC(userToken: MastodonUserToken) {
        let vc = T.instantiate(input, environment: userToken)
        show(vc, sender: self)
    }
}

class NewPostAccountSelectCushionViewController: AccoutSelectCushionBaseViewController {
    var appendBottomString = ""
    
    override func showVC(userToken: MastodonUserToken) {
        let userActivity = NSUserActivity(newPostWithMastodonUserToken: userToken)
        userActivity.newPostSuffix = appendBottomString
        let newPost = NewPostViewController(userActivity: userActivity)
        show(newPost, sender: self)
    }
}
