//
//  AttachedMediaViewController.swift
//  iMast
//
//  Created by rinsuki on 2019/03/19.
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

import UIKit
import Mew
import Ikemen
import AVFoundation
import iMastiOSCore

class AttachedMediaListViewController: UIViewController, Instantiatable, Injectable, Interactable {
    typealias Input = MastodonPostContentProtocol
    typealias Environment = Void
    enum Output {
        case show
        case hide
    }
    var input: Input
    var environment: Environment
    var output: Output = .show {
        didSet {
            if output != oldValue {
                let isShow = output == .show
                guardViewLeadingConstraint.isActive = isShow
                guardViewTrailingConstraint.isActive = !isShow
            }
            self.setText()
        }
    }
    var outputHandler: ((Output) -> Void)?
    var guardViewLeadingConstraint: NSLayoutConstraint!
    var guardViewTrailingConstraint: NSLayoutConstraint!

    let guardView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let guardTextLabel = UILabel(frame: .zero) ※ {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.text = ">>"
    }
    
    let mediaStackView = UIStackView() ※ {
        $0.axis = .vertical
        $0.spacing = 8
    }
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func output(_ handler: ((AttachedMediaListViewController.Output) -> Void)?) {
        self.outputHandler = handler
    }

    func setText() {
        switch output {
        case .show:
            guardTextLabel.text = ">>"
        case .hide:
            if input.sensitive {
                guardTextLabel.text = "閲覧注意"
            } else {
                guardTextLabel.text = "非表示にしたメディア"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.ignoreSmartInvert()
        
        let leftButtonWidth = 48
        
        self.view.addSubview(mediaStackView)
        mediaStackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(leftButtonWidth + 8)
        }
        
        self.view.addSubview(guardView)
        guardView.isUserInteractionEnabled = true
        guardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.guardViewTapped)))
        guardView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
        guardViewTrailingConstraint = guardView.trailingAnchor.constraint(equalTo: mediaStackView.trailingAnchor, constant: 0)
        guardViewLeadingConstraint = guardView.trailingAnchor.constraint(equalTo: mediaStackView.leadingAnchor, constant: -8) ※ {
            $0.isActive = true
        }

        guardView.contentView.addSubview(guardTextLabel)
        guardTextLabel.snp.makeConstraints { make in
            make.width.centerX.centerY.equalToSuperview()
        }
        
        self.view.sendSubviewToBack(mediaStackView)
        input(input)
    }

    func input(_ input: Input) {
        self.input = input
        self.output = input.sensitive ? .hide : .show
        self.outputHandler?(self.output)
        
        if input.attachments.count == 0 {
            self.view.isHidden = true
            return
        } else {
            self.view.isHidden = false
        }
        
        let thumbnailHeight = Defaults.thumbnailHeight
        
        // mediaStackView内のimageViewのストックが足りなかったら追加する
        while mediaStackView.arrangedSubviews.count < input.attachments.count {
            let imageView = UIImageView() ※ {
                $0.ignoreSmartInvert()
                $0.contentMode = .scaleAspectFill
                $0.clipsToBounds = true
                $0.snp.makeConstraints { make in
                    make.height.equalTo(thumbnailHeight)
                }
                $0.tag = mediaStackView.arrangedSubviews.count
                $0.isUserInteractionEnabled = true
                $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(target:))))
            }
            mediaStackView.addArrangedSubview(imageView)
        }
        
        for (i, media) in input.attachments.enumerated() {
            // swiftlint:disable:next force_cast
            let imageView = mediaStackView.arrangedSubviews[i] as! UIImageView
            imageView.image = nil
            if let previewURL = media.previewUrl {
                imageView.loadImage(from: URL(string: previewURL))
            }
            imageView.isHidden = false
        }
        
        // 越えてるストックは非表示にしておく
        for view in mediaStackView.arrangedSubviews[input.attachments.count...] {
            view.isHidden = true
        }
    }
    
    @objc func guardViewTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            switch self.output {
            case .show:
                self.output = .hide
            case .hide:
                self.output = .show
            }
            self.view.layoutIfNeeded()
            self.guardView.contentView.layoutIfNeeded()
            print("animated")
        }, completion: nil)
    }
    
    @objc func imageTapped(target: UITapGestureRecognizer) {
        guard let imageView = target.view as? UIImageView else {
            return
        }
        print(imageView.tag)
        let media = input.attachments[imageView.tag]
        
        if media.url.hasSuffix("webm") && openVLC(media.url) {
            return
        }
        
        if media.type.shouldUseMediaPlayer, Defaults.useAVPlayer, let url = URL(string: media.url) {
            let item = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: item)
            let viewController = LoopableAVPlayerViewController()
            viewController.player = player
            player.play()
            viewController.loopEnabled = media.type == .gifv
            self.present(viewController, animated: true, completion: nil)
            return
        }

        self.open(url: URL(string: media.url)!)
    }
}
