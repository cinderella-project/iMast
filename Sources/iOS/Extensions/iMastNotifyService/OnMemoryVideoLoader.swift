//
//  OnMemoryVideoLoader.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2025/02/19.
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
import AVFoundation
import os

class OnMemoryVideoLoader: NSObject, AVAssetResourceLoaderDelegate {
    let data: Data
    let logger = Logger(subsystem: "jp.pronama.iMastNotifyService", category: "OnMemoryVideoLoader")
    
    init(data: Data) {
        self.data = data
    }
    
    deinit {
        logger.debug("goodbye...")
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if let contentRequest = loadingRequest.contentInformationRequest {
            contentRequest.contentType = "video/mp4" // TODO: use actual value
            contentRequest.contentLength = Int64(data.count)
            contentRequest.isByteRangeAccessSupported = true
        }
        
        if let dataRequest = loadingRequest.dataRequest {
            let subdata = data.subdata(in: Int(dataRequest.requestedOffset)..<Int(dataRequest.requestedOffset) + Int(dataRequest.requestedLength))
            logger.debug("requesting offset=\(dataRequest.requestedOffset), length=\(dataRequest.requestedLength), result=\(subdata.count)")
            dataRequest.respond(with: subdata)
            loadingRequest.finishLoading()
        }
        
        return true
    }
}
