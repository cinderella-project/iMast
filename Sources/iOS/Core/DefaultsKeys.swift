//
//  Defaultskeys.swift
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

public extension DefaultsKeys {
    static let streamingAutoConnect = DefaultsKey<String>("streaming_autoconnect", default: "always")
    static let appendMediaUrl = DefaultsKey<Bool>("append_mediaurl", default: true)
    static let newAccountVia = DefaultsKey<String>("new_account_via", default: "iMast")
    static let followRelationshipsOld = DefaultsKey<Bool>("follow_relationships_old", default: false)
    @available(*, unavailable)
    static let workaroundOfiOS13_1UITextView = DefaultsKey<Bool>(
        "workaroundOfiOS13_1UITextView",
         default: [
            "13.1",
            "13.1.1",
            "13.1.2",
            "13.1.3",
         ].firstIndex(of: UIDevice.current.systemVersion) != nil
    )

    static let timelineUsernameFontsize = DefaultsKey<Double>("timeline_username_fontsize", default: 14)
    static let timelineTextFontsize = DefaultsKey<Double>("timeline_text_fontsize", default: 15)
    static let timelineIconSize = DefaultsKey<Double>("timeline_icon_size", default: 48)
    static let visibilityEmoji = DefaultsKey<Bool>("visibility_emoji", default: true)
    static let thumbnailHeight = DefaultsKey<Double>("thumbnail_height", default: 50)
    static let timelineTextBold = DefaultsKey<Bool>("timeline_text_bold", default: false)
    static let pinnedTootLinesLimit = DefaultsKey<Double>("pinned_toot_lines_limit", default: 0)
    static let inReplyToEmoji = DefaultsKey<Bool>("in_reply_to_emoji", default: true)
    static let acctAbbr = DefaultsKey<Bool>("acct_abbr", default: true)
    static let postFabEnabled = DefaultsKey<Bool>("post_fab_enabled", default: true)
    static let postFabLocation = DefaultsKey<PostFabLocation>("post_fab_location", default: .rightBottom)
    static let usePostLanguageInfo = DefaultsKey<Bool>("use_post_language_info", default: true)

    static let webmVlcOpen = DefaultsKey<Bool>("webm_vlc_open", default: true)
    static let useAVPlayer = DefaultsKey<Bool>("use_avplayer", default: true)
    static let useUniversalLink = DefaultsKey<Bool>("use_universal_link", default: true)

    static let nowplayingFormat = DefaultsKey<String>("nowplaying_format", default: "#nowplaying {title} - {artist} ({albumTitle})")
    static let nowplayingAddAppleMusicUrl = DefaultsKey<Bool>("nowplaying_add_apple_music_url", default: true)
    static let autoResizeSize = DefaultsKey<Int>("autoResizeSize", default: 0)
    static let usingDefaultVisibility = DefaultsKey<Bool>("using_default_visibility", default: false)

    static let shareNoTwitterTracking = DefaultsKey<Bool>("share_no_twitter_tracking", default: true)
    static let shareNoSpotifySIParameter = DefaultsKey<Bool>("share_no_spotify_si_parameter", default: false)
    static let deleteTootTeokure = DefaultsKey<Bool>("delete_toot_teokure", default: false)

    static let usingNowplayingFormatInShareGooglePlayMusicUrl = DefaultsKey<Bool>("using_nowplaying_format_in_share_google_play_music_url", default: false)
    static let usingNowplayingFormatInShareSpotifyUrl = DefaultsKey<Bool>("using_nowplaying_format_in_share_spotify_url", default: false)
    static let useCustomizedSharePreview = DefaultsKey<Bool>("use_customized_share_preview", default: true)

    static let showPushServiceError = DefaultsKey<Bool>("show_push_service_error", default: false)
    
    static let groupNotifyAccounts = DefaultsKey<Bool>("group_notify_accounts", default: true)
    static let groupNotifyTypeBoost = DefaultsKey<Bool>("group_notify_type_boost", default: false)
    static let groupNotifyTypeFavourite = DefaultsKey<Bool>("group_notify_type_favourite", default: false)
    static let groupNotifyTypeMention = DefaultsKey<Bool>("group_notify_type_mention", default: false)
    static let groupNotifyTypeFollow = DefaultsKey<Bool>("group_notify_type_follow", default: false)
    static let groupNotifyTypeUnknown = DefaultsKey<Bool>("group_notify_type_unknown", default: false)
    
    static let newHtmlParser = DefaultsKey<Bool>("new_html_parser", default: true)
    static let notifyTabInfiniteScroll = DefaultsKey<Bool>("notify_tab_infinite_scroll", default: false)
    static let newFirstScreen = DefaultsKey<Bool>("new_first_screen", default: false)
    static let skipUniversalLinksCussionPage = DefaultsKey<Bool>("skip_universal_links_cussion_page", default: true)
    
    static let useCustomBoostSound = DefaultsKey<Bool>("use_custom_boost_sound", default: false)
    static let useCustomFavouriteSound = DefaultsKey<Bool>("use_custom_favourite_sound", default: false)
}
