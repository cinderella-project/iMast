//
//  NSDiffableDataSourceSnapshot+prependItems.swift
//  iMast
//
//  Created by user on 2019/07/03.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit

extension NSDiffableDataSourceSnapshot {
    func prependItems(_ items: [ItemIdentifierType], section: SectionIdentifierType) {
        if let firstItem = self.itemIdentifiers(inSection: section).first {
            self.insertItems(items, beforeItem: firstItem)
        } else {
            self.appendItems(items, toSection: section)
        }
    }
}
