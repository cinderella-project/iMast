//
//  OtherMenuPushSettingsChangeSoundViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/01/01.
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

import UIKit
import Eureka

class OtherMenuPushSettingsChangeSoundViewController: FormViewController {
    var lastType: String = "boost"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form.append {
            Section(header: "ブースト") {
                SwitchRow { row in
                    row.title = "有効"
                    row.userDefaultsConnect(.useCustomBoostSound)
                }
                ButtonRow { row in
                    row.title = "ファイル選択"
                    row.presentationMode = .presentModally(
                        controllerProvider: .callback {
                            self.lastType = "boost"
                            return self.getPicker()
                        },
                        onDismiss: nil
                    )
                }
                ButtonRow { row in
                    row.title = "再生してみる"
                    row.onCellSelection { cell, row in
                        self.playSound()
                    }
                }
            }
        }
        form.append {
            Section(header: "ふぁぼ") {
                SwitchRow { row in
                    row.title = "有効"
                    row.userDefaultsConnect(.useCustomFavouriteSound)
                }
                ButtonRow { row in
                    row.title = "ファイル選択"
                    row.presentationMode = .presentModally(
                        controllerProvider: .callback {
                            self.lastType = "favourite"
                            return self.getPicker()
                        },
                        onDismiss: nil
                    )
                }
                ButtonRow { row in
                    row.title = "再生してみる"
                    row.onCellSelection { cell, row in
                        self.playSound()
                    }
                }
            }
        }
    }
    
    func getPicker() -> UIDocumentPickerViewController {
        let vc = UIDocumentPickerViewController(documentTypes: ["com.apple.coreaudio-format"], in: .import)
        vc.delegate = self
        return vc
    }
    
    func playSound() {
        print("play sound")
    }
}

extension OtherMenuPushSettingsChangeSoundViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        let destDirUrl = appGroupFileUrl
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Sounds", isDirectory: true)
        try! FileManager.default.createDirectory(at: destDirUrl, withIntermediateDirectories: true)
        let destUrl = destDirUrl
            .appendingPathComponent("custom-\(lastType).caf")
        print(destUrl.absoluteString)
        try? FileManager.default.removeItem(at: destUrl)
        try! FileManager.default.copyItem(at: url, to: destUrl)
        url.stopAccessingSecurityScopedResource()
    }
}
