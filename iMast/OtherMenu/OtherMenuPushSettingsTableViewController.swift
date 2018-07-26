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
import PromiseKit
import SVProgressHUD
import Eureka
import ActionClosurable
import UserNotifications

@available(iOS 10.0, *)
class OtherMenuPushSettingsTableViewController: FormViewController {
    var loginSafari: LoginSafari!
    
    class OtherMenuPushSettingsAccountTableViewController: FormViewController {
        var settingsVC: OtherMenuPushSettingsTableViewController!
        let accountOriginal: PushServiceToken!
        let account: PushServiceToken!
        init(account: PushServiceToken) {
            self.accountOriginal = account
            self.account = CodableDeepCopy(account)
            super.init(style: .grouped)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style:.plain) { _ in
                self.dismiss(animated: true, completion: nil)
            }
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done) { _ in
                SVProgressHUD.show()
                firstly {
                    self.account.update()
                }.then { _ -> Promise<Void> in
                    SVProgressHUD.dismissPromise()
                }.done { _ in
                    self.settingsVC.reload(true)
                    self.dismiss(animated: true, completion: nil)
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
                <<< SwitchRow() { row in
                    row.title = "フォロー"
                    row.value = self.account.notify.follow
                    row.onChange { row in
                        self.account.notify.follow = row.value ?? false
                        print(row.value, self.account.notify.follow)
                    }
                }
                <<< SwitchRow() { row in
                    row.title = "メンション"
                    row.value = self.account.notify.mention
                    row.onChange { row in
                        self.account.notify.mention = row.value ?? false
                    }
                }
                <<< SwitchRow() { row in
                    row.title = "ブースト"
                    row.value = self.account.notify.boost
                    row.onChange { row in
                        self.account.notify.boost = row.value ?? false
                    }
                }
                <<< SwitchRow() { row in
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
                <<< ButtonRow() { row in
                    row.title = "このアカウントのプッシュ通知設定を削除"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .red
                }.onCellSelection { cell, row in
                    firstly {
                        self.confirm(title: "確認", message: "\(self.account.acct)のプッシュ通知設定を削除してもよろしいですか?\n削除したアカウントは再度追加できます。", okButtonMessage: "削除する", style: .destructive, cancelButtonMessage: "キャンセル")
                    }.then { res -> Promise<Void> in
                        if res {
                            SVProgressHUD.show()
                            return self.account.delete().ensure {
                                SVProgressHUD.dismiss()
                            }.map { _ in
                                self.settingsVC.reload(true)
                                self.dismiss(animated: true, completion: nil)
                                return ()
                            }
                        } else {
                            return Promise.value(())
                        }
                    }.catch { error in
                        self.alert(title: "エラー", message: "削除に失敗しました。\n\n\(error.localizedDescription)")
                    }
                }
        }
    }
    
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
        self.reload(true)
        self.form.append(self.accountsSection)
        self.form +++ Section("共通設定")
            <<< SwitchRow() { row in
                row.title = "通知受信時のクライアント側の処理に失敗した場合に、本来の通知内容の代わりにエラーを通知する"
                row.userDefaultsConnect(.showPushServiceError)
            }.cellUpdate { cell, row in
                cell.textLabel?.numberOfLines = 0
            }
            <<< ButtonRow() { row in
                row.title = "プッシュ通知の設定を削除"
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.red
            }.onCellSelection { cell, row in
                firstly {
                    self.confirm(
                        title: "確認",
                        message: "プッシュ通知の設定を削除します。\nこれにより、サーバーに保存されているあなたのプッシュ通知に関連する情報が削除されます。\n再度利用するには、もう一度プッシュ通知の設定をしなおす必要があります。",
                        okButtonMessage: "削除する", style: UIAlertActionStyle.destructive,
                        cancelButtonMessage: "キャンセル"
                    )
                }.then { res -> Promise<Void> in
                    if res {
                        return PushService.unRegister().map { _ in
                            self.navigationController?.popViewController(animated: true)
                            return ()
                        }
                    } else {
                        return Promise.value(())
                    }
                }.catch { error in
                    self.error(errorMsg: error.localizedDescription)
                }
            }
        self.title = "プッシュ通知設定"
    }
    
