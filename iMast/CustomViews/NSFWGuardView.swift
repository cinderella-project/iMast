//
//  NSFWGuardView.swift
//  iMast
//
//  Created by user on 2018/04/29.
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

import UIKit
import ActionClosurable

class NSFWGuardView: UIView {
    
    var explicitlyOpened = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        self.setup()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setup() {
        
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(blurEffectView)
            self.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: blurEffectView.centerYAnchor).isActive = true
            self.widthAnchor.constraint(equalTo: blurEffectView.widthAnchor).isActive = true
            self.heightAnchor.constraint(equalTo: blurEffectView.heightAnchor).isActive = true
        } else {
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        }
        
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        
        let warnTitle = UILabel()
        warnTitle.text = "閲覧注意"
        warnTitle.textColor = .white
        stackView.addArrangedSubview(warnTitle)
        
        warnTitle.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        stackView.frame = self.frame

        self.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let touchGesture = UITapGestureRecognizer { _ in
            self.isHidden = true
            self.isUserInteractionEnabled = false
            self.explicitlyOpened = true
        }

        self.addGestureRecognizer(touchGesture)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
