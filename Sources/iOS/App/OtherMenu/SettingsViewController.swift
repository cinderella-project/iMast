//
//  OtherMenuSettingsTableViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/12/29.
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
import Eureka
import EurekaFormBuilder
import SafariServices
import SDWebImage
import Alamofire
import SwiftyJSON

class SettingsViewController: FormViewController {

    // swiftlint:disable function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()
        form.append {
            getGeneralSection()
            getComposeSection()
            getNowPlayingSection()
            getPostInfoSection()
            getTimelineAppearanceSection()
            getTimelineSection()
            getWidgetSection()
            getShareSection()
            getImageCacheSection()
            getExperimentalSection()
        }
        self.title = "設定"
        self.navigationItem.rightBarButtonItem = .init(title: "ヘルプ", style: .plain, target: self, action: #selector(openHelp))
    }

    func getGeneralSection() -> Section {
        return Section {
            PushStringRow { row in
                row.title = "ストリーミング自動接続"
                row.userDefaultsConnect(.streamingAutoConnect, map: [
                    ("no", "しない"),
                    ("wifi", "WiFi接続時のみ"),
                    ("always", "常に接続"),
                ])
            }
            TextRow { row in
                row.title = "新規連携時のvia"
                row.placeholder = "iMast"
                row.userDefaultsConnect(.newAccountVia, ifEmptyUseDefaultValue: true)
            }
            SwitchRow { row in
                row.title = "フォロー関係を以前の表記にする"
                row.userDefaultsConnect(.followRelationshipsOld)
            }
            ButtonRow { row in
                row.title = "プッシュ通知"
                row.onCellSelection { cell, row in
                    OtherMenuPushSettingsTableViewController.openRequest(vc: self)
                }
            }
        }
    }
    
    func getComposeSection() -> Section {
        return Section(header: "投稿設定") {
            SwitchRow { row in
                row.title = "投稿時にメディアURL追加"
                row.userDefaultsConnect(.appendMediaUrl)
            }
            PushStringRow { row in
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
            SwitchRow { row in
                row.title = "デフォルト公開範囲を利用"
                row.userDefaultsConnect(.usingDefaultVisibility)
            }
        }
    }
    
    func getNowPlayingSection() -> Section {
        return Section(header: "NowPlaying設定") {
            LabelRow { row in
                row.title = "フォーマット"
            }
            TextAreaRow { row in
                row.placeholder = "#NowPlaying {title} - {artist} ({albumTitle})"
                row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                row.userDefaultsConnect(.nowplayingFormat)
            }
            SwitchRow { row in
                row.title = "Apple MusicならURLを付ける (できれば)"
                row.userDefaultsConnect(.nowplayingAddAppleMusicUrl)
            }
        }
    }
    
    func getPostInfoSection() -> Section {
        return Section(header: "投稿詳細") {
            SwitchRow { row in
                row.title = "トゥート削除をておくれにする"
                row.userDefaultsConnect(.deleteTootTeokure)
            }
        }
    }
    
    func getTimelineAppearanceSection() -> Section {
        return Section(header: "タイムラインの外観") {
            SliderRow { row in
                row.title = "ユーザー名の文字の大きさ"
                row.cellSetup { cell, row in
                    cell.slider.maximumValue = 20
                    cell.slider.minimumValue = 10
                }
                row.steps = 20
                row.userDefaultsConnect(.timelineUsernameFontsize)
            }
            SliderRow { row in
                row.title = "本文の文字の大きさ"
                row.cellSetup { cell, row in
                    cell.slider.maximumValue = 20
                    cell.slider.minimumValue = 10
                }
                row.steps = 20
                row.userDefaultsConnect(.timelineTextFontsize)
            }
            SwitchRow { row in
                row.title = "本文を太字で表示"
                row.userDefaultsConnect(.timelineTextBold)
            }
            SliderRow { row in
                row.title = "アイコンの大きさ"
                row.cellSetup { cell, row in
                    cell.slider.maximumValue = 72
                    cell.slider.minimumValue = 24
                }
                row.steps = (72-24)*2
                row.userDefaultsConnect(.timelineIconSize)
            }
            SwitchRow { row in
                row.title = "公開範囲を絵文字で表示"
                row.userDefaultsConnect(.visibilityEmoji)
            }
            SwitchRow { row in
                row.title = "inReplyToの有無を絵文字で表示"
                row.userDefaultsConnect(.inReplyToEmoji)
            }
            SliderRow { row in
                row.title = "サムネイルの高さ"
                row.cellSetup { cell, row in
                    cell.slider.maximumValue = 100
                    cell.slider.minimumValue = 0
                }
                row.steps = 100/5
                row.userDefaultsConnect(.thumbnailHeight)
            }
            SwitchRow { row in
                row.title = "ぬるぬるモード(再起動後反映)"
                row.userDefaultsConnect(.timelineNurunuruMode)
            }
            SliderRow { row in
                row.title = "ピン留めトゥートの行数制限"
                row.userDefaultsConnect(.pinnedTootLinesLimit)
                row.steps = 10
                row.displayValueFor = { ($0 ?? 0.0) == 0 ? "無制限" : "\(Int($0 ?? 0))行" }
                row.cellSetup { cell, row in
                    cell.slider.maximumValue = 10
                    cell.slider.minimumValue = 0
                }
            }
            SwitchRow { row in
                row.title = "でかい投稿ボタンを表示"
                row.userDefaultsConnect(.postFabEnabled)
            }
            PushRow<PostFabLocation> { row in
                row.title = "でかい投稿ボタンの場所"
                row.options = PostFabLocation.allCases
                row.userDefaultsConnect(.postFabLocation)
            }
            SwitchRow { row in
                row.title = "acctのホスト名を略す"
                row.userDefaultsConnect(.acctAbbr)
                row.cellStyle = .subtitle
                row.cellUpdate { cell, row in
                    cell.detailTextLabel?.text = "例: m6n.s4l"
                }
            }
            SwitchRow { row in
                row.title = "投稿の言語情報を表示時に考慮"
                row.userDefaultsConnect(.usePostLanguageInfo)
            }
        }
    }
    
    func getTimelineSection() -> Section {
        return Section(header: "タイムライン") {
            SwitchRow { row in
                row.title = "WebMをVLCで開く"
                row.userDefaultsConnect(.webmVlcOpen)
            }
            SwitchRow { row in
                row.title = "動画再生にAVPlayerを利用"
                row.userDefaultsConnect(.useAVPlayer)
            }
            SwitchRow { row in
                row.title = "Universal Linksを優先"
                row.userDefaultsConnect(.useUniversalLink)
            }
        }
    }
    
    func getWidgetSection() -> Section {
        return Section(header: "ウィジェット") {
            LabelRow { row in
                row.title = "投稿フォーマット"
            }
            TextAreaRow { row in
                row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 90)
                row.placeholder = "ID: {clipboard}\n#何らかのハッシュタグとか"
                row.userDefaultsConnect(.widgetFormat)
            }
            TextRow { row in
                row.title = "フィルタ"
                row.placeholder = "[0-9]{7}"
                row.userDefaultsConnect(.widgetFilter)
            }
        }
    }
    
