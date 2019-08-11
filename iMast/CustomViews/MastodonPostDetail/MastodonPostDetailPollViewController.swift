//
//  MastodonPostDetailPollViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by rinsuki on 2019/08/02.
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

class MastodonPostDetailPollViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonPost
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    let buttonStackView = UIStackView() ※ { v in
        v.axis = .vertical
        v.spacing = 8
    }
    let voteCountLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .footnote)
    }
    let voteExpiresLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .footnote)
    }
    let voteButton = UIButton() ※ { v in
        v.setTitle("投票", for: .normal)
    }
    var voteLabelStackView: UIStackView!
    
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
        voteLabelStackView = UIStackView(arrangedSubviews: [
            voteCountLabel ※ { v in
                v.setContentHuggingPriority(.init(rawValue: 1), for: .horizontal)
            },
            voteExpiresLabel,
        ]) ※ { v in
            v.spacing = 4
        }
        let mainStackView = UIStackView(arrangedSubviews: [
            buttonStackView,
            UIStackView(arrangedSubviews: [
                voteLabelStackView,
                voteButton,
            ]) ※ { v in
                v.axis = .horizontal
            },
        ]) ※ { v in
            v.axis = .vertical
        }
        self.view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.center.size.equalTo(view.readableContentGuide)
        }
        voteButton.backgroundColor = self.view.tintColor
        self.input(input)
    }
    
    func input(_ input: Input) {
        let poll = input.poll!
        let canVotable = !(poll.voted || poll.expired)
        voteCountLabel.text = "\(poll.votes_count)票"
        if poll.expired {
            voteExpiresLabel.text = "締め切り済み"
        } else if let expires = poll.expires_at {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            voteExpiresLabel.text = formatter.string(from: expires) + "まで"
        } else {
            voteExpiresLabel.text = "無期限"
        }
        voteLabelStackView.axis = canVotable ? .vertical : .horizontal
        voteButton.isHidden = !canVotable
    }
}