    func reload(_ blocking: Bool = false) {
        if blocking {
            SVProgressHUD.show()
        }
        PushService.getRegisterAccounts().done { accounts in
            print(accounts)
            let rows = accounts.map { account -> BaseRow in
                return ButtonRow() { row in
                    row.title = account.acct
                    row.cellStyle = .default
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }.onCellSelection { cell, row in
                    let vc = OtherMenuPushSettingsAccountTableViewController(account: account)
                    vc.settingsVC = self
                    let wrapVC = UINavigationController(rootViewController: vc)
                    self.present(wrapVC, animated: true, completion: nil)
                }
            }
            self.accountsSection.removeAll()
            self.accountsSection.append(contentsOf: rows)
            self.accountsSection <<< ButtonRow() { row in
                row.title = "アカウントを追加"
            }.onCellSelection { cell, row in
                let loginSafari = getLoginSafari()
                firstly {
                    Promise<String?>() { resolver in
                        let alert = UIAlertController(title: "アカウント追加", message: "インスタンスのホスト名を入力してください\n(https://などは含めず入力してください)", preferredStyle: .alert)
                        alert.addTextField { textField in
                            textField.placeholder = "mstdn.example.com"
                        }
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            resolver.resolve(alert.textFields?.first?.text, nil)
                        })
                        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                            resolver.resolve(nil as String?, nil)
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                }.then { host -> Promise<String> in
                    guard let host = host else {
                        throw APIError.alreadyError()
                    }
                    return PushService.getAuthorizeUrl(host: host)
                }.done { res in
                    self.loginSafari = getLoginSafari()
                    self.loginSafari.open(url: URL(string: res)!, viewController: self)
                }
            }
            self.tableView.reloadData()
        }.catch { error in
            self.alert(title: "エラー", message: error.localizedDescription)
            self.navigationController?.popViewController(animated: true)
        }.finally {
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
//            Alamofire.request("https://imast-backend.rinsuki.net/push/api/v1/get-url", method: .post, parameters: ["host": "mstdn.rinsuki.net"], encoding: JSONEncoding.default, headers: ["Authorization": try! PushService.getAuthorizationHeader()!]).response { res in
//                let json = try! JSON(data: res.data!)
//                UIApplication.shared.openURL(json["url"].url!)
//            }
            vc.navigationController?.pushViewController(self.init(), animated: true)
        } else {
            firstly {
                Promise<Bool>() { resolver in
                    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (accepted, error) in
                        resolver.resolve(accepted, error)
                    }
                }
            }.then { res -> Promise<Bool> in
                if res == false {
                    return vc.alertWithPromise(title: "エラー", message: "iOSの設定で通知を許可してください。").map {
                        return false
                    }
                }
                return vc.confirm(title: "プッシュ通知の利用確認", message: "このプッシュ通知機能は、本アプリ(iMast)の開発者である@rinsuki@mstdn.maud.ioが、希望したiMastの利用者に対して無償で提供するものです。そのため、予告なく一時もしくは永久的にサービスが利用できなくなることがあります。また、本機能を利用したことによる不利益や不都合などについて、本アプリの開発者や提供者は一切の責任を持たないものとします。\n\n同意して利用を開始しますか?", okButtonMessage: "同意する", style: .default, cancelButtonMessage: "キャンセル")
            }.then { result -> Promise<Void> in
                if result == false {
                    return Promise.value(())
                } else {
                    return PushService.register().done { _ in
                        UIApplication.shared.registerForRemoteNotifications()
                        vc.navigationController?.pushViewController(self.init(), animated: true)
                    }
                }
            }.catch { e in
                do {
                    throw e
                } catch PushServiceError.unknownError {
                    vc.alert(title: "不明なエラー", message: "登録中に不明なエラーが発生しました。")
                } catch PushServiceError.networkError(let message) {
                    if let message = message {
                        vc.alert(title: "通信エラー", message: "登録中に通信エラーが発生しました。\n\n\(message)")
                    } else {
                        vc.alert(title: "通信エラー", message: "登録中に通信エラーが発生しました。")
                    }
                } catch PushServiceError.responseError(let message, let httpCode) {
                    vc.alert(title: "エラー", message: "登録中にエラーが発生しました。\n\nメッセージ: \(message ?? "")\nエラーコード: HTTP-\(httpCode)")
                } catch PushServiceError.serverError(let message, let httpCode) {
                    vc.alert(title: "エラー", message: "登録中にエラーが発生しました。\n\nメッセージ: \(message)\nエラーコード: HTTP-\(httpCode)")
                } catch {
                    vc.alert(title: "エラー", message: "登録中にエラーが発生しました。\n\n\(error.localizedDescription)")
                }
            }
        }
    }
}
