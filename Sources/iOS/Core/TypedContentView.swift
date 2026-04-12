//
//  TypedContentView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2026/04/12.
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

import UIKit

public protocol TypedContentView: UIContentView {
    associatedtype ContentConfiguration: UIContentConfiguration
    
    @MainActor
    var typedConfiguration: ContentConfiguration { get set }
}

public extension TypedContentView {
    @MainActor
    var configuration: any UIContentConfiguration {
        get {
            return typedConfiguration
        }
        set {
            guard let c = configuration as? ContentConfiguration else {
                preconditionFailure()
            }
            typedConfiguration = c
        }
    }
    
    @MainActor func supports(_ configuration: any UIContentConfiguration) -> Bool {
        return configuration is ContentConfiguration
    }
}
