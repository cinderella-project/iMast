//
//  TopDeckViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2023/10/06.
//
//  ------------------------------------------------------------------------
//
//  Copyright 2017-2021 rinsuki and other contributors.
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
import iMastiOSCore
import Ikemen

class TopDeckViewController: UIViewController {
    let scrollView = UIScrollView(frame: .zero)
    let stackView = UIStackView(arrangedSubviews: []) ※ {
        $0.spacing = 1
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.backgroundColor = .separator
    }
    
    override func loadView() {
        view = .init()
        view.addSubview(scrollView)
        view.backgroundColor = .secondarySystemBackground
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.top.bottom.equalTo(view)
        }
        
        let pinnedScreens = (try? dbQueue.inDatabase(MastodonUserToken.getPinnedScreens)) ?? []
        let userTokens = (try? MastodonUserToken.getAllUserTokens()) ?? []
        
        for screen in pinnedScreens {
            let userToken = userTokens.first(where: { $0.id == screen.userTokenId })!
            let vc = UINavigationController(rootViewController: screen.descriptor.createViewController(with: userToken))
            addChild(vc)
            stackView.addArrangedSubview(vc.view)
            vc.view.snp.makeConstraints { make in
                make.width.equalTo(320)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
