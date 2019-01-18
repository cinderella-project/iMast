//
//  FourCharCode+toString.swift
//  iMast
//
//  Created by user on 2019/01/18.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

extension FourCharCode {
    func toString() -> String {
        let bytes: [CChar] = [
            CChar((self >> 24) & 0xFF),
            CChar((self >> 16) & 0xFF),
            CChar((self >> 8) & 0xFF),
            CChar(self & 0xFF),
            0
        ]
        let result = String(cString: bytes)
        let charset = CharacterSet.whitespaces
        return result.trimmingCharacters(in: charset)
    }
}
