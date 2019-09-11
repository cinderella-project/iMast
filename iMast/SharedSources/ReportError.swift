//
//  ReportError.swift
//  iMast
//
//  Created by rinsuki on 2018/01/11.
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
//

import Foundation
import UIKit

func reportError(error: Error) {
    guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) else { return }
    guard let windowScene = scene as? UIWindowScene else { return }
    windowScene.windows.first?.rootViewController?.alert(title: "内部エラー", message: "お手数ですが、以下のエラーメッセージを@imast_ios@mstdn.rinsuki.netまでスクリーンショットでお伝えください。\n\(error)")
    print(error)
}
