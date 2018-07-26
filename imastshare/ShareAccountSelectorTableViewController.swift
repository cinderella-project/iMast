//
//  ShareAccountSelectorTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/06/08.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SDWebImage

class ShareAccountSelectorTableViewController: UITableViewController {

    let userTokens = MastodonUserToken.getAllUserTokens()
    var nowUserTokenId = ""
    var parentVC: ShareViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "アカウント選択"
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: nil)
        
        let userToken = userTokens[indexPath[1]]
        cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        cell.textLabel!.text = userToken.name
        cell.detailTextLabel!.text = "@\((userToken.screenName ?? "--unknown--"))@"+userToken.app.instance.hostName
        if userToken.id == self.nowUserTokenId {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        if let avatarUrl = userToken.avatarUrl {
            cell.imageView?.sd_setImage(with: URL(string: avatarUrl), completed: { (image, error, cacheType, url) in
                cell.setNeedsLayout()
            })
            cell.imageView?.ignoreSmartInvert()
        }
        
        // Configure the cell...
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentVC!.userToken = userTokens[indexPath[1]]
        nowUserTokenId = userTokens[indexPath[1]].id!
        tableView.reloadData()  
    }

    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
