//
//  OtherMenuAccountChangeTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/18.
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
import iMastiOSCore

class ChangeActiveAccountViewController: UITableViewController {

    @IBOutlet var accountsTableView: UITableView!
    var userTokens: [MastodonUserToken] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = L10n.Localizable.switchActiveAccount
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "ユーザー情報を更新")
        refreshControl.addTarget(self, action: #selector(ChangeActiveAccountViewController.refresh), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onTapAddAccountButton))
        
        tableView.rowHeight = 44
        updateTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableView() {
        userTokens = MastodonUserToken.getAllUserTokens()
        tableView.reloadData()
    }
    
    @objc func refresh() {
        Task {
            await self.refreshAsync()
        }
    }
    
    func refreshAsync() async {
        var successCount = 0
        var failedCount = 0
        let allCount = userTokens.count
        for userToken in userTokens {
            do {
                try await userToken.getUserInfo(cache: false)
                try userToken.save()
                successCount += 1
            } catch {
                failedCount += 1
            }
            print(successCount, failedCount, allCount)
            let s = successCount, f = failedCount, all = allCount
            await MainActor.run {
                self.refreshControl?.attributedTitle = NSAttributedString(string: "ユーザー情報を更新(成功\(s) + 失敗\(f) = 合計 \(s+f)/\(all))")
            }
        }
        await MainActor.run {
            updateTableView()
            refreshControl?.endRefreshing()
            refreshControl?.attributedTitle = NSAttributedString(string: "ユーザー情報を更新")
        }
    }
    
    @objc func onTapAddAccountButton() {
        self.changeRootVC(AddAccountIndexViewController())
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userTokens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let userToken = userTokens[indexPath.row]
                
        cell.textLabel!.text = userToken.name   
        cell.detailTextLabel!.text = "@\(userToken.acct) (\(userToken.app.name))"
        if indexPath.row == 0 {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        if let avatarUrl = userToken.avatarUrl {
            cell.imageView?.loadImage(from: URL(string: avatarUrl)) {
                cell.setNeedsLayout()
            }
            cell.imageView?.ignoreSmartInvert()
        }
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let token = userTokens[indexPath.row]
        token.use()
        changeRootVC(MainTabBarController.instantiate(environment: token))
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    /*
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
        }
    }
    */
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { (action, sourceView, completionHandler) -> Void in
            tableView.isEditing = false
            let userToken = self.userTokens[indexPath.row]
            let alertVC = UIAlertController(title: "削除の確認", message: "iMastから以下のアカウントを削除しますか？\n(この端末のiMastからアカウント切り替えができなくなるだけで、iMastの連携が自動で解除されたり、他の端末のiMastからこのアカウントが消えたり、Mastodonからこのアカウントが消えることはありません。)\n\n@\(userToken.acct)", preferredStyle: .actionSheet)
            alertVC.popoverPresentationController?.sourceView = self.tableView.cellForRow(at: indexPath)
            alertVC.popoverPresentationController?.permittedArrowDirections = [.up, .down]
            alertVC.addAction(UIAlertAction(title: "削除", style: .destructive) { _ in
                do {
                    try userToken.delete()
                    self.userTokens = MastodonUserToken.getAllUserTokens()
                    self.tableView.reloadData()
                    if indexPath.row == 0 {
                        if let token = MastodonUserToken.getLatestUsed() {
                            self.changeRootVC(MainTabBarController.instantiate(environment: token))
                        } else {
                            self.changeRootVC(AddAccountIndexViewController())
                        }
                    }
                    completionHandler(true)
                } catch {
                    self.errorReport(error: error)
                    completionHandler(false)
                }
            })
            alertVC.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                completionHandler(false)
            })
            self.present(alertVC, animated: true, completion: nil)
        }
        return .init(actions: [deleteAction])
    }
}
