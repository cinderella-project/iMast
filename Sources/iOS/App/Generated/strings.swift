// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Localizable {
    /// ブックマーク
    internal static let bookmarks = L10n.tr("Localizable", "bookmarks")
    /// キャンセル
    internal static let cancel = L10n.tr("Localizable", "cancel")
    /// 使用するアカウントを選択
    internal static let chooseAccount = L10n.tr("Localizable", "chooseAccount")
    /// 接続
    internal static let connect = L10n.tr("Localizable", "connect")
    /// 接続中
    internal static let connected = L10n.tr("Localizable", "connected")
    /// 現在のアカウント: @%@
    internal static func currentAccount(_ p1: Any) -> String {
      return L10n.tr("Localizable", "currentAccount", String(describing: p1))
    }
    /// 切断
    internal static let disconnect = L10n.tr("Localizable", "disconnect")
    /// ふぁぼ一覧
    internal static let favouritesList = L10n.tr("Localizable", "favouritesList")
    /// 取得失敗
    internal static let fetchFailed = L10n.tr("Localizable", "fetchFailed")
    /// ヘルプ / Feedback
    internal static let helpAndFeedback = L10n.tr("Localizable", "helpAndFeedback")
    /// ホームタイムライン
    internal static let homeTimeline = L10n.tr("Localizable", "homeTimeline")
    /// リスト
    internal static let lists = L10n.tr("Localizable", "lists")
    /// ローカルタイムライン
    internal static let localTimeline = L10n.tr("Localizable", "localTimeline")
    /// 自分のプロフィール
    internal static let myProfile = L10n.tr("Localizable", "myProfile")
    /// 接続していません
    internal static let notConnected = L10n.tr("Localizable", "notConnected")
    /// ここまで
    internal static let nothingMore = L10n.tr("Localizable", "nothingMore")
    /// 通知
    internal static let notifications = L10n.tr("Localizable", "notifications")
    /// その他
    internal static let other = L10n.tr("Localizable", "other")
    /// 投稿
    internal static let post = L10n.tr("Localizable", "post")
    /// もっと
    internal static let readmore = L10n.tr("Localizable", "readmore")
    /// 再取得
    internal static let refetch = L10n.tr("Localizable", "refetch")
    /// 設定
    internal static let settings = L10n.tr("Localizable", "settings")
    /// Streaming
    internal static let streaming = L10n.tr("Localizable", "streaming")
    /// 状態: %@
    internal static func streamingStatus(_ p1: Any) -> String {
      return L10n.tr("Localizable", "streamingStatus", String(describing: p1))
    }
    /// アカウントを変更
    internal static let switchActiveAccount = L10n.tr("Localizable", "switchActiveAccount")
    /// %@ に切り替え
    internal static func switchTab(_ p1: Any) -> String {
      return L10n.tr("Localizable", "switchTab", String(describing: p1))
    }
    internal enum AboutThisApp {
      /// 作者
      internal static let author = L10n.tr("Localizable", "aboutThisApp.author")
      /// ほめる
      internal static let praise = L10n.tr("Localizable", "aboutThisApp.praise")
      /// App Store でレビューする
      internal static let reviewInAppStore = L10n.tr("Localizable", "aboutThisApp.reviewInAppStore")
      /// GitHub で Star する
      internal static let starInGitHub = L10n.tr("Localizable", "aboutThisApp.starInGitHub")
      /// このAppについて
      internal static let title = L10n.tr("Localizable", "aboutThisApp.title")
      /// #imast_ios を付けて投稿する
      internal static let tootWithHashtag = L10n.tr("Localizable", "aboutThisApp.tootWithHashtag")
      /// 翻訳してくれた人たち
      internal static let translators = L10n.tr("Localizable", "aboutThisApp.translators")
    }
    internal enum Bunmyaku {
      /// 文脈
      internal static let title = L10n.tr("Localizable", "bunmyaku.title")
    }
    internal enum EditHistory {
      /// 編集履歴
      internal static let title = L10n.tr("Localizable", "editHistory.title")
      internal enum Desc {
        /// オリジナル
        internal static let original = L10n.tr("Localizable", "editHistory.desc.original")
        internal enum Diff {
          /// 添付メディア
          internal static let attachments = L10n.tr("Localizable", "editHistory.desc.diff.attachments")
          /// 本文
          internal static let content = L10n.tr("Localizable", "editHistory.desc.diff.content")
          /// CW警告文
          internal static let cw = L10n.tr("Localizable", "editHistory.desc.diff.cw")
          /// NSFWフラグ
          internal static let sensitive = L10n.tr("Localizable", "editHistory.desc.diff.sensitive")
          /// 変更点: %@
          internal static func template(_ p1: Any) -> String {
            return L10n.tr("Localizable", "editHistory.desc.diff.template", String(describing: p1))
          }
        }
      }
    }
    internal enum EditedWarning {
      /// 最終編集: %@
      internal static func description(_ p1: Any) -> String {
        return L10n.tr("Localizable", "editedWarning.description", String(describing: p1))
      }
      /// この投稿は投稿後に編集されています
      internal static let title = L10n.tr("Localizable", "editedWarning.title")
    }
    internal enum Error {
      /// インスタンスを入力してください。
      internal static let pleaseInputInstance = L10n.tr("Localizable", "error.pleaseInputInstance")
      /// この機能はMastodonインスタンスのバージョンが%@以上でないと利用できません。\n(iMastを起動中にインスタンスがアップデートされた場合は、アプリを再起動すると利用できるようになります)\nMastodonインスタンスのアップデート予定については、各インスタンスの管理者にお尋ねください。
      internal static func requiredNewerMastodon(_ p1: Any) -> String {
        return L10n.tr("Localizable", "error.requiredNewerMastodon", String(describing: p1))
      }
      /// この機能を利用するためには iOS %.1f 以上が必要です。
      internal static func requiredNewerOS(_ p1: Float) -> String {
        return L10n.tr("Localizable", "error.requiredNewerOS", p1)
      }
      /// エラー
      internal static let title = L10n.tr("Localizable", "error.title")
      internal enum Unknown {
        /// もしよければ、このアラートがどのような条件で出たか、以下のコードを添えて @imast_ios@mstdn.rinsuki.net までお知らせください。
        internal static let text = L10n.tr("Localizable", "error.unknown.text")
        /// 謎のエラー
        internal static let title = L10n.tr("Localizable", "error.unknown.title")
      }
    }
    internal enum Help {
      /// ヘルプ
      internal static let title = L10n.tr("Localizable", "help.title")
    }
    internal enum HomeTimeline {
      /// ホーム
      internal static let short = L10n.tr("Localizable", "homeTimeline.short")
    }
    internal enum LocalTimeline {
      /// LTL
      internal static let short = L10n.tr("Localizable", "localTimeline.short")
    }
  }
  internal enum Login {
    /// ログイン
    internal static let loginButton = L10n.tr("Login", "loginButton")
    /// Mastodonのインスタンスを入力してください
    internal static let pleaseInputMastodonInstance = L10n.tr("Login", "pleaseInputMastodonInstance")
    /// ログイン
    internal static let title = L10n.tr("Login", "title")
    internal enum Authorize {
      /// 認証
      internal static let title = L10n.tr("Login", "authorize.title")
      internal enum Method {
        /// Safariでログイン (推奨)
        internal static let safari = L10n.tr("Login", "authorize.method.safari")
      }
      internal enum Tos {
        /// ログインすることで、以下のルールやプライバシーポリシーなどに同意したことになります。
        internal static let header = L10n.tr("Login", "authorize.tos.header")
        /// このサーバーのルール
        internal static let rules = L10n.tr("Login", "authorize.tos.rules")
        /// このサーバーの利用規約
        internal static let termsOfService = L10n.tr("Login", "authorize.tos.termsOfService")
      }
    }
    internal enum PasswordLogin {
      /// メールアドレス
      internal static let mailAddress = L10n.tr("Login", "passwordLogin.mailAddress")
      /// パスワード
      internal static let password = L10n.tr("Login", "passwordLogin.password")
    }
    internal enum ProgressDialog {
      /// サーバーの情報を取得中…
      internal static let fetchingServerInfo = L10n.tr("Login", "progressDialog.fetchingServerInfo")
      /// 認証してください
      internal static let pleaseAuthorize = L10n.tr("Login", "progressDialog.pleaseAuthorize")
      /// アプリをサーバーに登録中…
      internal static let registeringApplication = L10n.tr("Login", "progressDialog.registeringApplication")
      /// ログイン中
      internal static let title = L10n.tr("Login", "progressDialog.title")
    }
    internal enum Welcome {
      /// ようこそ、\n%@\nさん。
      internal static func message(_ p1: Any) -> String {
        return L10n.tr("Login", "welcome.message", String(describing: p1))
      }
      /// タイムラインへ
      internal static let toTimeline = L10n.tr("Login", "welcome.toTimeline")
    }
  }
  internal enum NewPost {
    /// ← から画像を追加
    internal static let addImageFromButton = L10n.tr("NewPost", "addImageFromButton")
    /// 編集
    internal static let edit = L10n.tr("NewPost", "edit")
    /// 返信
    internal static let reply = L10n.tr("NewPost", "reply")
    /// 送信
    internal static let send = L10n.tr("NewPost", "send")
    /// 新規投稿
    internal static let title = L10n.tr("NewPost", "title")
    internal enum Alerts {
      internal enum Sending {
        /// 投稿中
        internal static let title = L10n.tr("NewPost", "alerts.sending.title")
        internal enum Steps {
          /// 画像アップロード中 (%1$d/%2$d)
          internal static func mediaUpload(_ p1: Int, _ p2: Int) -> String {
            return L10n.tr("NewPost", "alerts.sending.steps.mediaUpload", p1, p2)
          }
          /// 送信中
          internal static let send = L10n.tr("NewPost", "alerts.sending.steps.send")
        }
      }
    }
    internal enum Errors {
      /// 楽曲ライブラリにアクセスできません。設定アプリでiMastに「メディアとApple Music」の権限を付与してください。
      internal static let declineAppleMusicPermission = L10n.tr("NewPost", "errors.declineAppleMusicPermission")
    }
    internal enum InfoText {
      /// 返信先: %@
      internal static func inReplyTo(_ p1: Any) -> String {
        return L10n.tr("NewPost", "infoText.inReplyTo", String(describing: p1))
      }
    }
    internal enum KeyCommand {
      internal enum Open {
        /// 新規投稿画面を開く
        internal static let description = L10n.tr("NewPost", "keyCommand.open.description")
        /// 新規投稿
        internal static let title = L10n.tr("NewPost", "keyCommand.open.title")
      }
      internal enum Send {
        /// 投稿を送信
        internal static let description = L10n.tr("NewPost", "keyCommand.send.description")
        /// 投稿
        internal static let title = L10n.tr("NewPost", "keyCommand.send.title")
      }
    }
    internal enum Media {
      /// 削除
      internal static let delete = L10n.tr("NewPost", "media.delete")
      /// プレビュー
      internal static let preview = L10n.tr("NewPost", "media.preview")
      internal enum Picker {
        /// 写真ライブラリ
        internal static let photoLibrary = L10n.tr("NewPost", "media.picker.photoLibrary")
        /// 写真を撮る
        internal static let takePhoto = L10n.tr("NewPost", "media.picker.takePhoto")
      }
    }
    internal enum Placeholders {
      /// CW説明文 (省略可能)
      internal static let cwWarningText = L10n.tr("NewPost", "placeholders.cwWarningText")
    }
    internal enum SelectVisibility {
      /// 公開範囲を選択してください
      internal static let description = L10n.tr("NewPost", "selectVisibility.description")
      /// 公開範囲
      internal static let title = L10n.tr("NewPost", "selectVisibility.title")
    }
  }
  internal enum Notification {
    internal enum Types {
      /// @%@さんにブーストされました
      internal static func boost(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.boost", String(describing: p1))
      }
      /// @%@さんにふぁぼられました
      internal static func favourite(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.favourite", String(describing: p1))
      }
      /// @%@さんにフォローされました
      internal static func follow(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.follow", String(describing: p1))
      }
      /// @%@さんがあなたをフォローしたいようです
      internal static func followRequest(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.followRequest", String(describing: p1))
      }
      /// @%@さんからのメンション
      internal static func mention(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.mention", String(describing: p1))
      }
      /// 不明な通知: %@
      internal static func unknown(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.unknown", String(describing: p1))
      }
      internal enum Poll {
        /// あなたが参加した投票が終了しました
        internal static let notowner = L10n.tr("Notification", "types.poll.notowner")
        /// あなたが作成した投票が終了しました
        internal static let owner = L10n.tr("Notification", "types.poll.owner")
      }
      internal enum PostUpdated {
        /// 投稿が編集されました
        internal static let isMe = L10n.tr("Notification", "types.postUpdated.isMe")
        /// 過去にブーストした投稿が編集されました
        internal static let notMe = L10n.tr("Notification", "types.postUpdated.notMe")
      }
    }
  }
  internal enum OtherMenu {
    internal enum Lists {
      /// リスト
      internal static let title = L10n.tr("OtherMenu", "lists.title")
      internal enum Create {
        /// リストの名前を決めてください
        internal static let message = L10n.tr("OtherMenu", "lists.create.message")
        /// リスト作成
        internal static let title = L10n.tr("OtherMenu", "lists.create.title")
        internal enum Actions {
          /// 作成
          internal static let primary = L10n.tr("OtherMenu", "lists.create.actions.primary")
        }
        internal enum TextField {
          internal enum Name {
            /// リストの名前
            internal static let placeholder = L10n.tr("OtherMenu", "lists.create.textField.name.placeholder")
          }
        }
      }
    }
  }
  internal enum Preferences {
    internal enum General {
      internal enum NewAccountVia {
        /// 新規連携時のvia
        internal static let title = L10n.tr("Preferences", "general.newAccountVia.title")
      }
      internal enum StreamingAutoConnect {
        /// 常にする
        internal static let always = L10n.tr("Preferences", "general.streamingAutoConnect.always")
        /// 常にしない
        internal static let no = L10n.tr("Preferences", "general.streamingAutoConnect.no")
        /// ストリーミング自動接続
        internal static let title = L10n.tr("Preferences", "general.streamingAutoConnect.title")
        /// WiFi接続時のみ
        internal static let wifi = L10n.tr("Preferences", "general.streamingAutoConnect.wifi")
      }
    }
    internal enum NowPlaying {
      /// Apple MusicならURLを付ける (できれば)
      internal static let addURLIfAppleMusicAndAvailable = L10n.tr("Preferences", "nowPlaying.addURLIfAppleMusicAndAvailable")
      /// NowPlaying
      internal static let title = L10n.tr("Preferences", "nowPlaying.title")
      internal enum Format {
        /// フォーマット
        internal static let title = L10n.tr("Preferences", "nowPlaying.format.title")
      }
    }
    internal enum Post {
      /// 投稿
      internal static let title = L10n.tr("Preferences", "post.title")
      /// デフォルト公開範囲を利用
      internal static let useDefaultVisibility = L10n.tr("Preferences", "post.useDefaultVisibility")
      internal enum AutoResize {
        /// しない
        internal static let no = L10n.tr("Preferences", "post.autoResize.no")
        /// %dpx以下にリサイズ
        internal static func pixel(_ p1: Int) -> String {
          return L10n.tr("Preferences", "post.autoResize.pixel", p1)
        }
        /// 画像の自動リサイズ
        internal static let title = L10n.tr("Preferences", "post.autoResize.title")
      }
    }
    internal enum Push {
      /// プッシュ通知
      internal static let link = L10n.tr("Preferences", "push.link")
      /// プッシュ通知設定
      internal static let title = L10n.tr("Preferences", "push.title")
      internal enum Accounts {
        /// アカウント一覧
        internal static let title = L10n.tr("Preferences", "push.accounts.title")
      }
      internal enum AddAccount {
        /// インスタンスのホスト名を入力してください\n(https://などは含めず入力してください)
        internal static let alertText = L10n.tr("Preferences", "push.addAccount.alertText")
        /// アカウント追加
        internal static let alertTitle = L10n.tr("Preferences", "push.addAccount.alertTitle")
        /// アカウントを追加
        internal static let title = L10n.tr("Preferences", "push.addAccount.title")
      }
      internal enum Shared {
        /// 通知受信時のクライアント側の処理に失敗した場合に、本来の通知内容の代わりにエラーを通知する
        internal static let displayErrorIfOccured = L10n.tr("Preferences", "push.shared.displayErrorIfOccured")
        /// 共通設定
        internal static let title = L10n.tr("Preferences", "push.shared.title")
        internal enum CustomSounds {
          /// 通知音カスタム (α)
          internal static let title = L10n.tr("Preferences", "push.shared.customSounds.title")
        }
        internal enum DeleteAccount {
          /// プッシュ通知の設定を削除
          internal static let title = L10n.tr("Preferences", "push.shared.deleteAccount.title")
        }
        internal enum GroupRules {
          /// アカウント毎にグループを分ける
          internal static let byAccount = L10n.tr("Preferences", "push.shared.groupRules.byAccount")
          /// グループ化のルール設定 (β)
          internal static let title = L10n.tr("Preferences", "push.shared.groupRules.title")
          internal enum ByType {
            /// ONにしたタイプはすべて個別のグループになります。
            internal static let description = L10n.tr("Preferences", "push.shared.groupRules.byType.description")
            /// 通知タイプ毎にグループを分ける
            internal static let title = L10n.tr("Preferences", "push.shared.groupRules.byType.title")
          }
        }
      }
      internal enum Support {
        /// サポート用
        internal static let title = L10n.tr("Preferences", "push.support.title")
        internal enum ShowUserID {
          /// ユーザーID
          internal static let alertTitle = L10n.tr("Preferences", "push.support.showUserID.alertTitle")
          /// コピー
          internal static let copyAction = L10n.tr("Preferences", "push.support.showUserID.copyAction")
          /// ユーザーIDがわかりませんでした
          internal static let failedToCheckUserID = L10n.tr("Preferences", "push.support.showUserID.failedToCheckUserID")
          /// プッシュ通知ユーザーIDを表示
          internal static let title = L10n.tr("Preferences", "push.support.showUserID.title")
        }
      }
    }
    internal enum Timeline {
      /// WebMをVLCで開く
      internal static let openWebMInVLC = L10n.tr("Preferences", "timeline.openWebMInVLC")
      /// タイムライン
      internal static let title = L10n.tr("Preferences", "timeline.title")
      /// OSの動画プレーヤーを使う
      internal static let useSystemVideoPlayer = L10n.tr("Preferences", "timeline.useSystemVideoPlayer")
      /// Universal Links を優先
      internal static let useUniversalLinks = L10n.tr("Preferences", "timeline.useUniversalLinks")
    }
    internal enum TimelineAppearance {
      /// 本文を太字で表示
      internal static let contentBold = L10n.tr("Preferences", "timelineAppearance.contentBold")
      /// 本文の文字の大きさ
      internal static let contentSize = L10n.tr("Preferences", "timelineAppearance.contentSize")
      /// アイコンの大きさ
      internal static let iconSize = L10n.tr("Preferences", "timelineAppearance.iconSize")
      /// inReplyToの有無を絵文字で表示
      internal static let inReplyToAsEmoji = L10n.tr("Preferences", "timelineAppearance.inReplyToAsEmoji")
      /// ぬるぬるモード(再起動後反映)
      internal static let nurunuru = L10n.tr("Preferences", "timelineAppearance.nurunuru")
      /// サムネイルの高さ
      internal static let thumbnailHeight = L10n.tr("Preferences", "timelineAppearance.thumbnailHeight")
      /// タイムラインの外観
      internal static let title = L10n.tr("Preferences", "timelineAppearance.title")
      /// ユーザー名の文字の大きさ
      internal static let userNameSize = L10n.tr("Preferences", "timelineAppearance.userNameSize")
      /// 公開範囲を絵文字で表示
      internal static let visibilityAsEmoji = L10n.tr("Preferences", "timelineAppearance.visibilityAsEmoji")
      internal enum BigNewPostButton {
        /// でかい投稿ボタンを表示
        internal static let show = L10n.tr("Preferences", "timelineAppearance.bigNewPostButton.show")
        internal enum Location {
          /// でかい投稿ボタンの場所
          internal static let title = L10n.tr("Preferences", "timelineAppearance.bigNewPostButton.location.title")
        }
      }
    }
  }
  internal enum Search {
    /// 検索
    internal static let title = L10n.tr("Search", "title")
    internal enum Sections {
      internal enum Accounts {
        /// アカウント
        internal static let title = L10n.tr("Search", "sections.accounts.title")
      }
      internal enum Hashtags {
        /// ハッシュタグ
        internal static let title = L10n.tr("Search", "sections.hashtags.title")
      }
      internal enum Posts {
        /// 投稿
        internal static let title = L10n.tr("Search", "sections.posts.title")
      }
      internal enum TrendTags {
        /// トレンドタグ (更新: %@)
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Search", "sections.trendTags.title", String(describing: p1))
        }
      }
    }
  }
  internal enum UserProfile {
    /// Webで最新のプロフィールを見る
    internal static let checkLatestProfileInWeb = L10n.tr("UserProfile", "checkLatestProfileInWeb")
    /// このユーザーは外部インスタンスに所属しているため、一部の数値が正確でない場合があります。
    internal static let federatedUserWarning = L10n.tr("UserProfile", "federatedUserWarning")
    /// プロフィール
    internal static let title = L10n.tr("UserProfile", "title")
    internal enum Actions {
      /// ブロック
      internal static let block = L10n.tr("UserProfile", "actions.block")
      /// キャンセル
      internal static let cancel = L10n.tr("UserProfile", "actions.cancel")
      /// フォロー
      internal static let follow = L10n.tr("UserProfile", "actions.follow")
      /// フォローリクエストを撤回
      internal static let followRequestCancel = L10n.tr("UserProfile", "actions.followRequestCancel")
      /// フォローリクエスト一覧
      internal static let followRequestsList = L10n.tr("UserProfile", "actions.followRequestsList")
      /// ミュート
      internal static let mute = L10n.tr("UserProfile", "actions.mute")
      /// 名刺
      internal static let profileCard = L10n.tr("UserProfile", "actions.profileCard")
      /// 共有
      internal static let share = L10n.tr("UserProfile", "actions.share")
      /// アクション
      internal static let title = L10n.tr("UserProfile", "actions.title")
      /// ブロック解除
      internal static let unblock = L10n.tr("UserProfile", "actions.unblock")
      /// フォロー解除
      internal static let unfollow = L10n.tr("UserProfile", "actions.unfollow")
      /// ミュート解除
      internal static let unmute = L10n.tr("UserProfile", "actions.unmute")
    }
    internal enum Cells {
      internal enum CreatedAt {
        /// 登録日
        internal static let title = L10n.tr("UserProfile", "cells.createdAt.title")
      }
      internal enum Followers {
        /// フォロワー
        internal static let title = L10n.tr("UserProfile", "cells.followers.title")
      }
      internal enum Following {
        /// フォロー
        internal static let title = L10n.tr("UserProfile", "cells.following.title")
      }
      internal enum Toots {
        /// 投稿
        internal static let title = L10n.tr("UserProfile", "cells.toots.title")
      }
    }
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
  static let bundle = Bundle(for: BundleToken.self)
}
// swiftlint:enable convenience_type
