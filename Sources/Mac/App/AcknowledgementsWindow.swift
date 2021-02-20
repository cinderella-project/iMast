//
//  AcknowledgementsWindow.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2021/02/16.
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

import Cocoa
import Ikemen

private class NoBackgroundScroller: NSScroller {
    override func draw(_ dirtyRect: NSRect) {
        drawKnob()
    }
}

class AcknowledgementsWindow: NSWindow {
    lazy var tableView = NSTableView() ※ {
        $0.headerView = nil
        $0.style = .sourceList
        $0.dataSource = self
        $0.delegate = self
        $0.addTableColumn(.init())
    }
    lazy var tableScrollView = NSScrollView() ※ {
        $0.documentView = tableView
        $0.verticalScroller = NoBackgroundScroller()
        $0.hasVerticalScroller = true
        $0.autohidesScrollers = true
        $0.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(200)
        }
    }
    let contentScrollView = NSTextView.scrollablePlainDocumentContentTextView() ※ {
        $0.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(320)
            make.height.greaterThanOrEqualTo(480)
        }
    }
    lazy var contentTextView = contentScrollView.documentView as! NSTextView
    
    var items: [Item] = []
    struct Item: Decodable {
        let title: String
        let text: String
    }
    
    convenience init() {
        self.init(contentRect: .zero, styleMask: [.closable, .resizable, .titled, .fullSizeContentView], backing: .buffered, defer: false)
        do {
            items = try JSONDecoder().decode([Item].self, from: Data(contentsOf: Bundle.main.url(forResource: "licenses", withExtension: "json")!))
        } catch {
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: self) { _ in
                self.close()
            }
        }
        let split = NSSplitView()
        split.addArrangedSubview(tableScrollView)
        split.addArrangedSubview(contentScrollView)
        split.isVertical = true
        split.setHoldingPriority(.init(251), forSubviewAt: 0)
        split.dividerStyle = .thin
        contentView = split
        title = "Acknowledgements"
    }
}

extension AcknowledgementsWindow: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
}

extension AcknowledgementsWindow: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = NSView()
        let textField = NSTextField(labelWithString: items[row].title)
        view.addSubview(textField)
        textField.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        textField.lineBreakMode = .byTruncatingTail
        // TODO: もうちょっとマシな方法があった気がするので見つけたらそっちにする
        textField.snp.makeConstraints { make in
            make.centerY.leading.trailing.equalToSuperview()
        }
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let item = items[tableView.selectedRow]
        contentTextView.isEditable = false
        contentTextView.textStorage?.setAttributedString(NSAttributedString(string: item.text, attributes: [
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .foregroundColor: NSColor.labelColor,
        ]))
    }
}
