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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = indexPath[1]
        print(selected)
        func userDefaultsConnect(_ row: PushRow<String>, name: String, map: [String: String]) {
            row.options = map.keys.map { (name) -> String in
                return map[name]!
            }
            let userDefaultsValue = UserDefaults.standard.string(forKey: name) ?? ""
            row.value = map[userDefaultsValue] ?? userDefaultsValue
            row.cellUpdate { (cell, row) in
                map.forEach({ (key, value) in
                    if(value == row.value) {
                        print(key)
                        UserDefaults.standard.set(key, forKey: name)
                    }
                })
            }
        }

        switch(tableView.cellForRow(at: indexPath)?.reuseIdentifier ?? "") {
        case "myProfile":
            MastodonUserToken.getLatestUsed()!.getUserInfo().then({ (user) in
                let newVC = openUserProfile(user: user)
                self.navigationController?.pushViewController(newVC, animated: true)
            })
        case "list":
            MastodonUserToken.getLatestUsed()!.get("lists").then({ lists in
                let vc = OtherMenuListsTableViewController()
                vc.lists = lists.arrayValue
                self.navigationController?.pushViewController(vc, animated: true)
            })
        case "settings":
            /*
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url)
             */
            let vc = FormViewController()
            vc.form +++ Section()
                <<< PushStringRow() { row in
                    row.title = "ストリーミング自動接続"
                    row.userDefaultsConnect(name: "streaming_autoconnect", map: [
                        "no": "しない",
                        "wifi": "WiFi接続時のみ",
                        "always": "常に接続",
                    ])
                }
                <<< TextRow() { row in
                    row.title = "新規連携時のvia"
                    row.placeholder = "iMast"
                    row.userDefaultsConnect(name: "new_account_via")
                }
                <<< SwitchRow() { row in
                    row.title = "フォロー関係を以前の表記にする"
                    row.userDefaultsConnect(name: "follow_relationships_old")
                }
            vc.form +++ Section("投稿設定")
                <<< SwitchRow() { row in
                    row.title = "投稿時にメディアURL追加"
                    row.userDefaultsConnect(name: "append_mediaurl")
                }
                <<< LabelRow() { row in
                    row.title = "nowplayingのフォーマット"
                }
                <<< TextAreaRow() { row in
                    row.placeholder = "#nowplaying {title} - {artist} ({albumTitle})"
                    row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                    row.userDefaultsConnect(name: "nowplaying_format")
                }
            vc.form +++ Section("タイムライン")
                <<< SliderRow() { row in
                    row.title = "ユーザー名の文字の大きさ"
                    row.maximumValue = 20
                    row.minimumValue = 10
                    row.steps = 20
                    row.userDefaultsConnect(name: "timeline_username_fontsize")
                }
                <<< SliderRow() { row in
                    row.title = "本文の文字の大きさ"
                    row.maximumValue = 20
                    row.minimumValue = 10
                    row.steps = 20
                    row.userDefaultsConnect(name: "timeline_text_fontsize")
                }
                <<< SliderRow() { row in
                    row.title = "アイコンの大きさ"
                    row.maximumValue = 72
                    row.minimumValue = 24
                    row.steps = (72-24)*2
                    row.userDefaultsConnect(name: "timeline_icon_size")
                }
                <<< SwitchRow() { row in
                    row.title = "公開範囲を絵文字で表示"
                    row.userDefaultsConnect(name: "visibility_emoji")
                }
                <<< SliderRow() { row in
                    row.title = "サムネイルの高さ"
                    row.maximumValue = 100
                    row.minimumValue = 0
                    row.steps = 100/5
                    row.userDefaultsConnect(name: "thumbnail_height")
            }

            vc.form +++ Section("ウィジェット")
                <<< LabelRow() { row in
                    row.title = "投稿フォーマット"
                }
                <<< TextAreaRow() { row in
                    row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                    row.placeholder = "ID: {clipboard}\n#何らかのハッシュタグとか"
                    row.userDefaultsConnect(name: "widget_format", userDefaults: UserDefaultsAppGroup)
                }
                <<< TextRow() { row in
                    row.title = "フィルタ"
                    row.placeholder = "[0-9]{7}"
                    row.userDefaultsConnect(name: "widget_filter", userDefaults: UserDefaultsAppGroup)
                }
            vc.title = "設定"
            let callhelpitem = UIBarButtonItem(title: "ヘルプ", style: .plain, target: self, action: #selector(self.openSettingsHelp(target:)))
            vc.navigationItem.rightBarButtonItems = [
                callhelpitem
            ]
            navigationController?.pushViewController(vc, animated: true)
            break
        default: // 何?
            break // いや知らんがなｗ
        }
    }
    
    func openSettingsHelp(target: Any) {
        let safari = SFSafariViewController(url: URL(string: "https://cinderella-project.github.io/iMast/help/settings.html")!)
        self.present(safari, animated: true, completion: nil)
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
