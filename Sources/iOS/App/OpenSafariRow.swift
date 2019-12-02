//
//  OpenSafariRow.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/12/02.
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

import Eureka
import SafariServices

final class OpenSafariRow: _ButtonRowOf<String>, RowType {
    init(title: String, url: URL) {
        super.init(tag: nil)
        self.title = title
        cellStyle = .subtitle
        self.cellUpdate { cell, row in
            cell.detailTextLabel?.text = url.absoluteString
        }
        presentationMode = .presentModally(controllerProvider: .callback(builder: { SFSafariViewController(url: url) }), onDismiss: nil)
    }
    
    required init(tag: String?) {
        fatalError("init(tag:) has not been implemented")
    }
}
