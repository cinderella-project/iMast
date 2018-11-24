//
//  LoopableAVPlayerViewController.swift
//  iMast
//
//  Created by user on 2018/11/25.
//  Copyright © 2018 rinsuki. All rights reserved.
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
