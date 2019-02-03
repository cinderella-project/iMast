//
//  EmojiListTableViewController.swift
//  iMast
//
//  Created by user on 2019/02/03.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import SafariServices
import SDWebImage

class EmojiListTableViewController: UITableViewController {
    var emojis: [MastodonCustomEmoji] = []
    var account: MastodonAccount!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "カスタム絵文字一覧"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.emojis.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let emoji = self.emojis[indexPath.row]
        // Configure the cell...
        cell.imageView?.sd_setImage(with: URL(string: emoji.url)) { _, _, _, _ in
            cell.layoutIfNeeded()
        }
        cell.textLabel?.text = ":" + emoji.shortcode + ":"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let emoji = self.emojis[indexPath.row]
        let safariVC = SFSafariViewController(url: URL(string: emoji.url)!)
        self.present(safariVC, animated: true)
    }
}
