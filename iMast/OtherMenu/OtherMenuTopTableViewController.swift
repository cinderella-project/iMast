//
//  OtherMenuTopTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/05/18.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import Eureka
import SafariServices

class OtherMenuTopTableViewController: UITableViewController {

    var nowAccount: MastodonUserToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        nowAccount = MastodonUserToken.getLatestUsed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = indexPath[1]
        print(selected)
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        switch cell.reuseIdentifier ?? "" {
        case "myProfile":
            MastodonUserToken.getLatestUsed()!.verifyCredentials().then { account in
                print(account)
                let newVC = openUserProfile(user: account)
                self.navigationController?.pushViewController(newVC, animated: true)
            }.catch { error in
                    print(error)
            }
        case "list":
            // TODO: ここの下限バージョンの処理をあとで共通化する
            MastodonUserToken.getLatestUsed()!.getIntVersion().then { version in
                if version < MastodonVersionStringToInt("2.1.0rc1") {
                    self.alert(title: "エラー", message: "この機能はMastodonインスタンスのバージョンが2.1.0rc1以上でないと利用できません。\n(iMastを起動中にインスタンスがアップデートされた場合は、アプリを再起動すると利用できるようになります)\nMastodonインスタンスのアップデート予定については、各インスタンスの管理者にお尋ねください。")
                    return
                }
                MastodonUserToken.getLatestUsed()!.lists().then({ lists in
                    let vc = OtherMenuListsTableViewController()
                    vc.lists = lists
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        case "settings":
            /*
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url)
             */
            let vc = SettingsViewController()
            navigationController?.pushViewController(vc, animated: true)
        case "siri_shortcuts":
            if #available(iOS 12.0, *) {
                let vc = CreateSiriShortcutsViewController()
                vc.title = cell.textLabel?.text
                navigationController?.pushViewController(vc, animated: true)
            } else {
                // Fallback on earlier versions
                self.alert(title: "エラー", message: R.string.localizable.errorRequiredNewerOS(12.0))
            }
        default: // 何?
            break // いや知らんがなｗ
        }
    }

    // MARK: - Table view data source

    /*
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    */

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let textLabel = cell.detailTextLabel, let nowAccount = self.nowAccount {
            let acct = nowAccount.screenName! + "@" + nowAccount.app.instance.hostName
            textLabel.text = textLabel.text?.replace("%", acct)
        }

        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    @IBAction func searchButtonTapped(_ sender: Any) {
        self.navigationController?.pushViewController(SearchViewController(), animated: true)
    }
}
