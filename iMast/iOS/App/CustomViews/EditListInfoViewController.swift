//
//  EditListInfoViewController.swift
//
//  iMast https://github.com/cinderella-project/iMast
//
//  Created by user on 2019/09/29.
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
import Mew
import Eureka
import EurekaFormBuilder
import Ikemen
import iMastiOSCore

class EditListInfoViewController: FormViewController, Instantiatable, Interactable {
    typealias Input = MastodonList
    typealias Environment = MastodonUserToken
    typealias Output = MastodonList?
    let environment: Environment
    var input: Input
    var outputHandler: ((Output) -> Void)?
    
    var isSaving: Bool = false {
        didSet {
            switch isSaving {
            case true:
                let indicator = UIActivityIndicatorView(style: .medium) ※ { v in
                    v.startAnimating()
                }
                navigationItem.rightBarButtonItem = .init(customView: indicator)
            case false:
                navigationItem.rightBarButtonItem = .init(title: "保存", style: .done, target: self, action: #selector(onSave))
            }
        }
    }
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        title = "編集"
        isSaving = false

        form.append {
            Section {
                TextRow("title") { row in
                    row.title = "名前"
                }
            }
            Section {
                ButtonRow { row in
                    row.title = "リストを削除"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .red
                }.onCellSelection { [weak self] cell, row in
                    self?.onDeleteButtonTapped(cell: cell)
                }
            }
        }
    }

    func output(_ handler: ((Output) -> Void)?) {
        outputHandler = handler
    }
    
    @objc func onSave() {
        isSaving = true
        let values = form.values()
        environment.list(list: input, title: values["title"] as! String).then { [weak self] newList in
            self?.outputHandler?(newList)
            self?.dismiss(animated: true, completion: nil)
        }.catch { [weak self] error in
            self?.isSaving = false
            self?.errorReport(error: error)
        }
    }
    
    func onDeleteButtonTapped(cell: BaseCell) {
        let alert = UIAlertController(
            title: "確認",
            message: "リスト「\(self.input)」を削除してもよろしいですか?",
            preferredStyle: .actionSheet
        )
        alert.popoverPresentationController?.sourceView = cell
        alert.addAction(.init(title: "削除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.environment.delete(list: self.input).then { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                self?.output(nil)
            }
        })
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
