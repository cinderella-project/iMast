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
    var loopEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let playerItem = player?.currentItem {
            NotificationCenter.default.addObserver(self, selector: #selector(loop), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func loop() {
        guard loopEnabled else {
            return
        }
        player?.seek(to: .zero)
        player?.play()
    }
}
