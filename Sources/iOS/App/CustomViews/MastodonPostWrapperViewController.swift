//
//  MastodonPostWrapperViewController.swift
//  iMast
//
//  Created by rinsuki on 2019/07/09.
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
//

import UIKit
import Mew
import iMastiOSCore

class MastodonPostWrapperViewController<
    T: UIViewController & Instantiatable & Injectable
>: UIViewController, Instantiatable, Injectable
where T.Input == MastodonPostCellViewController.Input, T.Environment == MastodonUserToken {
    typealias Input = (id: MastodonID, pinned: Bool)
    typealias Environment = MastodonUserToken
    let environment: Environment
    var input: Input
    let containerViewController: T
    private var observingNow = false
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        self.containerViewController = T(
            with: .init(post: environment.memoryStore.post.container[input.id]!, pinned: input.pinned),
            environment: environment
        )
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addChild(containerViewController)
        containerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerViewController.view)
        self.view.centerXAnchor.constraint(equalTo: containerViewController.view.centerXAnchor).isActive = true
        self.view.centerYAnchor.constraint(equalTo: containerViewController.view.centerYAnchor).isActive = true
        self.view.widthAnchor.constraint(equalTo: containerViewController.view.widthAnchor).isActive = true
        self.view.heightAnchor.constraint(equalTo: containerViewController.view.heightAnchor).isActive = true
        containerViewController.didMove(toParent: self)
        self.input(input)
    }
    
    func input(_ input: Input) {
        if input != self.input {
            environment.memoryStore.post.removeObserver(observer: self, id: self.input.id)
            self.input = input
            self.didChange(environment.memoryStore.post.container[input.id]!)
            self.observingNow = false
        }
        if !self.observingNow {
            environment.memoryStore.post.addObserver(observer: self, selector: #selector(self.didChange(_:)), id: self.input.id)
            self.observingNow = true
        }
    }
    
    @objc func didChange(_ value: Any) {
        let inp = environment.memoryStore.post.container[self.input.id]!
        containerViewController.input(.init(post: inp, pinned: self.input.pinned))
    }
}
