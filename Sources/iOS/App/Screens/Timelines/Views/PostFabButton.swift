//
//  PostFabButton.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2020/03/25.
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

class PostFabButton: UIButton {
    init() {
        super.init(frame: .zero)
        setImage(UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24)), for: .normal)
        backgroundColor = tintColor
        tintColor = .white
        
        let size = 56
        snp.makeConstraints { make in make.size.equalTo(size) }
        layer.cornerRadius = CGFloat(size / 2)

        layer.shadowOpacity = 0.25
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        isPointerInteractionEnabled = true
        pointerStyleProvider = { [unowned self] button, effect, shape in
            return .init(effect: effect, shape: .roundedRect(self.frame, radius: self.layer.cornerRadius))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
