//
//  ReportError.swift
//  iMast
//
//  Created by user on 2018/01/11.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import UIKit

func reportError(error: DecodingError) {
    UIApplication.shared.viewController?.alert(title: "内部エラー", message: "お手数ですが、以下のエラーメッセージを@imast_ios@mstdn.rinsuki.netまでスクリーンショットでお伝えください。\n\(error)")
    print(error)
}
