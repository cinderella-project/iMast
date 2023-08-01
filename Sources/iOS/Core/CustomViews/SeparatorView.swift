//
//  SeparatorView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2022/08/20.
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

public class SeparatorView: UIView {
    private var exactOnePixelHeightConstraint: NSLayoutConstraint!
    
    public init() {
        super.init(frame: .zero)
        backgroundColor = .opaqueSeparator
        translatesAutoresizingMaskIntoConstraints = false
        exactOnePixelHeightConstraint = heightAnchor.constraint(equalToConstant: 1)
        exactOnePixelHeightConstraint.isActive = true
        traitCollectionDidChange(nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        exactOnePixelHeightConstraint.constant = 1 / traitCollection.displayScale
    }
}
