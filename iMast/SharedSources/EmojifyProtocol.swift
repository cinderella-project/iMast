//
//  EmojifyProtocol.swift
//  iMast
//
//  Created by user on 2019/03/20.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

protocol EmojifyProtocol {
    var emojis: [MastodonCustomEmoji]? { get }
    var profileEmojis: [MastodonCustomEmoji]? { get }
}
