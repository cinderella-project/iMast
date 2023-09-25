// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Localizable {
  }
  internal enum Menu {
    /// %@のヘルプ
    internal static func help(_ p1: Any) -> String {
      return L10n.tr("Menu", "%@ Help", String(describing: p1))
    }
    /// %@について
    internal static func about(_ p1: Any) -> String {
      return L10n.tr("Menu", "About %@", String(describing: p1))
    }
    /// すべてを手前に移動
    internal static let bringAllToFront = L10n.tr("Menu", "Bring All to Front")
    /// アップデートを確認…
    internal static let checkForUpdates = L10n.tr("Menu", "Check for Updates…")
    /// 閉じる
    internal static let close = L10n.tr("Menu", "Close")
    /// コピー
    internal static let copy = L10n.tr("Menu", "Copy")
    /// ツールバーをカスタマイズ…
    internal static let customizeToolbar = L10n.tr("Menu", "Customize Toolbar…")
    /// カット
    internal static let cut = L10n.tr("Menu", "Cut")
    /// 削除
    internal static let delete = L10n.tr("Menu", "Delete")
    /// 編集
    internal static let edit = L10n.tr("Menu", "Edit")
    /// ファイル
    internal static let file = L10n.tr("Menu", "File")
    /// ヘルプ
    internal static let help = L10n.tr("Menu", "Help")
    /// %@を非表示
    internal static func hide(_ p1: Any) -> String {
      return L10n.tr("Menu", "Hide %@", String(describing: p1))
    }
    /// ほかを非表示
    internal static let hideOthers = L10n.tr("Menu", "Hide Others")
    /// プライベートな投稿を非表示
    internal static let hidePrivatePosts = L10n.tr("Menu", "Hide Private Posts")
    /// しまう
    internal static let minimize = L10n.tr("Menu", "Minimize")
    /// 新規
    internal static let new = L10n.tr("Menu", "New")
    /// 新規タブ
    internal static let newTab = L10n.tr("Menu", "New Tab")
    /// 新規ウインドウ
    internal static let newWindow = L10n.tr("Menu", "New Window")
    /// ペースト
    internal static let paste = L10n.tr("Menu", "Paste")
    /// 投稿
    internal static let post = L10n.tr("Menu", "Post")
    /// 環境設定…
    internal static let preferences = L10n.tr("Menu", "Preferences…")
    /// %@を終了
    internal static func quit(_ p1: Any) -> String {
      return L10n.tr("Menu", "Quit %@", String(describing: p1))
    }
    /// すべてを選択
    internal static let selectAll = L10n.tr("Menu", "Select All")
    /// 投稿を送信
    internal static let sendPost = L10n.tr("Menu", "Send Post")
    /// サービス
    internal static let services = L10n.tr("Menu", "Services")
    /// すべてを表示
    internal static let showAll = L10n.tr("Menu", "Show All")
    /// サイドバーを表示
    internal static let showSidebar = L10n.tr("Menu", "Show Sidebar")
    /// ツールバーを表示
    internal static let showToolbar = L10n.tr("Menu", "Show Toolbar")
    /// 表示
    internal static let view = L10n.tr("Menu", "View")
    /// ウインドウ
    internal static let window = L10n.tr("Menu", "Window")
    /// 拡大/縮小
    internal static let zoom = L10n.tr("Menu", "Zoom")
  }
  internal enum Timeline {
    /// 連合
    internal static let federated = L10n.tr("Timeline", "Federated")
    /// ホーム
    internal static let home = L10n.tr("Timeline", "Home")
    /// ローカル
    internal static let local = L10n.tr("Timeline", "Local")
    /// 新規投稿
    internal static let newPost = L10n.tr("Timeline", "New Post")
    /// タイムライン切替
    internal static let switchTimelines = L10n.tr("Timeline", "Switch Timelines")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
