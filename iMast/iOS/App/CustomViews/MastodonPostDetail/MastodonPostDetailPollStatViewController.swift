//
//  MastodonPostDetailPollStatViewController.swift
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
import SnapKit
import iMastiOSCore

class MastodonPostDetailPollStatViewController: UIViewController, Instantiatable, Injectable {
    
    class StatView: UIView {
        let textLabel = UILabel()
        let percentageLabel = UILabel() ※ {
            $0.text = "99.9%"
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        let barView = UIView() ※ {
            $0.backgroundColor = UIColor.systemGray5
        }
        
        var barWidth: Constraint!
        let labelStackView: UIStackView
        init() {
            labelStackView = UIStackView(arrangedSubviews: [textLabel, percentageLabel])
            super.init(frame: .zero)
            self.addSubview(barView)
            self.addSubview(labelStackView)
            barView.layer.cornerRadius = 4
            labelStackView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalToSuperview().inset(4)
                make.height.equalToSuperview().inset(8)
            }
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    typealias Input = MastodonPoll
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    let stackView = UIStackView(arrangedSubviews: []) ※ {
        $0.axis = .vertical
        $0.spacing = 8
    }
    
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
        self.input(input)
    }
    
    override func loadView() {
        self.view = stackView
    }
    
    func input(_ input: Input) {
        while stackView.arrangedSubviews.count < input.options.count {
            stackView.addArrangedSubview(StatView())
        }
        for (i, view) in stackView.arrangedSubviews.enumerated() {
            if i < input.options.count {
                let statView = view as! StatView
                let option = input.options[i]
                statView.textLabel.text = option.title
                let p = input.votes_count != 0 ? Float(option.votes_count) / Float(input.votes_count) : 0
                statView.percentageLabel.text = String(format: "% 3.1f%%", p * 100.0)
                statView.barView.snp.remakeConstraints { make in
                    make.leading.top.bottom.equalToSuperview()
                    make.width.greaterThanOrEqualTo(8)
                    make.width.equalToSuperview().multipliedBy(p).priority(.medium)
                }
            } else {
                view.isHidden = true
            }
        }
    }
}
