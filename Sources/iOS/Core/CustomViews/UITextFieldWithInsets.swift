//
//  UITextFieldWithInsets.swift
//  iMast
//
//  Created by rinsuki on 2019/07/06.
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

@IBDesignable
public class UITextFieldWithInsets: UITextField {
    @IBInspectable
    public var containerInsets: CGSize = .zero
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: containerInsets.width, dy: containerInsets.height)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: containerInsets.width, dy: containerInsets.height)
    }
}
