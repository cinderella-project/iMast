//
//  SearchViewController.swift
//  iMast
//
//  Created by user on 2018/10/27.
//  Copyright © 2018 rinsuki. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import SafariServices

class SearchViewController: UITableViewController, UISearchBarDelegate {
    var result: MastodonSearchResult?
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.tableHeaderView = self.searchBar
        searchBar.sizeToFit()
        self.title = "探せ!この世の全てをそこに置いてきた!"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(searchBar.text)
        guard let text = searchBar.text else {
            return
        }
        MastodonUserToken.getLatestUsed()!.search(q: text).then { result in
            self.result = result
            print(self.result)
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let result = self.result else {
            return 0
        }
        switch section {
        case 0:
            return result.accounts.count
        case 1:
            return result.hashtags.count
        case 2:
            return result.posts.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["アカウント", "ハッシュタグ", "投稿"][section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let account = self.result!.accounts[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = account.name == "" ? account.screenName : account.name
            cell.detailTextLabel?.text = "@" + account.acct
            let iconUrl = URL(string: account.avatarUrl, relativeTo: URL(string: "https://" + MastodonUserToken.getLatestUsed()!.app.instance.hostName)!)
            cell.imageView?.sd_setImage(with: iconUrl, completed: { (_, _, _, _) in
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            })
            return cell
        case 1:
            let hashtag = self.result!.hashtags[indexPath.row]
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "#" + hashtag
            return cell
        case 2:
            let post = self.result!.posts[indexPath.row]
            let cell = MastodonPostCell()
            cell.load(post: post)
            return cell
        default:
            fatalError("what")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = openUserProfile(user: self.result!.accounts[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            self.alert(title: "ハッシュタグはまって", message: "まだ実装してないので...")
        case 2:
            let vc = R.storyboard.mastodonPostDetail.instantiateInitialViewController()!
            vc.load(post: self.result!.posts[indexPath.row])
        default:
            break
        }
    }
}
