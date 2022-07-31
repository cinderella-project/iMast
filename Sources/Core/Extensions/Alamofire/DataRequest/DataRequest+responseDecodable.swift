//
//  DataRequest+responseDecodable.swift
//  iMast
//
//  Created by rinsuki on 2018/07/31.
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
import Alamofire

extension Alamofire.DataRequest {
    public enum DecodableError: Error {
        case httpError(message: String, code: Int)
    }
    
    public func responseData() async throws -> (Data, HTTPURLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            self.responseData(queue: nil) { res in
                switch res.result {
                case .success(let data):
                    continuation.resume(returning: (data, res.response!))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func responseDecodable<T: Decodable>() async throws -> T {
        let (data, response) = try await responseData()
        if response.statusCode >= 400 {
            throw DecodableError.httpError(
                message: String(data: data, encoding: .utf8) ?? "(不明)",
                code: response.statusCode
            )
        }
        return try JSONDecoder.forMastodonAPI.decode(T.self, from: data)
    }
}

extension Alamofire.DataRequest.DecodableError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .httpError(let message, let code):
            return "\(message) (HTTP-\(code),inDE)"
        }
    }
}
