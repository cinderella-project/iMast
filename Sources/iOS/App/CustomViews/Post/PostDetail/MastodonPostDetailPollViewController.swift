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
import iMastiOSCore

class MastodonPostDetailPollViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonPost
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    let selectorVC: MastodonPostDetailPollSelectorViewController
    let voteButtonVC: MastodonPostDetailPollVoteButtonViewController
    let statVC: MastodonPostDetailPollStatViewController
    let voteCountLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .footnote)
    }
    let voteExpiresLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .footnote)
    }
    var voteLabelStackView: UIStackView!
    var selected: [Int] = []
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        self.selectorVC = .instantiate(input.poll!, environment: environment)
        self.voteButtonVC = .instantiate((poll: input.poll!, selected: []), environment: environment)
        self.statVC = .instantiate(input.poll!, environment: environment)
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
        let mainStackView = ContainerView() ※ { v in
            v.addArrangedViewController(selectorVC, parentViewController: self)
            v.addArrangedViewController(statVC, parentViewController: self)
            v.addArrangedSubview(ContainerView() ※ { v in
                v.addArrangedSubview(voteLabelStackView)
                v.addArrangedViewController(voteButtonVC, parentViewController: self)
                v.axis = .horizontal
                v.spacing = 8
            })
            v.axis = .vertical
            v.spacing = 8
        }
        self.view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.center.width.equalTo(view.readableContentGuide)
            make.height.equalTo(view).inset(8)
        }

        selectorVC.output { [weak self] selected in
            guard let strongSelf = self else { return }
            strongSelf.selected = selected
            strongSelf.voteButtonVC.input((strongSelf.input.poll!, selected))
        }
        
        voteButtonVC.output { [weak self] poll in
            guard let strongSelf = self else { return }
            var newInput = strongSelf.input
            newInput.poll = poll
            strongSelf.input(newInput)
        }

        self.input(input)
    }
    
    func input(_ input: Input) {
        let poll = input.poll!
        let canVotable = !(poll.voted || poll.expired)
        voteCountLabel.text = "\(poll.votes_count)票 / \(poll.multiple ? "複数選択" : "一つ選択")"
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
        selectorVC.view.isHidden = !canVotable
        voteButtonVC.view.isHidden = !canVotable
        statVC.view.isHidden = canVotable
        if canVotable {
            selectorVC.input(poll)
        } else {
            statVC.input(poll)
        }
    }
}
