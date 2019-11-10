//
//  MastodonPostPollVoteButtonViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by rinsuki on 2019/08/23.
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

import UIKit
import Mew
import Ikemen
import iMastiOSCore

class MastodonPostDetailPollVoteButtonViewController: UIViewController, Instantiatable, Injectable, Interactable {
    typealias Input = (poll: MastodonPoll, selected: [Int])
    typealias Environment = MastodonUserToken
    typealias Output = MastodonPoll
    let environment: Environment
    var input: Input
    var handler: ((Output) -> Void)?
    
    let voteButton = UIButton() ※ { v in
        v.setTitle("投票", for: .normal)
    }
    let votingIndicator = UIActivityIndicatorView(style: .gray)
    var isFirst = true
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(voteButton)
        voteButton.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
        }
        self.view.addSubview(votingIndicator)
        votingIndicator.snp.makeConstraints { make in
            make.center.equalTo(voteButton)
        }
        voteButton.layer.cornerRadius = 8
        voteButton.layer.borderWidth = 1
        voteButton.setTitleColor(.systemGray, for: .disabled)
        voteButton.addTarget(self, action: #selector(self.tapVote), for: .touchUpInside)
        self.input(input)
    }
    
    func input(_ input: Input) {
        self.input = input
        let animateDuration = isFirst ? 0 : 0.1
        isFirst = false
        if input.selected.count > 0 {
            UIView.animate(withDuration: animateDuration) { [weak voteButton] in
                guard let voteButton = voteButton else { return }
                voteButton.isEnabled = true
                voteButton.backgroundColor = self.view.tintColor
                voteButton.layer.borderColor = UIColor.clear.cgColor
            }
        } else {
            UIView.animate(withDuration: animateDuration) { [weak voteButton] in
                guard let voteButton = voteButton else { return }
                voteButton.isEnabled = false
                voteButton.backgroundColor = .clear
                voteButton.layer.borderColor = UIColor.systemGray.cgColor
            }
        }
    }
    
    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
    
    @objc func tapVote(_ sender: UIButton) {
        sender.alpha = 0.125
        votingIndicator.startAnimating()
        environment.vote(poll: input.poll, choices: input.selected).then { [weak self] poll in
            guard let strongSelf = self else { return }
            strongSelf.handler?(poll)
        }
    }
}
