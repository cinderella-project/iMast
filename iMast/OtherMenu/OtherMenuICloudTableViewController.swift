//
//  OtherMenuICloudTableViewController.swift
//  iMast
//
//  Created by user on 2017/12/29.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON

class OtherMenuICloudTableViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        guard let icloudUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            return
        }
        try? FileManager.default.startDownloadingUbiquitousItem(at: icloudUrl)
        let indexJSONUrl = icloudUrl.appendingPathComponent("index.json")
        self.form +++ ButtonRow { row in
            row.title = "今すぐバックアップ"
        }.onCellSelection { _, _  in
            let randomString = genRandomString().trim(0, 32)
            var indexJSON = JSON(parseJSON: (try? String(contentsOf: indexJSONUrl)) ?? "{\"sqlite\": []}")
            let newBackupData: [String: Any] = [
                "file": randomString,
                "device": "test",
                "device_name": "test",
                "unix": Int(Date().timeIntervalSince1970),
                "name": "backup_test"
            ]
            var nowBackupData = indexJSON["sqlite"].arrayValue
            nowBackupData.append(JSON(newBackupData))
            indexJSON["sqlite"] = JSON(nowBackupData)
            print(indexJSON)
            try? FileManager.default.copyItem(at: getFileURL(), to: icloudUrl.appendingPathComponent("backup_\(randomString).sqlite"))
            guard let dumpJSON = indexJSON.rawString() else {
                return
            }
            try? dumpJSON.write(to: indexJSONUrl, atomically: true, encoding: String.Encoding.utf8)
        }
        self.form +++ MultivaluedSection(multivaluedOptions: [], header: "バックアップ一覧", footer: "") { section in
            section <<< LabelRow { row in
                row.title = "backup_1"
            }
            guard let icloudUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
                return
            }
            var indexJSON = JSON(parseJSON: (try? String(contentsOf: indexJSONUrl)) ?? "{\"sqlite\": []}")
            indexJSON["sqlite"].arrayValue.forEach { json in
                section <<< LabelRow { row in
                    row.title = json["name"].stringValue
                    }.onCellSelection {
                        _, _ in
                        try? FileManager.default.removeItem(at: getFileURL())
                        try? FileManager.default.copyItem(at: icloudUrl.appendingPathComponent("backup_\(json["file"].stringValue).sqlite"), to: getFileURL())
                        exit(0)
                }
            }
            print(icloudUrl.path)
        }
        self.title = "iCloud"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
