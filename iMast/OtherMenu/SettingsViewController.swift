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

class SettingsViewController: FormViewController {

    // swiftlint:disable function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()
        self.form +++ self.getGeneralSection()
        if #available(iOS 10.0, *), let section = self.form.allSections.last {
            section <<< ButtonRow { row in
                row.title = "プッシュ通知"
                row.onCellSelection { cell, row in
                    OtherMenuPushSettingsTableViewController.openRequest(vc: self)
                }
            }
        }
        self.form +++ self.getComposeSection()
        self.form +++ self.getPostInfoSection()
        self.form +++ self.getTimelineSection()
        if #available(iOS 10.0, *) {
            self.form +++ Section("ウィジェット")
                <<< LabelRow { row in
                    row.title = "投稿フォーマット"
                }
                <<< TextAreaRow { row in
                    row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                    row.placeholder = "ID: {clipboard}\n#何らかのハッシュタグとか"
                    row.userDefaultsConnect(.widgetFormat)
                }
                <<< TextRow { row in
                    row.title = "フィルタ"
                    row.placeholder = "[0-9]{7}"
                    row.userDefaultsConnect(.widgetFilter)
            }
        } else {
            self.form +++ Section("ウィジェット")
                <<< LabelRow { row in
                    row.title = "ウィジェットはiOS10以上でないと利用できません。"
            }
        }
        self.form +++ Section("共有")
            <<< SwitchRow { row in
                row.title = "Twitterにトラッキングさせない"
                row.userDefaultsConnect(.shareNoTwitterTracking)
            }
            <<< SwitchRow { row in
                row.title = "GPMを共有する時にNowPlayingフォーマットを使用"
                row.userDefaultsConnect(.usingNowplayingFormatInShareGooglePlayMusicUrl)
                row.cellStyle = .subtitle
                row.cellUpdate { cell, row in
                    cell.textLabel?.numberOfLines = 0
                    cell.detailTextLabel?.text = "GPMのURLを共有しようとする際に https://play.google.com との通信が発生します。また、この機能は非公式であり、問題が発生しても開発者は責任を負いません。自己責任でお使いください。"
                    cell.detailTextLabel?.numberOfLines = 0
                }
        }
        self.form +++ self.getImageCacheSection()
        self.form +++ Section("実験的な要素")
            <<< SwitchRow { row in
                row.title = "新しいHTMLパーサーを使う"
                row.userDefaultsConnect(.newHtmlParser)
            }
            <<< SwitchRow { row in
                row.title = "通知タブの無限スクロール"
                row.userDefaultsConnect(.notifyTabInfiniteScroll)
            }
        self.title = "設定"
        let callhelpitem = UIBarButtonItem(title: "ヘルプ", style: .plain) { _ in
            let safari = SFSafariViewController(url: URL(string: "https://cinderella-project.github.io/iMast/help/settings.html")!)
            self.present(safari, animated: true, completion: nil)
        }
        self.navigationItem.rightBarButtonItems = [
            callhelpitem,
        ]
    }

    func getGeneralSection() -> Section {
        let section = Section()
        section <<< PushStringRow { row in
            row.title = "ストリーミング自動接続"
            row.userDefaultsConnect(.streamingAutoConnect, map: [
                ("no", "しない"),
                ("wifi", "WiFi接続時のみ"),
                ("always", "常に接続"),
                ])
        }
        section <<< TextRow { row in
            row.title = "新規連携時のvia"
            row.placeholder = "iMast"
            row.userDefaultsConnect(.newAccountVia, ifEmptyUseDefaultValue: true)
        }
        section <<< SwitchRow { row in
            row.title = "フォロー関係を以前の表記にする"
            row.userDefaultsConnect(.followRelationshipsOld)
        }
        return section
    }
    
    func getComposeSection() -> Section {
        let section = Section("投稿設定")
        section <<< SwitchRow { row in
            row.title = "投稿時にメディアURL追加"
            row.userDefaultsConnect(.appendMediaUrl)
        }
        section <<< PushStringRow { row in
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
        section <<< LabelRow { row in
            row.title = "nowplayingのフォーマット"
        }
        section <<< TextAreaRow { row in
            row.placeholder = "#nowplaying {title} - {artist} ({albumTitle})"
            row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
            row.userDefaultsConnect(.nowplayingFormat)
        }
        section <<< SwitchRow { row in
            row.title = "デフォルト公開範囲を利用"
            row.userDefaultsConnect(.usingDefaultVisibility)
        }
        return section
    }
    
    func getPostInfoSection() -> Section {
        let section = Section("投稿詳細")
        section <<< SwitchRow { row in
            row.title = "トゥート削除をておくれにする"
            row.userDefaultsConnect(.deleteTootTeokure)
        }
        
        return section
    }
    
    func getTimelineSection() -> Section {
        let section = Section("タイムライン")
        section <<< SliderRow { row in
            row.title = "ユーザー名の文字の大きさ"
            row.cellSetup { cell, row in
                cell.slider.maximumValue = 20
                cell.slider.minimumValue = 10
            }
            row.steps = 20
            row.userDefaultsConnect(.timelineUsernameFontsize)
        }
        section <<< SliderRow { row in
            row.title = "本文の文字の大きさ"
            row.cellSetup { cell, row in
                cell.slider.maximumValue = 20
                cell.slider.minimumValue = 10
            }
            row.steps = 20
            row.userDefaultsConnect(.timelineTextFontsize)
        }
        section <<< SwitchRow { row in
            row.title = "本文を太字で表示"
            row.userDefaultsConnect(.timelineTextBold)
        }
        section <<< SliderRow { row in
            row.title = "アイコンの大きさ"
            row.cellSetup { cell, row in
                cell.slider.maximumValue = 72
                cell.slider.minimumValue = 24
            }
            row.steps = (72-24)*2
            row.userDefaultsConnect(.timelineIconSize)
        }
        section <<< SwitchRow { row in
            row.title = "公開範囲を絵文字で表示"
            row.userDefaultsConnect(.visibilityEmoji)
        }
        section <<< SwitchRow { row in
            row.title = "inReplyToの有無を絵文字で表示"
            row.userDefaultsConnect(.inReplyToEmoji)
        }
        section <<< SliderRow { row in
            row.title = "サムネイルの高さ"
            row.cellSetup { cell, row in
                cell.slider.maximumValue = 100
                cell.slider.minimumValue = 0
            }
            row.steps = 100/5
            row.userDefaultsConnect(.thumbnailHeight)
        }
        section <<< SwitchRow { row in
            row.title = "WebMをVLCで開く"
            row.userDefaultsConnect(.webmVlcOpen)
        }
        section <<< SwitchRow { row in
            row.title = "動画再生にAVPlayerを利用"
            row.userDefaultsConnect(.useAVPlayer)
        }
        section <<< SwitchRow { row in
            row.title = "Universal Linksを優先"
            row.userDefaultsConnect(.useUniversalLink)
        }
        section <<< SwitchRow { row in
            row.title = "ぬるぬるモード(再起動後反映)"
            row.userDefaultsConnect(.timelineNurunuruMode)
        }
        section <<< SliderRow { row in
            row.title = "ピン留めトゥートの行数制限"
            row.userDefaultsConnect(.pinnedTootLinesLimit)
            row.steps = 10
            row.displayValueFor = { ($0 ?? 0.0) == 0 ? "無制限" : "\(Int($0 ?? 0))行" }
        }.cellSetup { cell, row in
            cell.slider.maximumValue = 10
            cell.slider.minimumValue = 0
        }
        section <<< SwitchRow { row in
            row.title = "でかい投稿ボタンを表示"
            row.userDefaultsConnect(.postFabEnabled)
        }
        section <<< PushRow<PostFabLocation> { row in
            row.title = "でかい投稿ボタンの場所"
            row.options = PostFabLocation.allCases
            row.userDefaultsConnect(.postFabLocation)
        }
        section <<< SwitchRow { row in
            row.title = "acctのホスト名を略す"
            row.userDefaultsConnect(.acctAbbr)
            row.cellStyle = .subtitle
            row.cellUpdate { cell, row in
                cell.detailTextLabel?.text = "例: m6n.s4l"
            }
        }
        return section
    }
    
    func getImageCacheSection() -> Section {
        let section = Section("画像キャッシュ")
        section <<< TextRow { row in
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
        section <<< ButtonRow { row in
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
        return section
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
