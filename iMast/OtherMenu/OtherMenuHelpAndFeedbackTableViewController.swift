//
//  OtherMenuHelpAndFeedbackTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/10/05.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SafariServices
import Eureka
import Alamofire

class OtherMenuHelpAndFeedbackTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = indexPath[1]
        switch selected {
        case 0:
            let safariVC = SFSafariViewController(url: URL(string: "https://cinderella-project.github.io/iMast/help/")!)
            present(safariVC, animated: true, completion: nil)
        case 1:
            let versionString = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)+"(\((Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)))"
            let vc = FormViewController()
            let tar = TextAreaRow() { row in
                row.placeholder = "Feedbackの内容をお書きください"
                row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
            }
            vc.form +++ Section()
                <<< tar
            vc.form +++ Section("Feedbackを送信すると、以下の情報も一緒に送信され、iMastの改善に役立てられます。")
                <<< LabelRow() {
                    $0.title = "iMastのバージョン"
                    $0.value = versionString
                }
                <<< LabelRow() {
                    $0.title = "iOSのバージョン"
                    $0.value = UIDevice.current.systemVersion
                }
                <<< LabelRow() {
                    $0.title = "端末名"
                    $0.value = UIDevice.current.platform
                }
            vc.form +++ Section()
                <<< ButtonRow() {
                    $0.title = "送信"
                    }.onCellSelection({ (cell, row) in
                        if (tar.value ?? "") == "" {
                            self.alert(title: "エラー", message: "Feedbackの内容を入力してください")
                            return
                        }
                        let postBody = [
                            "body": tar.value ?? "",
                            "app_version": versionString,
                            "ios_version": UIDevice.current.systemVersion,
                            "device_name": UIDevice.current.platform
                        ]
                        Alamofire.request("https://imast-backend.rinsuki.net/old-api/feedback", method: .post, parameters: postBody).responseJSON { request in
                            if (request.response?.statusCode ?? 0) >= 400 {
                                self.alert(title: "通信エラー", message: "通信に失敗しました。(HTTP-\((request.response?.statusCode ?? 599)))\nしばらく待ってから、もう一度送信してみてください。\nFeedbackは@imast_ios@imastodon.netへのリプライでも受け付けています。")
                            }
                            if request.error != nil {
                                self.alert(title: "通信エラー", message: "通信に失敗しました。\nしばらく待ってから、もう一度送信してみてください。\nFeedbackは@imast_ios@imastodon.netへのリプライでも受け付けています。")
                                return
                            }
                            vc.navigationController?.popViewController(animated: true)
                            vc.alert(title: "送信しました!",message: "Feedbackありがとうございました。")
                        }
                    })
            vc.title = "Feedback"
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let safariVC = SFSafariViewController(url: URL(string: "https://github.com/cinderella-project/iMast/issues")!)
            present(safariVC, animated: true, completion: nil)
        default:
            print("凛「ここ、どこ...?プロデューサーは...?」")
        }
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
 */

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
