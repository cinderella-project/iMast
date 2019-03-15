//
//  UserIconViewController.swift
//  iMast
//
//  Created by user on 2019/03/11.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import SDWebImage

class UserIconViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = MastodonAccount
    typealias Environment = MastodonUserToken
    
    @IBOutlet weak var imageView: UIImageView!
    
    var environment: MastodonUserToken
    var input: MastodonAccount
    
    required init(with input: MastodonAccount, environment: MastodonUserToken) {
        self.environment = environment
        self.input = input
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.input(input)
    }

    func input(_ input: MastodonAccount) {
        imageView.sd_setImage(with: URL(string: input.avatarUrl, relativeTo: environment.app.instance.url), completed: nil)
    }
    
    @IBAction func iconTapped(_ sender: Any) {
        let vc = openUserProfile(user: self.input)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
