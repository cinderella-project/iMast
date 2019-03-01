//
//  PluginFileEditViewController.swift
//  iMast
//
//  Created by user on 2019/02/23.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import SnapKit

class PluginFileEditViewController: UIViewController, UITextViewDelegate {
    let textView = UITextView()
    var isModified = false { didSet { self.navigationItem.rightBarButtonItem?.isEnabled = isModified }}
    var path: URL!
    
    init (url: URL) {
        self.path = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        let contentData = FileManager.default.contents(atPath: path.path) ?? Data()
        let content = String(data: contentData, encoding: .utf8)
        self.textView.text = content ?? ""
        
        self.view.backgroundColor = .white
        self.view.addSubview(textView)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.font = UIFont(name: "Menlo", size: 14)
        self.textView.spellCheckingType = .no
        self.textView.autocorrectionType = .no
        self.textView.autocapitalizationType = .none
        if #available(iOS 11.0, *) {
            self.textView.smartDashesType = .no
            self.textView.smartQuotesType = .no
        }
        self.textView.becomeFirstResponder()
        self.textView.snp.makeConstraints { make in
            make.width.height.equalTo(self.view)
            make.center.equalTo(self.view)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain) { _ in
            if self.isModified {
                self.confirm(title: "変更を破棄します", message: "よろしいですか", okButtonMessage: "破棄する", style: UIAlertAction.Style.destructive, cancelButtonMessage: "やっぱやめる").then { result in
                    if result {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done) { _ in
            try! self.textView.text.data(using: .utf8)?.write(to: self.path)
            self.dismiss(animated: true, completion: nil)
        }
        
        self.isModified = false
        self.title = self.path.lastPathComponent
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.isModified = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
