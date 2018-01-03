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

class OtherMenuSettingsTableViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.form +++ Section()
            <<< PushStringRow() { row in
                row.title = "ストリーミング自動接続"
                row.userDefaultsConnect(.streamingAutoConnect, map: [
                    "no": "しない",
                    "wifi": "WiFi接続時のみ",
                    "always": "常に接続",
                    ])
            }
            <<< TextRow() { row in
                row.title = "新規連携時のvia"
                row.placeholder = "iMast"
                row.userDefaultsConnect(.newAccountVia)
            }
            <<< SwitchRow() { row in
                row.title = "フォロー関係を以前の表記にする"
                row.userDefaultsConnect(.followRelationshipsOld)
        }
        self.form +++ Section("投稿設定")
            <<< SwitchRow() { row in
                row.title = "投稿時にメディアURL追加"
                row.userDefaultsConnect(.appendMediaUrl)
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
