//
//  LoopableAVPlayerViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/11/25.
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

import AVKit

class LoopableAVPlayerViewController: AVPlayerViewController {
    var observer: NSObjectProtocol?
    var isLoop: Bool = false {
        didSet {
            if self.isViewLoaded {
                if isLoop {
                    self.loopEnable()
                } else {
                    self.loopDisable()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isLoop {
            self.loopEnable()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.loopDisable()
    }
    
    func loopEnable() {
        guard let playerItem = self.player?.currentItem else {
            print("item not found")
            return
        }
        if self.observer != nil {
            print("already enabled...")
        }
        self.observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { notification in
            self.player?.seek(to: .zero)
            self.player?.play()
        }
    }
    
    func loopDisable() {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
}