    func getShareSection() -> Section {
        return Section(header: "共有") {
            SwitchRow { row in
                row.title = "Twitterにトラッキングさせない"
                row.userDefaultsConnect(.shareNoTwitterTracking)
            }
            SwitchRow { row in
                row.title = "GPMを共有する時にNowPlayingフォーマットを使用"
                row.userDefaultsConnect(.usingNowplayingFormatInShareGooglePlayMusicUrl)
                row.cellStyle = .subtitle
                row.cellUpdate { cell, row in
                    cell.textLabel?.numberOfLines = 0
                    cell.detailTextLabel?.text = "GPMのURLを共有しようとする際に https://play.google.com との通信が発生します。また、この機能は非公式であり、問題が発生しても開発者は責任を負いません。自己責任でお使いください。"
                    cell.detailTextLabel?.numberOfLines = 0
                }
            }
            SwitchRow { row in
                row.title = "共有プレビューで独自実装を利用"
                row.userDefaultsConnect(.useCustomizedSharePreview)
                row.cellStyle = .subtitle
                row.cellUpdate { cell, row in
                    cell.detailTextLabel?.text = "メモリ制限でクラッシュする問題への対策です。\n何らかの不都合が生じた場合はオフにしてみてください。"
                    cell.detailTextLabel?.numberOfLines = 0
                }
            }
        }
    }
    
    func getImageCacheSection() -> Section {
        return Section(header: "画像キャッシュ") {
            TextRow { row in
                row.title = "キャッシュの容量"
                row.disabled = true
                let size = SDImageCache.shared.totalDiskSize()
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
                    row.value = "\(row.value ?? "") (\(formatter.string(from: NSNumber(value: size))!)bytes)"
                }
            }
            ButtonRow { row in
                row.title = "ストレージ上のキャッシュを削除"
                row.onCellSelection { (cell, row) in
                    let size = SDImageCache.shared.totalDiskSize()
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.groupingSeparator = ","
                    formatter.groupingSize = 3
                    let sizeStr = formatter.string(from: size as NSNumber) ?? "0"
                    let count = SDImageCache.shared.totalDiskCount()
                    self.confirm(title: "キャッシュ削除の確認", message: "ストレージ上のキャッシュ(\(sizeStr)bytes, \(count)個)のキャッシュを削除します。よろしいですか?", okButtonMessage: "OK").then { result in
                        if !result {
                            return
                        }
                        SDImageCache.shared.clearDisk {
                            self.alert(title: "キャッシュ削除完了", message: "キャッシュの削除が終了しました。")
                        }
                    }
                }
            }
        }
    }
    
    func getExperimentalSection() -> Section {
        return Section(header: "実験的な要素") {
            SwitchRow { row in
                row.title = "新しいHTMLパーサーを使う"
                row.userDefaultsConnect(.newHtmlParser)
            }
            SwitchRow { row in
                row.title = "通知タブの無限スクロール"
                row.userDefaultsConnect(.notifyTabInfiniteScroll)
            }
            SwitchRow { row in
                row.title = "最初の画面を新しいものに (α)"
                row.userDefaultsConnect(.newFirstScreen)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func openHelp() {
        let safari = SFSafariViewController(url: URL(string: "https://cinderella-project.github.io/iMast/help/settings.html")!)
        self.present(safari, animated: true, completion: nil)
    }
}
