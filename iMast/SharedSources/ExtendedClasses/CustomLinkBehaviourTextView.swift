//
//  CustomLinkBehaviourTextView.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/09/28.
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

protocol CustomLinkBehaviourTextViewDelegate: class {
    func linkClickedCallback(textView: CustomLinkBehaviourTextView, url: URL, label: NSAttributedString) -> (() -> Void)?
}

/// iOS 13.1 beta 4以降にあるtouchDownでリンクが踏まれたことにされてしまうバグを修正するTextView
class CustomLinkBehaviourTextView: UITextView {
    weak var linkDelegate: CustomLinkBehaviourTextViewDelegate?
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        addGestureRecognizer(gesture)
        gesture.delegate = self
        gesture.isEnabled = true
    }
    
    var interactedCallback: (Date, () -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomLinkBehaviourTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let callback = linkDelegate?.linkClickedCallback(
            textView: self,
            url: URL,
            label: attributedText.attributedSubstring(from: characterRange)
        ) {
            if Defaults[.workaroundOfiOS13_1UITextView] {
                interactedCallback = (Date(), callback)
            } else {
                callback()
            }
            return false
        }
        return true
    }
}

extension CustomLinkBehaviourTextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func onTapped() {
        guard let (date, callback) = interactedCallback else { return }
        guard date.timeIntervalSinceNow > -0.3 else { return }
        callback()
        interactedCallback = nil
    }
}
