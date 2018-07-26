//
//  OtherMenuSettingsTableViewController.swift
//  iMast
//
//  Created by user on 2017/12/29.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import Eureka
import ActionClosurable
import SafariServices
import SDWebImage
import Alamofire
import SwiftyJSON

class OtherMenuSettingsTableViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let generalSettings = Section()
        generalSettings <<< PushStringRow() { row in
            row.title = "ストリーミング自動接続"
            row.userDefaultsConnect(.streamingAutoConnect, map: [
                ("no", "しない"),
                ("wifi", "WiFi接続時のみ"),
                ("always", "常に接続"),
            ])
        }
        generalSettings <<< TextRow() { row in
            row.title = "新規連携時のvia"
            row.placeholder = "iMast"
            row.userDefaultsConnect(.newAccountVia)
        }
        generalSettings <<< SwitchRow() { row in
                row.title = "フォロー関係を以前の表記にする"
                row.userDefaultsConnect(.followRelationshipsOld)
        }
        self.form +++ generalSettings
        if #available(iOS 10.0, *), let section = self.form.allSections.last {
            section <<< ButtonRow() { row in
                row.title = "プッシュ通知"
                row.onCellSelection { cell, row in
                    OtherMenuPushSettingsTableViewController.openRequest(vc: self)
                }
            }
        }
        self.form +++ Section("投稿設定")
            <<< SwitchRow() { row in
                row.title = "投稿時にメディアURL追加"
                row.userDefaultsConnect(.appendMediaUrl)
            }
            <<< PushStringRow() { row in
                row.title = "画像の自動リサイズ"
                let sentakusi = [ // 自動リサイズの選択肢
                    0,
                    1920,
                    1280,
                    1000,
                    750,
                    500,
                ]
                let smap = sentakusi.map { px -> (Int, String) in
                    let str = px == 0 ? "自動でリサイズしない" : "\(px)px以下にリサイズ"
                    return (px, str)
                }
                row.userDefaultsConnect(.autoResizeSize, map: smap)
            }
            <<< LabelRow() { row in
                row.title = "nowplayingのフォーマット"
            }
            <<< TextAreaRow() { row in
                row.placeholder = "#nowplaying {title} - {artist} ({albumTitle})"
                row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                row.userDefaultsConnect(.nowplayingFormat)
            }
            <<< SwitchRow() { row in
                row.title = "デフォルト公開範囲を利用"
                row.userDefaultsConnect(.usingDefaultVisibility)
        }
        self.form +++ Section("投稿詳細")
            <<< SwitchRow() { row in
                row.title = "トゥート削除をておくれにする"
                row.userDefaultsConnect(.deleteTootTeokure)
        }
        self.form +++ Section("タイムライン")
            <<< SliderRow() { row in
                row.title = "ユーザー名の文字の大きさ"
                row.maximumValue = 20
                row.minimumValue = 10
                row.steps = 20
                row.userDefaultsConnect(.timelineUsernameFontsize)
            }
            <<< SliderRow() { row in
                row.title = "本文の文字の大きさ"
                row.maximumValue = 20
                row.minimumValue = 10
                row.steps = 20
                row.userDefaultsConnect(.timelineTextFontsize)
            }
            <<< SwitchRow() { row in
                row.title = "本文を太字で表示"
                row.userDefaultsConnect(.timelineTextBold)
            }
            <<< SliderRow() { row in
                row.title = "アイコンの大きさ"
                row.maximumValue = 72
                row.minimumValue = 24
                row.steps = (72-24)*2
                row.userDefaultsConnect(.timelineIconSize)
            }
            <<< SwitchRow() { row in
                row.title = "公開範囲を絵文字で表示"
                row.userDefaultsConnect(.visibilityEmoji)
            }
            <<< SliderRow() { row in
                row.title = "サムネイルの高さ"
                row.maximumValue = 100
                row.minimumValue = 0
                row.steps = 100/5
                row.userDefaultsConnect(.thumbnailHeight)
            }
            <<< SwitchRow() { row in
                row.title = "WebMをVLCで開く"
                row.userDefaultsConnect(.webmVlcOpen)
            }
            <<< SwitchRow() { row in
                row.title = "ぬるぬるモード(再起動後反映)"
                row.userDefaultsConnect(.timelineNurunuruMode)
            }
            <<< SliderRow() { row in
                row.title = "ピン留めトゥートの行数制限"
                row.userDefaultsConnect(.pinnedTootLinesLimit)
                row.minimumValue = 0
                row.maximumValue = 10
                row.steps = 10
                row.displayValueFor = { ($0 ?? 0.0) == 0 ? "無制限" : "\(Int($0 ?? 0))行" }
        }
        if #available(iOS 10.0, *) {
            self.form +++ Section("ウィジェット")
                <<< LabelRow() { row in
                    row.title = "投稿フォーマット"
                }
                <<< TextAreaRow() { row in
                    row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                    row.placeholder = "ID: {clipboard}\n#何らかのハッシュタグとか"
                    row.userDefaultsConnect(.widgetFormat)
                }
                <<< TextRow() { row in
                    row.title = "フィルタ"
                    row.placeholder = "[0-9]{7}"
                    row.userDefaultsConnect(.widgetFilter)
            }
        } else {
            self.form +++ Section("ウィジェット")
                <<< LabelRow() { row in
                    row.title = "ウィジェットはiOS10以上でないと利用できません。"
            }
        }
        self.form +++ Section("共有")
            <<< SwitchRow() { row in
                row.title = "Twitterにトラッキングさせない"
                row.userDefaultsConnect(.shareNoTwitterTracking)
        }
        self.form +++ Section("画像キャッシュ")
            <<< TextRow() { row in
                row.title = "キャッシュの容量"
                row.disabled = true
                let size = UInt64(SDWebImageManager.shared().imageCache?.getSize() ?? 0)
                if size < 10_000 {
                    row.value = size.description + "B"
                } else if size < 10_000_000 {
                    row.value = (size / 1000).description + "KB"
                } else if size < 10_000_000_000 {
                    row.value = (size / 1000_000).description + "MB"
                } else {
                    row.value = (size / 1000_000_000).description + "GB"
                }
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = ","
                formatter.groupingSize = 3
                if size >= 10_000 {
                    row.value = (row.value ?? "") + " ("+formatter.string(from: size as NSNumber)!+"bytes)"
                }
                
            }
            <<< ButtonRow() { row in
                row.title = "ストレージ上のキャッシュを削除"
            }.onCellSelection { (cell, row) in
                let size = SDWebImageManager.shared().imageCache?.getSize() ?? 0
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = ","
                formatter.groupingSize = 3
                let sizeStr = formatter.string(from: size as NSNumber) ?? "0"
                let count = SDWebImageManager.shared().imageCache?.getDiskCount() ?? 0
                self.confirm(title: "キャッシュ削除の確認", message: "ストレージ上のキャッシュ(\(sizeStr)bytes, \(count)個)のキャッシュを削除します。よろしいですか?", okButtonMessage: "OK").then { result in
                    if !result {
                        return
                    }
                    SDWebImageManager.shared().imageCache?.clearDisk(onCompletion: {
                        self.alert(title: "キャッシュ削除完了", message: "キャッシュの削除が終了しました。")
                    })
                }
            }
        self.title = "設定"
        let callhelpitem = UIBarButtonItem(title: "ヘルプ", style: .plain) { _ in
            let safari = SFSafariViewController(url: URL(string: "https://cinderella-project.github.io/iMast/help/settings.html")!)
            self.present(safari, animated: true, completion: nil)
        }
        self.navigationItem.rightBarButtonItems = [
            callhelpitem
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
