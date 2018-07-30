//
//  MastodonCursorWrapper.swift
//  iMast
//
//  Created by user on 2018/07/31.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation

struct MastodonCursorWrapper<T> {
    var result: T

    var max: MastodonID?
    var since: MastodonID?
}
