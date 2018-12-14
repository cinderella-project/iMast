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

class OtherMenuViewController: FormViewController {

    var nowAccount: MastodonUserToken?

    init() {
        super.init(style: .plain)
        self.title = R.string.localizable.tabsOtherTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        nowAccount = MastodonUserToken.getLatestUsed()
        
        let section = Section()
        section <<< ButtonRow { row in
            row.title = R.string.localizable.tabsOtherSwitchActiveAccountTitle()
            row.cellStyle = .subtitle
            row.presentationMode = .show(controllerProvider: .callback(builder: { ChangeActiveAccountViewController() }), onDismiss: nil)
        }.cellSetup { cell, row in
            cell.height = { 44 }
        }.cellUpdate { (cell, row) in
            cell.detailTextLabel?.text = R.string.localizable.tabsOtherSwitchActiveAccountSubTitle(self.nowAccount?.acct ?? "")
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.tabsOtherMyProfile()
        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }.onCellSelection { cell, row in
            MastodonUserToken.getLatestUsed()!.verifyCredentials().then { account in
                print(account)
                let newVC = openUserProfile(user: account)
                self.navigationController?.pushViewController(newVC, animated: true)
            }.catch { error in
                    print(error)
            }
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.tabsOtherLists()
        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }.onCellSelection { cell, row in
            // TODO: ここの下限バージョンの処理をあとで共通化する
            MastodonUserToken.getLatestUsed()!.getIntVersion().then { version in
                if version < MastodonVersionStringToInt("2.1.0rc1") {
                    self.alert(title: R.string.localizable.errorTitle(), message: R.string.localizable.errorRequiredNewerMastodon("2.1.0rc1"))
                    return
                }
                MastodonUserToken.getLatestUsed()!.lists().then({ lists in
                    let vc = ListsTableViewController()
                    vc.lists = lists
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.tabsOtherSettings()
            row.presentationMode = .show(controllerProvider: .callback(builder: { SettingsViewController() }), onDismiss: nil)
        }
        
        section <<< ButtonRow { row in
            row.title = "Siri Shortcuts"
        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = nil
        }.onCellSelection { (cell, row) in
            if #available(iOS 12.0, *) {
                let vc = CreateSiriShortcutsViewController()
                vc.title = cell.textLabel?.text
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                // Fallback on earlier versions
                self.alert(title: R.string.localizable.errorTitle(), message: R.string.localizable.errorRequiredNewerOS(12.0))
            }
        }
        
        section <<< ButtonRow { row in
            row.title = R.string.localizable.tabsOtherHelpAndFeedback()
            row.presentationMode = .show(controllerProvider: .callback(builder: { OtherMenuHelpAndFeedbackViewController() }), onDismiss: nil)
        }
        
        self.form +++ section
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchButtonTapped(_ sender: Any) {
        self.navigationController?.pushViewController(SearchViewController(), animated: true)
    }
}
