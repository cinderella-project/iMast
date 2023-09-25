// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum CoreL10n {
  /// キャンセル
  public static let cancel = CoreL10n.tr("Core", "cancel")

  public enum Error {
    /// (不明)
    public static let failedToDecodeAsUTF8 = CoreL10n.tr("Core", "error.failedToDecodeAsUTF8")
    public enum Api {
      /// サーバーからエラーが返却されました。
      /// 
      /// %1$@
      /// (HTTP %2$d)
      public static func text(_ p1: Any, _ p2: Int) -> String {
        return CoreL10n.tr("Core", "error.api.text", String(describing: p1), p2)
      }
      /// APIエラー
      public static let title = CoreL10n.tr("Core", "error.api.title")
    }
    public enum Http {
      /// サーバーから予期せぬ内容が返却されました。
      /// (HTTP %1$d)
      /// 
      /// %2$@
      public static func text(_ p1: Int, _ p2: Any) -> String {
        return CoreL10n.tr("Core", "error.http.text", p1, String(describing: p2))
      }
      /// サーバーエラー
      public static let title = CoreL10n.tr("Core", "error.http.title")
    }
  }

  public enum ErrorAlert {
    /// エラーが発生しました。
    /// 
    /// %@
    public static func message(_ p1: Any) -> String {
      return CoreL10n.tr("Core", "errorAlert.message", String(describing: p1))
    }
    /// 詳しい情報を見る
    public static let moreInfo = CoreL10n.tr("Core", "errorAlert.moreInfo")
    /// エラー
    public static let title = CoreL10n.tr("Core", "errorAlert.title")
  }

  public enum ErrorMoreInfo {
    /// エラー詳細
    public static let title = CoreL10n.tr("Core", "errorMoreInfo.title")
  }

  public enum PostFab {
    public enum Locations {
      /// 中央下
      public static let centerBottom = CoreL10n.tr("Core", "postFab.locations.centerBottom")
      /// 左下
      public static let leftBottom = CoreL10n.tr("Core", "postFab.locations.leftBottom")
      /// 左中央
      public static let leftCenter = CoreL10n.tr("Core", "postFab.locations.leftCenter")
      /// 右下
      public static let rightBottom = CoreL10n.tr("Core", "postFab.locations.rightBottom")
      /// 右中央
      public static let rightCenter = CoreL10n.tr("Core", "postFab.locations.rightCenter")
    }
  }

  public enum Visibility {
    /// 公開範囲
    public static let title = CoreL10n.tr("Core", "visibility.title")
    public enum Title {
      /// 指定した相手のみ
      public static let direct = CoreL10n.tr("Core", "visibility.title.direct")
      /// フォロワーのみ
      public static let `private` = CoreL10n.tr("Core", "visibility.title.private")
      /// 公開
      public static let `public` = CoreL10n.tr("Core", "visibility.title.public")
      /// 未収載
      public static let unlisted = CoreL10n.tr("Core", "visibility.title.unlisted")
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
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
