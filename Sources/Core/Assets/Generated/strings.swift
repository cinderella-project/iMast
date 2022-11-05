// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum CoreL10n {
  /// キャンセル
  public static let cancel = CoreL10n.tr("Localizable", "cancel")

  public enum Error {
    /// (不明)
    public static let failedToDecodeAsUTF8 = CoreL10n.tr("Localizable", "error.failedToDecodeAsUTF8")
  }

  public enum ErrorAlert {
    /// エラーが発生しました。\n\n%@
    public static func message(_ p1: Any) -> String {
      return CoreL10n.tr("Localizable", "errorAlert.message", String(describing: p1))
    }
    /// 詳しい情報を見る
    public static let moreInfo = CoreL10n.tr("Localizable", "errorAlert.moreInfo")
    /// エラー
    public static let title = CoreL10n.tr("Localizable", "errorAlert.title")
  }

  public enum ErrorMoreInfo {
    /// エラー詳細
    public static let title = CoreL10n.tr("Localizable", "errorMoreInfo.title")
  }

  public enum PostFab {
    public enum Locations {
      /// 中央下
      public static let centerBottom = CoreL10n.tr("Localizable", "postFab.locations.centerBottom")
      /// 左下
      public static let leftBottom = CoreL10n.tr("Localizable", "postFab.locations.leftBottom")
      /// 左中央
      public static let leftCenter = CoreL10n.tr("Localizable", "postFab.locations.leftCenter")
      /// 右下
      public static let rightBottom = CoreL10n.tr("Localizable", "postFab.locations.rightBottom")
      /// 右中央
      public static let rightCenter = CoreL10n.tr("Localizable", "postFab.locations.rightCenter")
    }
  }

  public enum Visibility {
    /// 公開範囲
    public static let title = CoreL10n.tr("Localizable", "visibility.title")
    public enum Description {
      /// メンションを飛ばした対象の人にのみ見れます
      public static let direct = CoreL10n.tr("Localizable", "visibility.description.direct")
      /// あなたのフォロワーと、メンションを飛ばした対象の人のみ見れます
      public static let `private` = CoreL10n.tr("Localizable", "visibility.description.private")
      /// LTLやフォロワーのHTL等に流れます
      public static let `public` = CoreL10n.tr("Localizable", "visibility.description.public")
      /// LTLやハッシュタグ検索には出ません
      public static let unlisted = CoreL10n.tr("Localizable", "visibility.description.unlisted")
    }
    public enum Title {
      /// 指定した相手のみ
      public static let direct = CoreL10n.tr("Localizable", "visibility.title.direct")
      /// フォロワーのみ
      public static let `private` = CoreL10n.tr("Localizable", "visibility.title.private")
      /// 公開
      public static let `public` = CoreL10n.tr("Localizable", "visibility.title.public")
      /// 未収載
      public static let unlisted = CoreL10n.tr("Localizable", "visibility.title.unlisted")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension CoreL10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle = Bundle(for: BundleToken.self)
}
// swiftlint:enable convenience_type
