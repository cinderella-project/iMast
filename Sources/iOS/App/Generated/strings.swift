// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  internal enum Localizable {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "cancel")
    /// Connect
    internal static let connect = L10n.tr("Localizable", "connect")
    /// Connected
    internal static let connected = L10n.tr("Localizable", "connected")
    /// Current: @%@
    internal static func currentAccount(_ p1: String) -> String {
      return L10n.tr("Localizable", "currentAccount", p1)
    }
    /// Disconnect
    internal static let disconnect = L10n.tr("Localizable", "disconnect")
    /// Fetch failed
    internal static let fetchFailed = L10n.tr("Localizable", "fetchFailed")
    /// Help / Feedback
    internal static let helpAndFeedback = L10n.tr("Localizable", "helpAndFeedback")
    /// Home Timeline
    internal static let homeTimeline = L10n.tr("Localizable", "homeTimeline")
    /// Lists
    internal static let lists = L10n.tr("Localizable", "lists")
    /// Local Timeline
    internal static let localTimeline = L10n.tr("Localizable", "localTimeline")
    /// My Profile
    internal static let myProfile = L10n.tr("Localizable", "myProfile")
    /// Not connected
    internal static let notConnected = L10n.tr("Localizable", "notConnected")
    /// Nothing more
    internal static let nothingMore = L10n.tr("Localizable", "nothingMore")
    /// Notifications
    internal static let notifications = L10n.tr("Localizable", "notifications")
    /// Others
    internal static let other = L10n.tr("Localizable", "other")
    /// Post
    internal static let post = L10n.tr("Localizable", "post")
    /// Read more
    internal static let readmore = L10n.tr("Localizable", "readmore")
    /// Refresh
    internal static let refetch = L10n.tr("Localizable", "refetch")
    /// Settings
    internal static let settings = L10n.tr("Localizable", "settings")
    /// Streaming
    internal static let streaming = L10n.tr("Localizable", "streaming")
    /// Status: %@
    internal static func streamingStatus(_ p1: String) -> String {
      return L10n.tr("Localizable", "streamingStatus", p1)
    }
    /// Switch active account
    internal static let switchActiveAccount = L10n.tr("Localizable", "switchActiveAccount")
    internal enum Error {
      /// Please input instance.
      internal static let pleaseInputInstance = L10n.tr("Localizable", "error.pleaseInputInstance")
      /// This feature requires Mastodon %@ or higher.
      internal static func requiredNewerMastodon(_ p1: String) -> String {
        return L10n.tr("Localizable", "error.requiredNewerMastodon", p1)
      }
      /// This feature requires iOS %.1f or higher.
      internal static func requiredNewerOS(_ p1: Float) -> String {
        return L10n.tr("Localizable", "error.requiredNewerOS", p1)
      }
      /// Error
      internal static let title = L10n.tr("Localizable", "error.title")
    }
    internal enum HomeTimeline {
      /// Home
      internal static let short = L10n.tr("Localizable", "homeTimeline.short")
    }
    internal enum LocalTimeline {
      /// LTL
      internal static let short = L10n.tr("Localizable", "localTimeline.short")
    }
  }
  internal enum Login {
    /// Login
    internal static let loginButton = L10n.tr("Login", "loginButton")
    /// Please input mastodon instance
    internal static let pleaseInputMastodonInstance = L10n.tr("Login", "pleaseInputMastodonInstance")
    /// Login
    internal static let title = L10n.tr("Login", "title")
    internal enum Authorize {
      /// Authorize
      internal static let title = L10n.tr("Login", "authorize.title")
      internal enum Method {
        /// Login with mail address and password
        internal static let mailAndPassword = L10n.tr("Login", "authorize.method.mailAndPassword")
        /// Login with Safari (Recommended)
        internal static let safari = L10n.tr("Login", "authorize.method.safari")
      }
      internal enum Tos {
        /// By login, you agree to follow the rules and privacy policies.
        internal static let header = L10n.tr("Login", "authorize.tos.header")
        /// Rules of this server
        internal static let rules = L10n.tr("Login", "authorize.tos.rules")
        /// Terms of Service of this server
        internal static let termsOfService = L10n.tr("Login", "authorize.tos.termsOfService")
      }
    }
    internal enum PasswordLogin {
      /// Mail address
      internal static let mailAddress = L10n.tr("Login", "passwordLogin.mailAddress")
      /// Password
      internal static let password = L10n.tr("Login", "passwordLogin.password")
    }
    internal enum ProgressDialog {
      /// Fetching server information...
      internal static let fetchingServerInfo = L10n.tr("Login", "progressDialog.fetchingServerInfo")
      /// Please authorize
      internal static let pleaseAuthorize = L10n.tr("Login", "progressDialog.pleaseAuthorize")
      /// Registering app to server...
      internal static let registeringApplication = L10n.tr("Login", "progressDialog.registeringApplication")
      /// Logging in...
      internal static let title = L10n.tr("Login", "progressDialog.title")
    }
    internal enum Welcome {
      /// Welcome,\n%@
      internal static func message(_ p1: String) -> String {
        return L10n.tr("Login", "welcome.message", p1)
      }
    }
  }
  internal enum Notification {
    internal enum Types {
      /// @%@ boosted your toot
      internal static func boost(_ p1: String) -> String {
        return L10n.tr("Notification", "types.boost", p1)
      }
      /// @%@ favorited your toot
      internal static func favourite(_ p1: String) -> String {
        return L10n.tr("Notification", "types.favourite", p1)
      }
      /// @%@ followed you
      internal static func follow(_ p1: String) -> String {
        return L10n.tr("Notification", "types.follow", p1)
      }
      /// @%@ mentioned you
      internal static func mention(_ p1: String) -> String {
        return L10n.tr("Notification", "types.mention", p1)
      }
      /// Unknown Notification: %@
      internal static func unknown(_ p1: String) -> String {
        return L10n.tr("Notification", "types.unknown", p1)
      }
      internal enum Poll {
        /// A poll you voted has ended
        internal static let notowner = L10n.tr("Notification", "types.poll.notowner")
        /// Your poll has ended
        internal static let owner = L10n.tr("Notification", "types.poll.owner")
      }
    }
  }
  internal enum Search {
    /// Search
    internal static let title = L10n.tr("Search", "title")
    internal enum Sections {
      internal enum Accounts {
        /// Accounts
        internal static let title = L10n.tr("Search", "sections.accounts.title")
      }
      internal enum Hashtags {
        /// Hashtags
        internal static let title = L10n.tr("Search", "sections.hashtags.title")
      }
      internal enum Posts {
        /// Posts
        internal static let title = L10n.tr("Search", "sections.posts.title")
      }
      internal enum TrendTags {
        /// Trend tags (Updated: %@)
        internal static func title(_ p1: String) -> String {
          return L10n.tr("Search", "sections.trendTags.title", p1)
        }
      }
    }
  }
  internal enum UserProfile {
    /// Since this user is belonged to another instance, some informations may not be accurate.
    internal static let federatedUserWarning = L10n.tr("UserProfile", "federatedUserWarning")
    /// Profile
    internal static let title = L10n.tr("UserProfile", "title")
    internal enum Actions {
      /// Block
      internal static let block = L10n.tr("UserProfile", "actions.block")
      /// Cancel
      internal static let cancel = L10n.tr("UserProfile", "actions.cancel")
      /// Follow
      internal static let follow = L10n.tr("UserProfile", "actions.follow")
      /// Cancel follow request
      internal static let followRequestCancel = L10n.tr("UserProfile", "actions.followRequestCancel")
      /// Pending follow requests
      internal static let followRequestsList = L10n.tr("UserProfile", "actions.followRequestsList")
      /// Mute
      internal static let mute = L10n.tr("UserProfile", "actions.mute")
      /// Card
      internal static let profileCard = L10n.tr("UserProfile", "actions.profileCard")
      /// Share
      internal static let share = L10n.tr("UserProfile", "actions.share")
      /// Actions
      internal static let title = L10n.tr("UserProfile", "actions.title")
      /// Unblock
      internal static let unblock = L10n.tr("UserProfile", "actions.unblock")
      /// Unfollow
      internal static let unfollow = L10n.tr("UserProfile", "actions.unfollow")
      /// Unmute
      internal static let unmute = L10n.tr("UserProfile", "actions.unmute")
    }
    internal enum Cells {
      internal enum CreatedAt {
        /// Created At
        internal static let title = L10n.tr("UserProfile", "cells.createdAt.title")
      }
      internal enum Followers {
        /// Followers
        internal static let title = L10n.tr("UserProfile", "cells.followers.title")
      }
      internal enum Following {
        /// Following
        internal static let title = L10n.tr("UserProfile", "cells.following.title")
      }
      internal enum Toots {
        /// Toots
        internal static let title = L10n.tr("UserProfile", "cells.toots.title")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
