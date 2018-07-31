//
//  Alamofire.Request+responseDecodable.swift
//  iMast
//
//  Created by user on 2018/07/31.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import Foundation
import Alamofire
import Hydra

extension Alamofire.DataRequest {
    enum DecodableError: Error {
        case httpError(message: String, code: Int)
    }
    
    
    func responseDecodable<T: Decodable>(_ type: T.Type) -> Promise<T> {
        return Promise<T> { resolve, reject, _ in
            self.responseData { res in
                switch res.result {
                case .success(let value):
                    if res.response?.statusCode ?? 499 >= 400 {
                        reject(DecodableError.httpError(
                            message: String(data: value, encoding: .utf8) ?? "(不明)",
                            code: res.response?.statusCode ?? 499
                        ))
                        return
                    }
                    do {
                        resolve(try JSONDecoder.get().decode(type, from: value))
                    } catch {
                        reject(error)
                    }
                case .failure(let error):
                    reject(error)
                }
            }
        }
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
