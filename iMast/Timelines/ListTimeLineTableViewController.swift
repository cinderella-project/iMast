//
//  ListTimeLineTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/11/22.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Hydra
import Eureka
import ActionClosurable

class ListTimeLineTableViewController: TimeLineTableViewController {
    
    var list: MastodonList!
    
    override func viewDidLoad() {
        self.timelineType = .list(self.list)
        self.isNewPostAvailable = true
        super.viewDidLoad()
    }
    
    @objc func editList() {
        let navC = UINavigationController()
        let vc = FormViewController()
        let titleRow = TextRow { row in
                row.title = "名前"
                row.value = self.title
            }
        vc.form +++ Section()
            <<< titleRow
            +++ Section()
            <<< ButtonRow { row in
                    row.title = "リストを削除"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .red
                }.onCellSelection { cell, row in
                    let alert = UIAlertController(title: "確認", message: "リスト「\(self.title ?? "")」を削除してもよろしいですか?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive) { _ in
                        MastodonUserToken.getLatestUsed()!.delete(list: self.list).then {
                            vc.dismiss(animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                    alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                    vc.present(alert, animated: true, completion: nil)
                }
        
        vc.title = "編集"
        navC.pushViewController(vc, animated: false)
        vc.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "キャンセル", style: .plain) { _ in
                navC.dismiss(animated: true, completion: nil)
            },
        ]
        let loadingItem = UIBarButtonItem()
        let actIndV = UIActivityIndicatorView(style: .gray)
        actIndV.startAnimating()
        actIndV.hidesWhenStopped = true
        loadingItem.customView = actIndV
        vc.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "保存", style: .plain) { item in
                vc.navigationItem.rightBarButtonItems = [loadingItem]
                MastodonUserToken.getLatestUsed()!.list(list: self.list, title: titleRow.value ?? "").then { res in
//                    if res["error"].exists() {
//                        vc.navigationItem.rightBarButtonItems = [item]
//                        vc.apiError(res)
//                    } else {
                        self.title = res.title
                        navC.dismiss(animated: true, completion: nil)
//                    }
                }
            },
        ]
        self.present(navC, animated: true, completion: nil)
    }
    
    override func websocketEndpoint() -> String? {
        return "list&list=\(list.id.string)"
    }
}
