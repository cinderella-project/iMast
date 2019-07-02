//
//  OtherMenuPushSettingsTableViewController.swift
//  iMast
//
//  Created by user on 2018/07/17.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import Eureka
import ActionClosurable
import UserNotifications
import Notifwift
import Hydra

@available(iOS 10.0, *)
class OtherMenuPushSettingsTableViewController: FormViewController {
    var loginSafari: LoginSafari!
    let notifwift = Notifwift()
    
    var accounts: [PushServiceToken] = []
    
    let accountsSection = Section("アカウント一覧")
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.refreshControl = UIRefreshControl { _ in
            self.reload()
        }
        self.form.append(self.accountsSection)
        self.form +++ Section("共通設定")
            <<< SwitchRow { row in
                row.title = "通知受信時のクライアント側の処理に失敗した場合に、本来の通知内容の代わりにエラーを通知する"
                row.userDefaultsConnect(.showPushServiceError)
            }.cellUpdate { cell, row in
                cell.textLabel?.numberOfLines = 0
            }
            <<< ButtonRow { row in
                row.title = "グループ化のルール設定 (β)"
                row.cellStyle = .default
                row.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = .label
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = .disclosureIndicator
                }
                row.onCellSelection { (cell, row) in
                    self.navigationController?.pushViewController(OtherMenuPushSettingsGroupNotifyTableViewController(), animated: true)
                }
            }
            <<< ButtonRow { row in
                row.title = "プッシュ通知の設定を削除"
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.red
            }.onCellSelection { cell, row in
                self.confirm(
                    title: "確認",
                    message: "プッシュ通知の設定を削除します。\nこれにより、サーバーに保存されているあなたのプッシュ通知に関連する情報が削除されます。\n再度利用するには、もう一度プッシュ通知の設定をしなおす必要があります。",
                    okButtonMessage: "削除する", style: UIAlertAction.Style.destructive,
                    cancelButtonMessage: "キャンセル"
                ).then { res -> Promise<Void> in
                    if res {
                        return PushService.unRegister().then { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        return Promise(resolved: ())
                    }
                }.catch { error in
                    self.alert(title: "エラー", message: "削除に失敗しました。\n\n" + error.localizedDescription)
                }
            }
        self.title = "プッシュ通知設定"
        self.notifwift.observe(.pushSettingsAccountReload) { _ in
            self.reload(true)
        }
        Notifwift.post(.pushSettingsAccountReload)
    }
    
    func reload(_ blocking: Bool = false) {
        if blocking {
            SVProgressHUD.show()
        }
        PushService.getRegisterAccounts().then { accounts in
            print(accounts)
            let rows = accounts.map { account -> BaseRow in
                return ButtonRow { row in
                    row.title = account.acct
                    row.cellStyle = .default
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                }.onCellSelection { cell, row in
                    let vc = OtherMenuPushSettingsAccountTableViewController(account: account)
                    let wrapVC = UINavigationController(rootViewController: vc)
                    self.present(wrapVC, animated: true, completion: nil)
                }
            }
            self.accountsSection.removeAll()
            self.accountsSection.append(contentsOf: rows)
            self.accountsSection <<< ButtonRow { row in
                row.title = "アカウントを追加"
            }.onCellSelection { cell, row in
                Promise<String?> { resolve, reject, _ in
                    let alert = UIAlertController(title: "アカウント追加", message: "インスタンスのホスト名を入力してください\n(https://などは含めず入力してください)", preferredStyle: .alert)
                    alert.addTextField { textField in
                        textField.placeholder = "mstdn.example.com"
                    }
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        resolve(alert.textFields?.first?.text)
                    })
                    alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                        resolve(nil as String?)
                    })
                    self.present(alert, animated: true, completion: nil)
                }.then { host -> Promise<String> in
                    guard let host = host else {
                        throw APIError.alreadyError
                    }
                    return PushService.getAuthorizeUrl(host: host)
                }.then { res in
                    self.loginSafari = getLoginSafari()
                    self.loginSafari.open(url: URL(string: res)!, viewController: self)
                }.catch { error in
                    switch error {
                    case APIError.alreadyError:
                        break
                    default:
                        self.alert(title: "エラー", message: error.localizedDescription)
                    }
                }
            }
            self.tableView.reloadData()
        }.catch { error in
            switch error {
            case Alamofire.DataRequest.DecodableError.httpError(let message, _):
                if message == "user not found in auth" {
                    self.confirm(
                        title: "エラー",
                        message: "サーバー上にあなたのデータが見つかりませんでした。これは一時的な障害や、プログラムの不具合で起こる可能性があります。\n\nこれが一時的なものではなく、永久的に直らないようであれば、(存在するかもしれない)サーバー上のデータを見捨てて再登録することができます。再登録をしますか?",
                        okButtonMessage: "再登録",
                        style: .destructive,
                        cancelButtonMessage: "キャンセル"
                    ).then { res in
                        if res == false {
                            return
                        }
                        PushService.deleteAuthInfo().then {
                            UIApplication.shared.viewController?.alert(title: "削除完了", message: "削除が完了しました。")
                        }
                    }
                } else {
                    self.alert(title: "APIエラー", message: message)
                }
            default:
                self.alert(title: "エラー", message: error.localizedDescription)
            }
            self.navigationController?.popViewController(animated: true)
        }.always(in: .main) {
            if blocking {
                SVProgressHUD.dismiss()
            }
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func openRequest(vc: UIViewController) {
        if try! PushService.isRegistered() {
            vc.navigationController?.pushViewController(OtherMenuPushSettingsTableViewController(), animated: true)
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]).then { res -> Promise<Bool> in
                if res == false {
                    return Promise<Bool> { resolve, reject, _ in
                        let alert = UIAlertController(title: "通知が許可されていません", message: "iOSの設定で、iMastからの通知を許可してください。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "設定へ", style: UIAlertAction.Style.default) { _ in
                            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                            resolve(false)
                        })
                        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                            resolve(false)
                        })
                        vc.present(alert, animated: true, completion: nil)
                    }
                }
                return vc.confirm(title: "プッシュ通知の利用確認", message: "このプッシュ通知機能は、本アプリ(iMast)の開発者である@rinsuki@mstdn.rinsuki.netが、希望したiMastの利用者に対して無償で提供するものです。そのため、予告なく一時もしくは永久的にサービスが利用できなくなることがあります。また、本機能を利用したことによる不利益や不都合などについて、本アプリの開発者や提供者は一切の責任を持たないものとします。\n\n同意して利用を開始しますか?", okButtonMessage: "同意する", style: .default, cancelButtonMessage: "キャンセル")
            }.then { result -> Promise<Void> in
                if result == false {
                    return Promise(resolved: ())
                } else {
                    return PushService.register().then { _ in
                        UIApplication.shared.registerForRemoteNotifications()
                        vc.navigationController?.pushViewController(OtherMenuPushSettingsTableViewController(), animated: true)
                    }
                }
            }.catch { e in
                switch e {
                case Alamofire.DataRequest.DecodableError.httpError(let message, _):
                    vc.alert(title: "APIエラー", message: message)
                default:
                    vc.alert(title: "エラー", message: "登録中にエラーが発生しました。\n\n\(e.localizedDescription)")
                }
            }
        }
    }
}
