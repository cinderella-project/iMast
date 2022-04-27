//
//  ImageCache.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/04/28.
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
import SDWebImage

#if canImport(UIKit)
import UIKit

@MainActor
var uiImageViewLastLoadingURL = NSMapTable<UIImageView, NSURL>(keyOptions: [.weakMemory], valueOptions: [])
var uiImageViewCancelToken = NSMapTable<UIImageView, SDWebImageOperation>(keyOptions: [.weakMemory], valueOptions: [])

public extension UIImageView {
    @MainActor
    func loadImage(from url: URL?, callback: (() -> Void)? = nil) {
        guard let url = url as? NSURL else {
            NSLog("overwrite image with URL nil")
            image = nil
            uiImageViewLastLoadingURL.removeObject(forKey: self)
            if let oldOne = uiImageViewCancelToken.object(forKey: self) {
                oldOne.cancel()
                uiImageViewCancelToken.removeObject(forKey: self)
            }
            return
        }
        if uiImageViewLastLoadingURL.object(forKey: self) == url {
            // already trying to load it
            return
        }
        uiImageViewLastLoadingURL.setObject(url, forKey: self)
        if let oldOne = uiImageViewCancelToken.object(forKey: self) {
            oldOne.cancel()
        }
        image = nil
        let cancellable = SDWebImageManager.shared.loadImage(with: url as URL, options: [], progress: nil) { [weak self] image, _, _, _, _, _  in
            guard let self = self else {
                return
            }
            if uiImageViewLastLoadingURL.object(forKey: self) == url {
                uiImageViewLastLoadingURL.removeObject(forKey: self)
                uiImageViewCancelToken.removeObject(forKey: self)
                self.image = image
                callback?()
            } else {
                NSLog("cancelled...", self, url)
            }
        }
        uiImageViewCancelToken.setObject(cancellable, forKey: self)
    }
}

#endif
