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
    
    var listId = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(self.editList))
        ]
    }
    
    func editList() {
        let navC = UINavigationController()
        let vc = FormViewController()
        let titleRow = TextRow { row in
                row.title = "名前"
                row.value = self.title
            }
        vc.form +++ Section()
            <<< titleRow
            +++ Section()
            <<< ButtonRow() { row in
                    row.title = "リストを削除"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .red
                }.onCellSelection { cell, row in
                    let alert = UIAlertController(title: "確認", message: "リスト「\(self.title ?? "")」を削除してもよろしいですか?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "削除", style: UIAlertActionStyle.destructive) { _ in
                        MastodonUserToken.getLatestUsed()!.delete("lists/\(self.listId)").then { res in
                            if res["error"].exists() {
                                vc.apiError(res)
                                return
                            }
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
            }
        ]
        let loadingItem = UIBarButtonItem()
        let actIndV = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        actIndV.startAnimating()
        actIndV.hidesWhenStopped = true
        loadingItem.customView = actIndV
        vc.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "保存", style: .plain) { item in
                vc.navigationItem.rightBarButtonItems = [loadingItem]
                MastodonUserToken.getLatestUsed()!.put("lists/\(self.listId)", params: ["title": titleRow.value ?? ""]).then { res in
                    if res["error"].exists() {
                        vc.navigationItem.rightBarButtonItems = [item]
                        vc.apiError(res)
                    } else {
                        self.title = res["title"].stringValue
                        navC.dismiss(animated: true, completion: nil)
                    }
                }
            }
        ]
        self.present(navC, animated: true, completion: nil)
    }
    
    override func loadTimeline() -> Promise<Void>{
        return Promise<Void>() { resolve, reject in
            MastodonUserToken.getLatestUsed()?.get("timelines/list/\(self.listId)").then { (res: JSON) in
                if (res.array != nil) {
                    self._addNewPosts(posts: res.arrayValue)
                }
                resolve()
            }
        }
    }
    
    override func refreshTimeline() {
        MastodonUserToken.getLatestUsed()?.get("timelines/list/\(listId)?limit=40&since_id="+(self.posts.count >= 1 ? self.posts[0]["id"].stringValue : "")).then { (res: JSON) in
            self.addNewPosts(posts: res.arrayValue)
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func readMoreTimeline() {
        MastodonUserToken.getLatestUsed()?.get("timelines/list/\(listId)?limit=40&max_id="+self.posts[self.posts.count-1]["id"].stringValue).then { (res: JSON) in
            if (res.array != nil) {
                print(res.array)
                self.appendNewPosts(posts: res.arrayValue)
                self.isReadmoreLoading = false
            }
        }
    }
    
    override func websocketEndpoint() -> String? {
        return "list&list=\(listId)"
    }
}
