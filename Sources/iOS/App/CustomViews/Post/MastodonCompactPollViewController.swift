//
//  MastodonCompactPollViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by rinsuki on 2019/07/26.
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

class MastodonCompactPollViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonPost
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    
    let titleLabel = UILabel() ※ { v in
        v.text = "投票"
    }
    
    let expireLabel = UILabel() ※ { v in
        v.text = "n票 / あとn日ぐらい"
        v.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
    }
    
    let descriptionLabel = UILabel() ※ { v in
        v.text = "4択の中から1つ: 選択肢1 / 選択肢2 / 選択肢3 / 選択肢4"
    }
    
    var paddingConstraint: Constraint!
    
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
        view.layer.cornerRadius = 8
        #if os(visionOS)
        view.layer.borderWidth = 1
        #else
        view.layer.borderWidth = 1 / UIScreen.main.scale
        #endif
        view.layer.borderColor = UIColor.gray.cgColor
        
        let stackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [
                titleLabel,
                expireLabel,
            ]) ※ { v in
                v.axis = .horizontal
            },
            descriptionLabel,
        ]) ※ { v in
            v.axis = .vertical
            v.spacing = 4
            v.isUserInteractionEnabled = false
        }
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { snp in
            self.paddingConstraint = snp.width.height.equalToSuperview().offset(-16).constraint
            snp.centerX.centerY.equalToSuperview()
        }
        self.input(input)
    }
    
    override func loadView() {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(self.onTapped), for: .touchUpInside)
        self.view = view
    }
    
    func input(_ input: Input) {
        self.input = input
        guard let poll = input.poll else {
            self.view.isHidden = true
            return
        }
        self.view.isHidden = false
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(Defaults.timelineTextFontsize))
        self.expireLabel.font = UIFont.systemFont(ofSize: CGFloat(Defaults.timelineTextFontsize))
        self.descriptionLabel.font = UIFont.systemFont(ofSize: CGFloat(Defaults.timelineTextFontsize))
        self.paddingConstraint.update(offset: -Defaults.timelineTextFontsize)

        var expireLabelComponents = ["\(poll.votes_count)票"]
        if poll.expired {
            expireLabelComponents.append("締め切り済み")
        } else if let expires = poll.expires_at {
            let trueRemains = expires.timeIntervalSinceNow
            let remains = fabs(trueRemains)
            let finished = trueRemains < 0
            var remainsString: String
            if remains > (24 * 60 * 60 * 1.5) {
                remainsString = "\(Int(remains / (24 * 60 * 60)))日"
            } else if remains > (60 * 60 * 1.5) {
                remainsString = "\(Int(remains / (60 * 60)))時間"
            } else if remains > (60 * 1.5) {
                remainsString = "\(Int(remains / 60))分"
            } else {
                if finished {
                    remainsString = "ちょっと"
                } else {
                    remainsString = "もうすぐ"
                }
            }
            expireLabelComponents.append(finished ? "\(remainsString)前に終わるはずだった" : "あと\(remainsString)ぐらい")
        } else {
            expireLabelComponents.append("期限不定")
        }
        expireLabel.text = expireLabelComponents.joined(separator: " / ")
        descriptionLabel.text = "\(poll.options.count)択の中から\(poll.multiple ? "複数" : "一個")選択 : \(poll.options.map { $0.title }.joined(separator: " / "))"
    }
    
    @objc func onTapped() {
        let newVC = MastodonPostDetailViewController.instantiate(self.input, environment: self.environment)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
}
