//
//  OtherMenuAccountChangeTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/18.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import Hydra
import SwiftyJSON

class OtherMenuAccountChangeTableViewController: UITableViewController {

    @IBOutlet var accountsTableView: UITableView!
    var userTokens: [MastodonUserToken] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "ユーザー情報を更新")
        refreshControl?.addTarget(self, action: #selector(OtherMenuAccountChangeTableViewController.refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl!)
        
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
        var successCount = 0
        var failedCount = 0
        let allCount = userTokens.count
        func redrawRefreshControl () {
            print(successCount, failedCount, allCount)
            self.refreshControl?.attributedTitle = NSAttributedString(string: "ユーザー情報を更新(\(String(successCount))/\(String(allCount)))")
        }
        var promise = Promise.init(resolved: Void()).then { _ in
            return
        }
        userTokens.forEach { (userToken) in
            promise = promise.then { _ in
                return userToken.getUserInfo()
            }.then { _ in
                userToken.save()
                successCount += 1
                redrawRefreshControl()
                return
            }.catch { _ in
                failedCount += 1
                redrawRefreshControl()
                return
            }
        }
        promise.then {_ in
            self.updateTableView()
            self.refreshControl?.endRefreshing()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "ユーザー情報を更新")
        }
    }

    @IBAction func addAccountButtonTapped(_ sender: Any) {
        if let vc = R.storyboard.login.logintop() {
            changeRootVC(vc, animated: true)
        }
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

        let userToken = userTokens[indexPath[1]]
                
        cell.textLabel!.text = userToken.name   
        cell.detailTextLabel!.text = String.init(format: "@%@@%@ (%@)", userToken.screenName ?? "--unknown--", userToken.app.instance.hostName, userToken.app.name)
        if indexPath[1] == 0 {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        if let avatarUrl = userToken.avatarUrl {
            cell.imageView?.sd_setImage(with: URL(string: avatarUrl)) { (image, error, cacheType, url) in
                cell.setNeedsLayout()
            }
            cell.imageView?.ignoreSmartInvert()
        }
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userTokens[indexPath[1]].use()
        changeRootVC(MainTabBarController(), animated: true)
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            tableView.isEditing = false
            let userToken = self.userTokens[indexPath[1]]
            let alertVC = UIAlertController(title: "削除の確認", message: "iMastから以下のアカウントを削除しますか？\n(この端末のiMastからアカウント切り替えができなくなるだけで、iMastの連携が自動で解除されたり、他の端末のiMastからこのアカウントが消えたり、Mastodonからこのアカウントが消えることはありません。)\n\n"+String.init(format: "@%@@%@", userToken.screenName ?? "--unknown--", userToken.app.instance.hostName), preferredStyle: .actionSheet)
            alertVC.addAction(UIAlertAction(title: "削除", style: .destructive) { _ in
                if userToken.delete() {
                    self.userTokens = MastodonUserToken.getAllUserTokens()
                    self.tableView.reloadData()
                    if indexPath[1] == 0 {
                        if self.userTokens.count > 0 {
                            changeRootVC(MainTabBarController(), animated: true)
                        } else {
                            changeRootVC(R.storyboard.login.instantiateInitialViewController()!, animated: true)
                        }
                    }
                }
            })
            alertVC.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = UIColor.red
        return [
            deleteAction,
        ]
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
