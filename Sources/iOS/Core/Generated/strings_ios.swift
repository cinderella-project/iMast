// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum Localizable {
    /// ブックマーク
    public static let bookmarks = L10n.tr("Localizable", "bookmarks")
    /// キャンセル
    public static let cancel = L10n.tr("Localizable", "cancel")
    /// 使用するアカウントを選択
    public static let chooseAccount = L10n.tr("Localizable", "chooseAccount")
    /// 接続
    public static let connect = L10n.tr("Localizable", "connect")
    /// 接続中
    public static let connected = L10n.tr("Localizable", "connected")
    /// 現在のアカウント: @%@
    public static func currentAccount(_ p1: Any) -> String {
      return L10n.tr("Localizable", "currentAccount", String(describing: p1))
    }
    /// 切断
    public static let disconnect = L10n.tr("Localizable", "disconnect")
    /// ふぁぼ一覧
    public static let favouritesList = L10n.tr("Localizable", "favouritesList")
    /// 連合タイムライン
    public static let federatedTimeline = L10n.tr("Localizable", "federatedTimeline")
    /// 取得失敗
    public static let fetchFailed = L10n.tr("Localizable", "fetchFailed")
    /// ヘルプ / Feedback
    public static let helpAndFeedback = L10n.tr("Localizable", "helpAndFeedback")
    /// ホームタイムライン
    public static let homeTimeline = L10n.tr("Localizable", "homeTimeline")
    /// リスト
    public static let lists = L10n.tr("Localizable", "lists")
    /// ローカルタイムライン
    public static let localTimeline = L10n.tr("Localizable", "localTimeline")
    /// 自分のプロフィール
    public static let myProfile = L10n.tr("Localizable", "myProfile")
    /// 接続していません
    public static let notConnected = L10n.tr("Localizable", "notConnected")
    /// ここまで
    public static let nothingMore = L10n.tr("Localizable", "nothingMore")
    /// 通知
    public static let notifications = L10n.tr("Localizable", "notifications")
    /// その他
    public static let other = L10n.tr("Localizable", "other")
    /// 投稿
    public static let post = L10n.tr("Localizable", "post")
    /// もっと
    public static let readmore = L10n.tr("Localizable", "readmore")
    /// 再取得
    public static let refetch = L10n.tr("Localizable", "refetch")
    /// 設定
    public static let settings = L10n.tr("Localizable", "settings")
    /// Streaming
    public static let streaming = L10n.tr("Localizable", "streaming")
    /// 状態: %@
    public static func streamingStatus(_ p1: Any) -> String {
      return L10n.tr("Localizable", "streamingStatus", String(describing: p1))
    }
    /// アカウントを変更
    public static let switchActiveAccount = L10n.tr("Localizable", "switchActiveAccount")
    /// %@ に切り替え
    public static func switchTab(_ p1: Any) -> String {
      return L10n.tr("Localizable", "switchTab", String(describing: p1))
    }
    public enum AboutThisApp {
      /// 作者
      public static let author = L10n.tr("Localizable", "aboutThisApp.author")
      /// ほめる
      public static let praise = L10n.tr("Localizable", "aboutThisApp.praise")
      /// App Store でレビューする
      public static let reviewInAppStore = L10n.tr("Localizable", "aboutThisApp.reviewInAppStore")
      /// GitHub で Star する
      public static let starInGitHub = L10n.tr("Localizable", "aboutThisApp.starInGitHub")
      /// このAppについて
      public static let title = L10n.tr("Localizable", "aboutThisApp.title")
      /// #imast_ios を付けて投稿する
      public static let tootWithHashtag = L10n.tr("Localizable", "aboutThisApp.tootWithHashtag")
      /// 翻訳してくれた人たち
      public static let translators = L10n.tr("Localizable", "aboutThisApp.translators")
    }
    public enum Bunmyaku {
      /// 文脈
      public static let title = L10n.tr("Localizable", "bunmyaku.title")
    }
    public enum Count {
      /// Plural format key: "%#@count@"
      public static func boost(_ p1: Int) -> String {
        return L10n.tr("Localizable", "count.boost", p1)
      }
      /// Plural format key: "%#@count@"
      public static func favorites(_ p1: Int) -> String {
        return L10n.tr("Localizable", "count.favorites", p1)
      }
    }
    public enum CustomEmojis {
      /// カスタム絵文字一覧
      public static let title = L10n.tr("Localizable", "customEmojis.title")
    }
    public enum EditHistory {
      /// 編集履歴
      public static let title = L10n.tr("Localizable", "editHistory.title")
      public enum Desc {
        /// オリジナル
        public static let original = L10n.tr("Localizable", "editHistory.desc.original")
        public enum Diff {
          /// 添付メディア
          public static let attachments = L10n.tr("Localizable", "editHistory.desc.diff.attachments")
          /// 本文
          public static let content = L10n.tr("Localizable", "editHistory.desc.diff.content")
          /// CW警告文
          public static let cw = L10n.tr("Localizable", "editHistory.desc.diff.cw")
          /// NSFWフラグ
          public static let sensitive = L10n.tr("Localizable", "editHistory.desc.diff.sensitive")
          /// 変更点: %@
          public static func template(_ p1: Any) -> String {
            return L10n.tr("Localizable", "editHistory.desc.diff.template", String(describing: p1))
          }
        }
      }
    }
    public enum EditedWarning {
      /// 最終編集: %@
      public static func description(_ p1: Any) -> String {
        return L10n.tr("Localizable", "editedWarning.description", String(describing: p1))
      }
      /// この投稿は投稿後に編集されています
      public static let title = L10n.tr("Localizable", "editedWarning.title")
    }
    public enum Error {
      /// インスタンスを入力してください。
      public static let pleaseInputInstance = L10n.tr("Localizable", "error.pleaseInputInstance")
      /// この機能はMastodonインスタンスのバージョンが%@以上でないと利用できません。
      /// (iMastを起動中にインスタンスがアップデートされた場合は、アプリを再起動すると利用できるようになります)
      /// Mastodonインスタンスのアップデート予定については、各インスタンスの管理者にお尋ねください。
      public static func requiredNewerMastodon(_ p1: Any) -> String {
        return L10n.tr("Localizable", "error.requiredNewerMastodon", String(describing: p1))
      }
      /// この機能を利用するためには iOS %.1f 以上が必要です。
      public static func requiredNewerOS(_ p1: Float) -> String {
        return L10n.tr("Localizable", "error.requiredNewerOS", p1)
      }
      /// エラー
      public static let title = L10n.tr("Localizable", "error.title")
      /// サーバーから無効なデータが返されました: %1$@ のID %2$@ は %3$@ 内で自分自身を参照しています
      public static func tryToChainItself(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return L10n.tr("Localizable", "error.tryToChainItself", String(describing: p1), String(describing: p2), String(describing: p3))
      }
      public enum Unknown {
        /// もしよければ、このアラートがどのような条件で出たか、以下のコードを添えて @imast_ios@mstdn.rinsuki.net までお知らせください。
        public static let text = L10n.tr("Localizable", "error.unknown.text")
        /// 謎のエラー
        public static let title = L10n.tr("Localizable", "error.unknown.title")
      }
    }
    public enum FederatedTimeline {
      /// 連合
      public static let short = L10n.tr("Localizable", "federatedTimeline.short")
    }
    public enum Help {
      /// ヘルプ
      public static let title = L10n.tr("Localizable", "help.title")
    }
    public enum HomeTimeline {
      /// ホーム
      public static let short = L10n.tr("Localizable", "homeTimeline.short")
    }
    public enum LocalTimeline {
      /// LTL
      public static let short = L10n.tr("Localizable", "localTimeline.short")
    }
    public enum PostDetail {
      /// ブースト
      public static let boost = L10n.tr("Localizable", "postDetail.boost")
      /// 削除
      public static let delete = L10n.tr("Localizable", "postDetail.delete")
      /// ふぁぼ
      public static let favorite = L10n.tr("Localizable", "postDetail.favorite")
      /// 通報
      public static let reportAbuse = L10n.tr("Localizable", "postDetail.reportAbuse")
      /// 共有
      public static let share = L10n.tr("Localizable", "postDetail.share")
      /// 投稿詳細
      public static let title = L10n.tr("Localizable", "postDetail.title")
    }
    public enum ReportPost {
      /// 送信
      public static let send = L10n.tr("Localizable", "reportPost.send")
      /// 投稿を通報
      public static let title = L10n.tr("Localizable", "reportPost.title")
      public enum AdditionalInfo {
        /// オプション
        public static let placeholderOption = L10n.tr("Localizable", "reportPost.additionalInfo.placeholderOption")
        /// 追加の情報
        public static let title = L10n.tr("Localizable", "reportPost.additionalInfo.title")
      }
      public enum Finished {
        /// 送信しました
        public static let title = L10n.tr("Localizable", "reportPost.finished.title")
      }
      public enum ForwardToRemote {
        /// このスイッチをONにすると、この通報内容は%1$@にも転送されます。あなたのアカウントがあるサーバーと%1$@が共にMastodon 2.3以上であるか、通報の連合経由での転送に対応している必要があります。
        public static func description(_ p1: Any) -> String {
          return L10n.tr("Localizable", "reportPost.forwardToRemote.description", String(describing: p1))
        }
        /// リモートサーバーに転送
        public static let title = L10n.tr("Localizable", "reportPost.forwardToRemote.title")
      }
      public enum TargetPost {
        /// 対象の投稿
        public static let title = L10n.tr("Localizable", "reportPost.targetPost.title")
      }
    }
  }
  public enum Login {
    /// ログイン
    public static let loginButton = L10n.tr("Login", "loginButton")
    /// Mastodonのインスタンスを入力してください
    public static let pleaseInputMastodonInstance = L10n.tr("Login", "pleaseInputMastodonInstance")
    /// ログイン
    public static let title = L10n.tr("Login", "title")
    public enum AcquireTokenProgress {
      /// あともう少しです…
      public static let almostDone = L10n.tr("Login", "acquireTokenProgress.almostDone")
      /// プロフィール情報を取得中…
      public static let fetchingProfile = L10n.tr("Login", "acquireTokenProgress.fetchingProfile")
      /// 認証中…
      public static let fetchingToken = L10n.tr("Login", "acquireTokenProgress.fetchingToken")
    }
    public enum Authorize {
      /// 認証
      public static let title = L10n.tr("Login", "authorize.title")
      public enum Method {
        /// Safariでログイン (推奨)
        public static let safari = L10n.tr("Login", "authorize.method.safari")
        /// Safariでログイン (プライベートブラウズ)
        public static let safariEphemeral = L10n.tr("Login", "authorize.method.safariEphemeral")
      }
      public enum Tos {
        /// ログインすることで、以下のルールやプライバシーポリシーなどに同意したことになります。
        public static let header = L10n.tr("Login", "authorize.tos.header")
        /// このサーバーのルール
        public static let rules = L10n.tr("Login", "authorize.tos.rules")
        /// このサーバーの利用規約
        public static let termsOfService = L10n.tr("Login", "authorize.tos.termsOfService")
      }
    }
    public enum PasswordLogin {
      /// メールアドレス
      public static let mailAddress = L10n.tr("Login", "passwordLogin.mailAddress")
      /// パスワード
      public static let password = L10n.tr("Login", "passwordLogin.password")
    }
    public enum ProgressDialog {
      /// サーバーの情報を取得中…
      public static let fetchingServerInfo = L10n.tr("Login", "progressDialog.fetchingServerInfo")
      /// 認証してください
      public static let pleaseAuthorize = L10n.tr("Login", "progressDialog.pleaseAuthorize")
      /// アプリをサーバーに登録中…
      public static let registeringApplication = L10n.tr("Login", "progressDialog.registeringApplication")
      /// ログイン中
      public static let title = L10n.tr("Login", "progressDialog.title")
    }
    public enum Welcome {
      /// ようこそ、
      /// %@
      /// さん。
      public static func message(_ p1: Any) -> String {
        return L10n.tr("Login", "welcome.message", String(describing: p1))
      }
      /// タイムラインへ
      public static let toTimeline = L10n.tr("Login", "welcome.toTimeline")
    }
  }
  public enum NewPost {
    /// ← から画像を追加
    public static let addImageFromButton = L10n.tr("NewPost", "addImageFromButton")
    /// 編集
    public static let edit = L10n.tr("NewPost", "edit")
    /// 返信
    public static let reply = L10n.tr("NewPost", "reply")
    /// 送信
    public static let send = L10n.tr("NewPost", "send")
    /// 新規投稿
    public static let title = L10n.tr("NewPost", "title")
    public enum Alerts {
      public enum Sending {
        /// しばらくお待ちください…
        public static let pleaseWait = L10n.tr("NewPost", "alerts.sending.pleaseWait")
        /// 投稿中
        public static let title = L10n.tr("NewPost", "alerts.sending.title")
        public enum Steps {
          /// 完了しました
          public static let done = L10n.tr("NewPost", "alerts.sending.steps.done")
          /// 画像アップロード中 (%1$d/%2$d)
          public static func mediaUpload(_ p1: Int, _ p2: Int) -> String {
            return L10n.tr("NewPost", "alerts.sending.steps.mediaUpload", p1, p2)
          }
          /// 送信中
          public static let send = L10n.tr("NewPost", "alerts.sending.steps.send")
        }
      }
    }
    public enum Errors {
      /// 楽曲ライブラリにアクセスできません。設定アプリでiMastに「メディアとApple Music」の権限を付与してください。
      public static let declineAppleMusicPermission = L10n.tr("NewPost", "errors.declineAppleMusicPermission")
    }
    public enum InfoText {
      /// 返信先: %@
      public static func inReplyTo(_ p1: Any) -> String {
        return L10n.tr("NewPost", "infoText.inReplyTo", String(describing: p1))
      }
    }
    public enum KeyCommand {
      public enum Open {
        /// 新規投稿画面を開く
        public static let description = L10n.tr("NewPost", "keyCommand.open.description")
        /// 新規投稿
        public static let title = L10n.tr("NewPost", "keyCommand.open.title")
      }
      public enum Send {
        /// 投稿を送信
        public static let description = L10n.tr("NewPost", "keyCommand.send.description")
        /// 投稿
        public static let title = L10n.tr("NewPost", "keyCommand.send.title")
      }
    }
    public enum Media {
      /// 削除
      public static let delete = L10n.tr("NewPost", "media.delete")
      /// プレビュー
      public static let preview = L10n.tr("NewPost", "media.preview")
      public enum Picker {
        /// 写真ライブラリ
        public static let photoLibrary = L10n.tr("NewPost", "media.picker.photoLibrary")
        /// 写真を撮る
        public static let takePhoto = L10n.tr("NewPost", "media.picker.takePhoto")
      }
    }
    public enum Placeholders {
      /// CW説明文 (省略可能)
      public static let cwWarningText = L10n.tr("NewPost", "placeholders.cwWarningText")
    }
    public enum SelectVisibility {
      /// 公開範囲を選択してください
      public static let description = L10n.tr("NewPost", "selectVisibility.description")
      /// 公開範囲
      public static let title = L10n.tr("NewPost", "selectVisibility.title")
    }
  }
  public enum Notification {
    public enum Types {
      /// @%@さんにブーストされました
      public static func boost(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.boost", String(describing: p1))
      }
      /// @%@さんにふぁぼられました
      public static func favourite(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.favourite", String(describing: p1))
      }
      /// @%@さんにフォローされました
      public static func follow(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.follow", String(describing: p1))
      }
      /// @%@さんがあなたをフォローしたいようです
      public static func followRequest(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.followRequest", String(describing: p1))
      }
      /// @%@さんからのメンション
      public static func mention(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.mention", String(describing: p1))
      }
      /// 不明な通知: %@
      public static func unknown(_ p1: Any) -> String {
        return L10n.tr("Notification", "types.unknown", String(describing: p1))
      }
      public enum Poll {
        /// あなたが参加した投票が終了しました
        public static let notowner = L10n.tr("Notification", "types.poll.notowner")
        /// あなたが作成した投票が終了しました
        public static let owner = L10n.tr("Notification", "types.poll.owner")
      }
      public enum PostUpdated {
        /// 投稿が編集されました
        public static let isMe = L10n.tr("Notification", "types.postUpdated.isMe")
        /// 過去にブーストした投稿が編集されました
        public static let notMe = L10n.tr("Notification", "types.postUpdated.notMe")
      }
    }
  }
  public enum OtherMenu {
    public enum Lists {
      /// リスト
      public static let title = L10n.tr("OtherMenu", "lists.title")
      public enum Create {
        /// リストの名前を決めてください
        public static let message = L10n.tr("OtherMenu", "lists.create.message")
        /// リスト作成
        public static let title = L10n.tr("OtherMenu", "lists.create.title")
        public enum Actions {
          /// 作成
          public static let primary = L10n.tr("OtherMenu", "lists.create.actions.primary")
        }
        public enum TextField {
          public enum Name {
            /// リストの名前
            public static let placeholder = L10n.tr("OtherMenu", "lists.create.textField.name.placeholder")
          }
        }
      }
    }
  }
  public enum Preferences {
    public enum General {
      public enum NewAccountVia {
        /// 新規連携時のvia
        public static let title = L10n.tr("Preferences", "general.newAccountVia.title")
      }
      public enum StreamingAutoConnect {
        /// 常にする
        public static let always = L10n.tr("Preferences", "general.streamingAutoConnect.always")
        /// 常にしない
        public static let no = L10n.tr("Preferences", "general.streamingAutoConnect.no")
        /// ストリーミング自動接続
        public static let title = L10n.tr("Preferences", "general.streamingAutoConnect.title")
        /// WiFi接続時のみ
        public static let wifi = L10n.tr("Preferences", "general.streamingAutoConnect.wifi")
      }
    }
    public enum NowPlaying {
      /// Apple MusicならURLを付ける (できれば)
      public static let addURLIfAppleMusicAndAvailable = L10n.tr("Preferences", "nowPlaying.addURLIfAppleMusicAndAvailable")
      /// NowPlaying
      public static let title = L10n.tr("Preferences", "nowPlaying.title")
      public enum Format {
        /// フォーマット
        public static let title = L10n.tr("Preferences", "nowPlaying.format.title")
      }
    }
    public enum Post {
      /// 投稿
      public static let title = L10n.tr("Preferences", "post.title")
      /// デフォルト公開範囲を利用
      public static let useDefaultVisibility = L10n.tr("Preferences", "post.useDefaultVisibility")
      public enum AutoResize {
        /// しない
        public static let no = L10n.tr("Preferences", "post.autoResize.no")
        /// %dpx以下にリサイズ
        public static func pixel(_ p1: Int) -> String {
          return L10n.tr("Preferences", "post.autoResize.pixel", p1)
        }
        /// 画像の自動リサイズ
        public static let title = L10n.tr("Preferences", "post.autoResize.title")
      }
    }
    public enum Push {
      /// プッシュ通知
      public static let link = L10n.tr("Preferences", "push.link")
      /// プッシュ通知設定
      public static let title = L10n.tr("Preferences", "push.title")
      public enum Accounts {
        /// アカウント一覧
        public static let title = L10n.tr("Preferences", "push.accounts.title")
      }
      public enum AddAccount {
        /// インスタンスのホスト名を入力してください
        /// (https://などは含めず入力してください)
        public static let alertText = L10n.tr("Preferences", "push.addAccount.alertText")
        /// アカウント追加
        public static let alertTitle = L10n.tr("Preferences", "push.addAccount.alertTitle")
        /// アカウントを追加
        public static let title = L10n.tr("Preferences", "push.addAccount.title")
      }
      public enum Shared {
        /// 通知受信時のクライアント側の処理に失敗した場合に、本来の通知内容の代わりにエラーを通知する
        public static let displayErrorIfOccured = L10n.tr("Preferences", "push.shared.displayErrorIfOccured")
        /// 共通設定
        public static let title = L10n.tr("Preferences", "push.shared.title")
        public enum CustomSounds {
          /// 通知音カスタム (α)
          public static let title = L10n.tr("Preferences", "push.shared.customSounds.title")
        }
        public enum DeleteAccount {
          /// プッシュ通知の設定を削除
          public static let title = L10n.tr("Preferences", "push.shared.deleteAccount.title")
        }
        public enum GroupRules {
          /// アカウント毎にグループを分ける
          public static let byAccount = L10n.tr("Preferences", "push.shared.groupRules.byAccount")
          /// グループ化のルール設定 (β)
          public static let title = L10n.tr("Preferences", "push.shared.groupRules.title")
          public enum ByType {
            /// ONにしたタイプはすべて個別のグループになります。
            public static let description = L10n.tr("Preferences", "push.shared.groupRules.byType.description")
            /// 通知タイプ毎にグループを分ける
            public static let title = L10n.tr("Preferences", "push.shared.groupRules.byType.title")
          }
        }
      }
      public enum Support {
        /// サポート用
        public static let title = L10n.tr("Preferences", "push.support.title")
        public enum ShowUserID {
          /// ユーザーID
          public static let alertTitle = L10n.tr("Preferences", "push.support.showUserID.alertTitle")
          /// コピー
          public static let copyAction = L10n.tr("Preferences", "push.support.showUserID.copyAction")
          /// ユーザーIDがわかりませんでした
          public static let failedToCheckUserID = L10n.tr("Preferences", "push.support.showUserID.failedToCheckUserID")
          /// プッシュ通知ユーザーIDを表示
          public static let title = L10n.tr("Preferences", "push.support.showUserID.title")
        }
      }
    }
    public enum Timeline {
      /// WebMをVLCで開く
      public static let openWebMInVLC = L10n.tr("Preferences", "timeline.openWebMInVLC")
      /// タイムライン
      public static let title = L10n.tr("Preferences", "timeline.title")
      /// OSの動画プレーヤーを使う
      public static let useSystemVideoPlayer = L10n.tr("Preferences", "timeline.useSystemVideoPlayer")
      /// Universal Links を優先
      public static let useUniversalLinks = L10n.tr("Preferences", "timeline.useUniversalLinks")
    }
    public enum TimelineAppearance {
      /// 本文を太字で表示
      public static let contentBold = L10n.tr("Preferences", "timelineAppearance.contentBold")
      /// 本文の文字の大きさ
      public static let contentSize = L10n.tr("Preferences", "timelineAppearance.contentSize")
      /// アイコンの大きさ
      public static let iconSize = L10n.tr("Preferences", "timelineAppearance.iconSize")
      /// inReplyToの有無を絵文字で表示
      public static let inReplyToAsEmoji = L10n.tr("Preferences", "timelineAppearance.inReplyToAsEmoji")
      /// ぬるぬるモード(再起動後反映)
      public static let nurunuru = L10n.tr("Preferences", "timelineAppearance.nurunuru")
      /// サムネイルの高さ
      public static let thumbnailHeight = L10n.tr("Preferences", "timelineAppearance.thumbnailHeight")
      /// タイムラインの外観
      public static let title = L10n.tr("Preferences", "timelineAppearance.title")
      /// ユーザー名の文字の大きさ
      public static let userNameSize = L10n.tr("Preferences", "timelineAppearance.userNameSize")
      /// 公開範囲を絵文字で表示
      public static let visibilityAsEmoji = L10n.tr("Preferences", "timelineAppearance.visibilityAsEmoji")
      public enum BigNewPostButton {
        /// でかい投稿ボタンを表示
        public static let show = L10n.tr("Preferences", "timelineAppearance.bigNewPostButton.show")
        public enum Location {
          /// でかい投稿ボタンの場所
          public static let title = L10n.tr("Preferences", "timelineAppearance.bigNewPostButton.location.title")
        }
      }
    }
  }
  public enum Search {
    /// 検索
    public static let title = L10n.tr("Search", "title")
    public enum Sections {
      public enum Accounts {
        /// アカウント
        public static let title = L10n.tr("Search", "sections.accounts.title")
      }
      public enum Hashtags {
        /// ハッシュタグ
        public static let title = L10n.tr("Search", "sections.hashtags.title")
      }
      public enum Posts {
        /// 投稿
        public static let title = L10n.tr("Search", "sections.posts.title")
      }
      public enum TrendTags {
        /// トレンドタグ (更新: %@)
        public static func title(_ p1: Any) -> String {
          return L10n.tr("Search", "sections.trendTags.title", String(describing: p1))
        }
      }
    }
  }
  public enum UserProfile {
    /// Webで最新のプロフィールを見る
    public static let checkLatestProfileInWeb = L10n.tr("UserProfile", "checkLatestProfileInWeb")
    /// このユーザーは外部インスタンスに所属しているため、一部の数値が正確でない場合があります。
    public static let federatedUserWarning = L10n.tr("UserProfile", "federatedUserWarning")
    /// プロフィール
    public static let title = L10n.tr("UserProfile", "title")
    public enum Actions {
      /// ブロック
      public static let block = L10n.tr("UserProfile", "actions.block")
      /// キャンセル
      public static let cancel = L10n.tr("UserProfile", "actions.cancel")
      /// フォロー
      public static let follow = L10n.tr("UserProfile", "actions.follow")
      /// フォローリクエストを撤回
      public static let followRequestCancel = L10n.tr("UserProfile", "actions.followRequestCancel")
      /// フォローリクエスト一覧
      public static let followRequestsList = L10n.tr("UserProfile", "actions.followRequestsList")
      /// ミュート
      public static let mute = L10n.tr("UserProfile", "actions.mute")
      /// 共有
      public static let share = L10n.tr("UserProfile", "actions.share")
      /// アクション
      public static let title = L10n.tr("UserProfile", "actions.title")
      /// ブロック解除
      public static let unblock = L10n.tr("UserProfile", "actions.unblock")
      /// フォロー解除
      public static let unfollow = L10n.tr("UserProfile", "actions.unfollow")
      /// ミュート解除
      public static let unmute = L10n.tr("UserProfile", "actions.unmute")
    }
    public enum Cells {
      public enum CreatedAt {
        /// 登録日
        public static let title = L10n.tr("UserProfile", "cells.createdAt.title")
      }
      public enum Followers {
        /// フォロワー
        public static let title = L10n.tr("UserProfile", "cells.followers.title")
      }
      public enum Following {
        /// フォロー
        public static let title = L10n.tr("UserProfile", "cells.following.title")
      }
      public enum Toots {
        /// 投稿
        public static let title = L10n.tr("UserProfile", "cells.toots.title")
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
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
