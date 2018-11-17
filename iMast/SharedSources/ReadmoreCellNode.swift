//
//  ReadmoreCellNode.swift
//  iMast
//
//  Created by user on 2018/11/11.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ReadmoreCellNode: ASCellNode {
    enum State {
        case enabled
        case loading
        case nothingMore
        case withError
    }
    let textNode = ASTextNode()
    let indicatorView = UIActivityIndicatorView(style: .gray)
    var indicatorNode: ASDisplayNode!
    var lastError: Error?
    
    var state: State = .enabled { didSet {
        self.textNode.isHidden = state == .loading
        if oldValue != state {
            DispatchQueue.main.async {
                if self.state != .loading {
                    self.indicatorView.stopAnimating()
                } else {
                    self.indicatorView.startAnimating()
                }
            }
            switch state {
            case .enabled:
                self.textNode.attributedText = NSAttributedString(string: R.string.localizable.tabsNotificationsCellReadmoreTitle(), attributes: [
                    .font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: self.tintColor,
                    ])
            case .nothingMore:
                self.textNode.attributedText = NSAttributedString(string: R.string.localizable.tabsNotificationsCellReadmoreDisabledTitle(), attributes: [
                    .font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: UIColor.darkGray,
                    ])
            case .withError:
                self.textNode.attributedText = NSAttributedString(string: R.string.localizable.tabsNotificationsCellReadmoreFetchError(), attributes: [
                    .font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: UIColor.red,
                    ])
            default:
                break
            }
        }
    }}
    
    override init() {
        super.init()
        self.indicatorNode = ASDisplayNode { () -> UIView in
            return self.indicatorView
        }
        
        self.addSubnode(self.textNode)
        self.addSubnode(self.indicatorNode)
        self.style.height = ASDimensionMake(44)
        self.selectionStyle = .none
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASOverlayLayoutSpec(child: ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self.textNode), overlay: self.indicatorNode)
    }
}
