//
//  Defaults.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/11/10.
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

import UIKit

public class Defaults {
    @DefaultsKey("streaming_autoconnect") public static var streamingAutoConnect: String = "always"
    // @available(*, unavailable) @DefaultsKey("append_mediaurl") public static var appendMediaUrl: Bool = true
    @DefaultsKey("new_account_via") public static var newAccountVia: String = "iMast"
    @DefaultsKey("follow_relationships_old") public static var followRelationshipsOld: Bool = false
    /*
    @available(*, unavailable)
    @DefaultsKey("workaroundOfiOS13_1UITextView") public static var workaroundOfiOS13_1UITextView: Bool = [
        "13.1",
        "13.1.1",
        "13.1.2",
        "13.1.3",
    ].firstIndex(of: UIDevice.current.systemVersion) != nil
     */

    @DefaultsKey("timeline_username_fontsize") public static var timelineUsernameFontsize: Double = 14
    @DefaultsKey("timeline_text_fontsize") public static var timelineTextFontsize: Double = 15
    @DefaultsKey("timeline_icon_size") public static var timelineIconSize: Double = 48
    @DefaultsKey("visibility_emoji") public static var visibilityEmoji: Bool = true
    @DefaultsKey("thumbnail_height") public static var thumbnailHeight: Double = 50
    @DefaultsKey("timeline_text_bold") public static var timelineTextBold: Bool = false
    // @available(*, unavailable) @DefaultsKey("pinned_toot_lines_limit") public static var pinnedTootLinesLimit: Double = 0
    @DefaultsKey("in_reply_to_emoji") public static var inReplyToEmoji: Bool = true
    @DefaultsKey("acct_abbr") public static var acctAbbr: Bool = true
    @DefaultsKey("post_fab_enabled") public static var postFabEnabled: Bool = true
    @DefaultsKeyRawRepresentable("post_fab_location") public static var postFabLocation: PostFabLocation = .rightBottom
    @DefaultsKey("use_post_language_info") public static var usePostLanguageInfo: Bool = true

    @DefaultsKey("webm_vlc_open") public static var webmVlcOpen: Bool = true
    @DefaultsKey("use_avplayer") public static var useAVPlayer: Bool = true
    @DefaultsKey("use_universal_link") public static var useUniversalLink: Bool = true

    @DefaultsKey("nowplaying_format") public static var nowplayingFormat: String = "#nowplaying {title} - {artist} ({albumTitle})"
    @DefaultsKey("nowplaying_add_apple_music_url") public static var nowplayingAddAppleMusicUrl: Bool = true
    @DefaultsKey("autoResizeSize") public static var autoResizeSize: Int = 0
    @DefaultsKey("using_default_visibility") public static var usingDefaultVisibility: Bool = false

    @DefaultsKey("share_no_twitter_tracking") public static var shareNoTwitterTracking: Bool = true
    @DefaultsKey("share_no_spotify_si_parameter") public static var shareNoSpotifySIParameter: Bool = false
    @DefaultsKey("delete_toot_teokure") public static var deleteTootTeokure: Bool = false

    // @available(*, unavailable) @DefaultsKey("using_nowplaying_format_in_share_google_play_music_url") public static var usingNowplayingFormatInShareGooglePlayMusicUrl: Bool = false
    @DefaultsKey("using_nowplaying_format_in_share_spotify_url") public static var usingNowplayingFormatInShareSpotifyUrl: Bool = false
    // @available(*, unavailable) @DefaultsKey("use_customized_share_preview") public static var useCustomizedSharePreview: Bool = true

    @DefaultsKey("show_push_service_error") public static var showPushServiceError: Bool = false
    
    @DefaultsKey("group_notify_accounts") public static var groupNotifyAccounts: Bool = true
    @DefaultsKey("group_notify_type_boost") public static var groupNotifyTypeBoost: Bool = false
    @DefaultsKey("group_notify_type_favourite") public static var groupNotifyTypeFavourite: Bool = false
    @DefaultsKey("group_notify_type_mention") public static var groupNotifyTypeMention: Bool = false
    @DefaultsKey("group_notify_type_follow") public static var groupNotifyTypeFollow: Bool = false
    @DefaultsKey("group_notify_type_unknown") public static var groupNotifyTypeUnknown: Bool = false
    
    // @available(*, unavailable) @DefaultsKey("new_html_parser") public static var newHtmlParser: Bool = true
    @DefaultsKey("notify_tab_infinite_scroll") public static var notifyTabInfiniteScroll: Bool = false
    @DefaultsKey("new_first_screen") public static var newFirstScreen: Bool = false
    // @available(*, unavailable) @DefaultsKey("skip_universal_links_cussion_page") public static var skipUniversalLinksCussionPage: Bool = true
    
    @DefaultsKey("use_custom_boost_sound") public static var useCustomBoostSound: Bool = false
    @DefaultsKey("use_custom_favourite_sound") public static var useCustomFavouriteSound: Bool = false
    @DefaultsKey("communication_notifications_enabled") public static var communicationNotificationsEnabled: Bool = false
    @DefaultsKey("open_as_half_modal_from_timeline") public static var openAsHalfModalFromTimeline: Bool = false
    
    #if os(visionOS)
    @DefaultsKey("open_as_another_window") public static var openAsAnotherWindow: Bool = true
    #else
    @DefaultsKey("open_as_another_window") public static var openAsAnotherWindow: Bool = false
    #endif

    @DefaultsKey("workaround_of_ios16_textkit2_wont_updates_link_color") public static var workaroundOfiOS16_TextKit2_WontUpdatesLinkColor = true
}
