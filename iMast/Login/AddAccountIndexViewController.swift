//
//  AddAccountIndexViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/22.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit
import SafariServices

class AddAccountIndexViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var hostNameField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hostNameField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goButton.sendActions(for: UIControlEvents.touchUpInside);
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goProgress" {
            let nextView = segue.destination as! AddAccountProgressViewController
            if let hostName = hostNameField.text, hostName.count > 0) {
                nextView.setHost(hostName)
            } else if let hostName = hostNameField.placeholder, hostName.count > 0) {
                nextView.setHost(hostName)
            } else {
                alert(title: "エラー", message: "ホスト名を入力してください。")
            }
            print(nextView.hostName)
        }
    }
    @IBAction func doNotHaveAccountButtonTapped(_ sender: Any) {
        let safariVC = SFSafariViewController(url: URL(string: "https://cinderella-project.github.io/iMast/no-account.html")!)
        present(safariVC, animated: true, completion: nil)
    }
}

