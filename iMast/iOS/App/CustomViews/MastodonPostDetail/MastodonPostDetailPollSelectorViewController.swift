//
//  MastodonPostDetailPollSelectorViewController.swift
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

class MastodonPostDetailPollSelectorViewController: UIViewController, Instantiatable, Injectable, Interactable {
    typealias Input = MastodonPoll
    typealias Environment = MastodonUserToken
    typealias Output = [Int]
    let environment: Environment
    var input: Input
    var handler: ((Output) -> Void)?
    var selected: [Int] = []
    
    let buttonStackView = UIStackView() ※ { v in
        v.axis = .vertical
        v.spacing = 8
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
        self.view = self.buttonStackView
    }
    
    func input(_ input: Input) {
        self.input = input
        while buttonStackView.arrangedSubviews.count < input.options.count {
            let button = UIButton()
            button.layer.cornerRadius = 8
            button.layer.borderColor = self.view.tintColor.cgColor
            button.layer.borderWidth = 1
            button.setTitleColor(self.view.tintColor, for: .normal)
            button.tag = buttonStackView.arrangedSubviews.count
            button.addTarget(self, action: #selector(self.tapOption(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        for (i, view) in buttonStackView.arrangedSubviews.enumerated() {
            if i < input.options.count {
                let button = view as! UIButton
                let option = input.options[i]
                button.setTitle(option.title, for: .normal)
            } else {
                view.isHidden = true
            }
        }
    }
    
    @objc func tapOption(_ sender: UIButton) {
        let tag = sender.tag
        let animateDuration = 0.1
        if let index = selected.firstIndex(of: tag) { // 選択されている (ので外す)
            selected.remove(at: index)
            UIView.animate(withDuration: animateDuration) {
                sender.setTitleColor(self.view.tintColor, for: .normal)
                sender.backgroundColor = nil
            }
        } else { // 選択されていない (ので選択する)
            if input.multiple == false, selected.count > 0 { // 単数選択で、なおかつ他のが既に選択済みだったら他のを外す
                for tag in selected {
                    let button = buttonStackView.arrangedSubviews[tag] as! UIButton
                    UIView.animate(withDuration: animateDuration) {
                        button.setTitleColor(self.view.tintColor, for: .normal)
                        button.backgroundColor = nil
                    }
                }
                selected = []
            }
            UIView.animate(withDuration: animateDuration) {
                sender.setTitleColor(.white, for: .normal)
                sender.backgroundColor = self.view.tintColor
            }
            selected.append(tag)
        }
        self.handler?(selected)
    }
    
    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
}
