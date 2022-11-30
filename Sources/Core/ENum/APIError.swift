//
//  APIError.swift
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

import Foundation

public enum APIError: Error {
    case `nil`(String)
    case alreadyError // すでにエラーをユーザーに伝えているときに使う
    case errorReturned(errorMessage: String, errorHttpCode: Int) // APIがまともにエラーを返してきた場合
    case unknownResponse(errorHttpCode: Int, errorString: String?) // APIがJSONではない何かを返してきた場合
    case decodeFailed // 画像のデコードに失敗したときのエラー
    case dateParseFailed(dateString: String)
}
