//
//  Hydra+promiseAsync.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/07/31.
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

import Hydra

public extension Promise {
    func wait() async throws -> Value {
        return try await withCheckedThrowingContinuation { continuation in
            then {
                continuation.resume(returning: $0)
            }.catch {
                continuation.resume(throwing: $0)
            }
        }
    }
}

public func asyncPromise<T>(_ callback: @escaping () async throws -> T) -> Promise<T> {
    return Promise { resolve, reject, _ in
        Task {
            do {
                resolve(try await callback())
            } catch {
                reject(error)
            }
        }
    }
}
