//
//  OtherMenuPushSettingsGroupNotifyTableViewController.swift
//  iMast
//
//  Created by user on 2018/09/18.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit
import Eureka

class OtherMenuPushSettingsGroupNotifyTableViewController: FormViewController {

    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "グループ化のルール設定 (β)"
        
        self.form +++ Section()
            <<< SwitchRow() { row in
                row.title = "アカウント毎にグループを分ける"
                row.userDefaultsConnect(.groupNotifyAccounts)
            }
        +++ Section(header: "通知タイプ毎にグループを分ける", footer: "ONにしたタイプはすべて個別のグループになります。")
            <<< SwitchRow() { row in
                row.title = "ブースト"
                row.userDefaultsConnect(.groupNotifyTypeBoost)
            }
            <<< SwitchRow() { row in
                row.title = "お気に入り"
                row.userDefaultsConnect(.groupNotifyTypeFavourite)
            }
            <<< SwitchRow() { row in
                row.title = "メンション"
                row.userDefaultsConnect(.groupNotifyTypeMention)
            }
            <<< SwitchRow() { row in
                row.title = "フォロー"
                row.userDefaultsConnect(.groupNotifyTypeFollow)
            }
            <<< SwitchRow() { row in
                row.title = "その他"
                row.userDefaultsConnect(.groupNotifyTypeUnknown)
            }
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
