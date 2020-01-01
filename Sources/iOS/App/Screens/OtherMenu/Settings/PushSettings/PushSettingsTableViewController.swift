//
//  PushSettingsTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/07/17.
//  
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2019 rinsuki and other contributors.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import Eureka
import EurekaFormBuilder
import UserNotifications
import Notifwift
import Hydra
import Ikemen
import iMastiOSCore

@available(iOS 10.0, *)
class PushSettingsTableViewController: FormViewController {
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
        self.tableView.refreshControl = UIRefreshControl() ※ { view in
            view.addTarget(self, action: #selector(reload), for: .valueChanged)
        }
        self.form.append(self.accountsSection)
        self.form.append {
            Section(header: "共通設定") {
                SwitchRow { row in
                    row.title = "通知受信時のクライアント側の処理に失敗した場合に、本来の通知内容の代わりにエラーを通知する"
                    row.userDefaultsConnect(.showPushServiceError)
                }.cellUpdate { cell, row in
                    cell.textLabel?.numberOfLines = 0
                }
                ButtonRow { row in
                    row.title = "グループ化のルール設定 (β)"
                    row.cellStyle = .default
                }.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = .label
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = .disclosureIndicator
                }.onCellSelection { (cell, row) in
                    self.navigationController?.pushViewController(PushSettingsGroupNotifyTableViewController(), animated: true)
                }
                ButtonRow { row in
                    row.title = "通知音カスタム (α)"
                    row.cellStyle = .default
                    row.presentationMode = .show(controllerProvider: .callback(builder: { PushSettingsChangeSoundViewController() }), onDismiss: nil)
                }
                ButtonRow { row in
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
            }
            Section(header: "サポート用") {
                ButtonRow { row in
                    row.title = "プッシュ通知ユーザーIDを確認"
                }.onCellSelection { cell, row in
                    guard let userId = try? PushService.keyChain.getString("userId") else {
                        self.alert(title: "エラー", message: "ユーザーIDがわかりませんでした")
                        return
                    }
                    let alert = UIAlertController(
                        title: "ユーザーID",
                        message: "\(userId)",
                        preferredStyle: .alert
                    )
                    alert.addAction(.init(title: "コピー", style: .default) { _ in
                        UIPasteboard.general.string = userId
                    })
                    alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        self.title = "プッシュ通知設定"
        self.notifwift.observe(.pushSettingsAccountReload) { _ in
            self.reload(true)
        }
        Notifwift.post(.pushSettingsAccountReload)
    }
    
    @objc func reload(_ blocking: Bool = false) {
        let vc = ModalLoadingIndicatorViewController()
        let animatePromise: Promise<Void>
        if blocking {
            animatePromise = self.presentPromise(vc, animated: false)
        } else {
            animatePromise = Promise.init(resolved: ())
        }
        animatePromise.then {
            PushService.getRegisterAccounts()
        }.then { accounts in
            print(accounts)
            let rows = accounts.map { account -> BaseRow in
                return ButtonRow { row in
                    row.title = account.acct
                    row.cellStyle = .default
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .label
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                }.onCellSelection { cell, row in
                    let vc = PushSettingsAccountTableViewController(account: account)
                    let wrapVC = UINavigationController(rootViewController: vc)
                    self.present(wrapVC, animated: true, completion: nil)
                }
            }
            self.accountsSection.removeAll()
            self.accountsSection.append(contentsOf: rows)
            self.accountsSection.append(ButtonRow { row in
                row.title = "アカウントを追加"
                row.onCellSelection { cell, row in
                    self.addAccountDialog()
                }
            })
            self.tableView.reloadData()
        }.catch { error in
            switch error {
            case Alamofire.DataRequest.DecodableError.httpError(let message, _):
                if message == "user not found in auth" {
                } else {
                    self.alert(title: "APIエラー", message: message)
                }
            default:
                self.alert(title: "エラー", message: error.localizedDescription)
            }
            self.navigationController?.popViewController(animated: true)
        }.always(in: .main) {
            if blocking {
                vc.dismiss(animated: true, completion: nil)
            }
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAccountDialog() {
        Promise<String?>(in: .main) { resolve, reject, _ in
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
        }.then(in: .main) { res in
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
    
    func deleteAuthInfo() {
        let navigationController = self.navigationController
        confirm(
            title: "エラー",
            message: "サーバー上にあなたのデータが見つかりませんでした。これは一時的な障害や、プログラムの不具合で起こる可能性があります。\n\nこれが一時的なものではなく、永久的に直らないようであれば、(存在するかもしれない)サーバー上のデータを見捨てて再登録することができます。再登録をするために現在のプッシュ通知アカウントを削除しますか?",
            okButtonMessage: "削除",
            style: .destructive,
            cancelButtonMessage: "キャンセル"
        ).then { res in
            if res == false {
                return
            }
            PushService.deleteAuthInfo().then { _ in
                navigationController?.visibleViewController?.alert(title: "削除完了", message: "削除が完了しました。")
            }
        }
    }
    
    static func openRequest(vc: UIViewController) {
        if try! PushService.isRegistered() {
            vc.navigationController?.pushViewController(PushSettingsTableViewController(), animated: true)
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
                return vc.confirm(title: "プッシュ通知の利用確認", message: "このプッシュ通知機能は、\n本アプリ(iMast)の開発者である@rinsuki@mstdn.rinsuki.netが、希望したiMastの利用者に対して無償で提供するものです。そのため、予告なく一時もしくは永久的にサービスが利用できなくなることがあります。また、本機能を利用したことによる不利益や不都合などについて、本アプリの開発者や提供者は一切の責任を持たないものとします。\n\n同意して利用を開始しますか?", okButtonMessage: "同意する", style: .default, cancelButtonMessage: "キャンセル")
            }.then { result -> Promise<Void> in
                if result == false {
                    return Promise(resolved: ())
                } else {
                    return PushService.register().then { _ in
                        UIApplication.shared.registerForRemoteNotifications()
                        vc.navigationController?.pushViewController(PushSettingsTableViewController(), animated: true)
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
