//
//  OtherMenuPushSettingsAccountTableViewController.swift
//  iMast
//
//  Created by user on 2018/07/28.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit
import Eureka
import Hydra
import SVProgressHUD
import Notifwift

@available(iOS 10.0, *)
class OtherMenuPushSettingsAccountTableViewController: FormViewController {
    let accountOriginal: PushServiceToken!
    let account: PushServiceToken!

    init(account: PushServiceToken) {
        self.accountOriginal = account
        self.account = CodableDeepCopy(account)
        super.init(style: .grouped)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done) { _ in
            SVProgressHUD.show()
            self.account.update().always {
                SVProgressHUD.dismiss()
            }.then { _ in
                Notifwift.post(.pushSettingsAccountReload)
                self.dismiss(animated: true, completion: nil)
            }.catch { error in
                self.alert(title: "エラー", message: error.localizedDescription)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.account.acct
        self.form +++ Section("通知設定")
            <<< SwitchRow { row in
                row.title = "フォロー"
                row.value = self.account.notify.follow
                row.onChange { row in
                    self.account.notify.follow = row.value ?? false
                }
            }
            <<< SwitchRow { row in
                row.title = "メンション"
                row.value = self.account.notify.mention
                row.onChange { row in
                    self.account.notify.mention = row.value ?? false
                }
            }
            <<< SwitchRow { row in
                row.title = "ブースト"
                row.value = self.account.notify.boost
                row.onChange { row in
                    self.account.notify.boost = row.value ?? false
                }
            }
            <<< SwitchRow { row in
                row.title = "ふぁぼ"
                row.value = self.account.notify.favourite
                row.onChange { row in
                    self.account.notify.favourite = row.value ?? false
                }
        }
        // 絶対間に合わないから
        //                <<< SwitchRow() { row in
        //                    row.title = "フォローリクエスト"
        //                    row.value = self.account.notify.followRequest
        //                    row.tag = "followRequest"
        //                }
        self.form +++ Section()
            <<< ButtonRow { row in
                row.title = "このアカウントのプッシュ通知設定を削除"
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = .red
            }.onCellSelection { cell, row in
                self.confirm(title: "確認",
                             message: "\(self.account.acct)のプッシュ通知設定を削除してもよろしいですか?\n削除したアカウントは再度追加できます。",
                             okButtonMessage: "削除する",
                             style: .destructive,
                             cancelButtonMessage: "キャンセル"
                ).then { res -> Promise<Void> in
                    if res {
                        SVProgressHUD.show()
                        return self.account.delete().always {
                            SVProgressHUD.dismiss()
                        }.then { _ in
                            Notifwift.post(.pushSettingsAccountReload)
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        return Promise(resolved: ())
                    }
                }.catch { error in
                    self.alert(title: "エラー", message: "削除に失敗しました。\n\n\(error.localizedDescription)")
                }
            }
    }
}
