//
//  MastodonAPI.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/11/06.
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

enum MastodonAPI {
    static func handleHTTPError(_ input: (Data, URLResponse)) throws -> Data {
        if let response = input.1 as? HTTPURLResponse, response.statusCode >= 400 {
            let err: APIError
            do {
                let obj = try JSONDecoder.forMastodonAPI.decode(MastodonErrorResponse.self, from: input.0)
                err = .errorReturned(errorMessage: obj.error, errorHttpCode: response.statusCode)
            } catch {
                print("Failed to parse response as JSON", error)
                throw APIError.unknownResponse(errorHttpCode: response.statusCode, errorString: .init(data: input.0, encoding: .utf8))
            }
            throw err
        }
        return input.0
    }
}
