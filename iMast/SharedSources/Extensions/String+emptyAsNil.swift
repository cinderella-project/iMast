//
//  String+emptyAsNil.swift
//  iMast
//
//  Created by user on 2019/03/12.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

extension String {
    var emptyAsNil: String? {
        return self.count == 0 ? nil : self
    }
}
