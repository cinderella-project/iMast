//
//  UITextFieldWithInsets.swift
//  iMast
//
//  Created by user on 2019/07/06.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit

@IBDesignable
class UITextFieldWithInsets: UITextField {
    @IBInspectable
    var containerInsets: CGSize = .zero
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: containerInsets.width, dy: containerInsets.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: containerInsets.width, dy: containerInsets.height)
    }
}
