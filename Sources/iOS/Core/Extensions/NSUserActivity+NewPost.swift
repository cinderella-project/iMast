//
//  NSUserActivity+NewPost.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2024/02/06.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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

import Foundation
import iMastPackage

extension NSUserActivity {
    public static let activityTypeNewPost = "jp.pronama.imast.private.newpost"

    public static let userInfoKeyUserTokenID = "jp.pronama.imast.private.userTokenID"
    @UserInfoProperty("jp.pronama.imast.private.newpost.suffix") public var newPostSuffix: String?
    @UserInfoProperty("jp.pronama.imast.private.newpost.visibility") public var newPostVisibility: String?
    @UserInfoProperty("jp.pronama.imast.private.newpost.currentText") public var newPostCurrentText: String?
    @UserInfoCodableProperty("jp.pronama.imast.private.newpost.replyPostId") public var newPostReplyPostID: MastodonID?
    @UserInfoProperty("jp.pronama.imast.private.newpost.replyPostAcct") public var newPostReplyPostAcct: String?
    @UserInfoProperty("jp.pronama.imast.private.newpost.replyPostText") public var newPostReplyPostText: String?
    
    public convenience init(newPostWithMastodonUserToken userToken: MastodonUserToken) {
        self.init(activityType: NSUserActivity.activityTypeNewPost)
        addUserInfoEntries(from: [
            Self.userInfoKeyUserTokenID: userToken.id,
        ])
    }
    
    public func mastodonUserToken() -> MastodonUserToken? {
        guard let userTokenID = userInfo?[Self.userInfoKeyUserTokenID] as? String else {
            return nil
        }
        
        return MastodonUserToken.initFromId(id: userTokenID)
    }
    
    public func setNewPostReplyInfo(_ post: MastodonPost) {
        newPostReplyPostID = post.id
        newPostReplyPostAcct = post.account.acct
        newPostReplyPostText = post.status
        
        newPostVisibility = post.visibility.rawValue
        var accounts = [post.account.acct]
        var accountsSet = Set<String>()
        accountsSet.insert(post.account.acct)
        if let userToken = mastodonUserToken(), let screenName = userToken.screenName {
            accountsSet.insert(screenName)
        }
        for mention in post.mentions {
            let acct = post.account.acct
            let (inserted, _) = accountsSet.insert(acct)
            if inserted {
                accounts.append(post.account.acct)
            }
        }
        newPostCurrentText = accounts.map { "@\($0) " }.joined()
    }
}
