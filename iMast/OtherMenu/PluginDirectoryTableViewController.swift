//
//  PluginDirectoryTableViewController.swift
//  iMast
//
//  Created by user on 2019/02/23.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import ActionClosurable
import Ikemen

class PluginDirectoryTableViewController: UITableViewController {
    var directory: URL
    var directories: [URL] = []
    var files: [URL] = []
    
    init(directory: URL? = nil) {
        if let dir = directory {
            self.directory = dir
        } else {
            self.directory = pluginHome
        }
        super.init(style: .plain)
        self.reload()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = self.directory.lastPathComponent
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add) { target in
            let actionSheet = UIAlertController(title: "追加", message: "何を追加しますか?", preferredStyle: .actionSheet)
            actionSheet.popoverPresentationController?.barButtonItem = target
            actionSheet.addAction(UIAlertAction(title: "ディレクトリ", style: .default) { _ in
                let alert = UIAlertController(title: "新規ディレクトリ", message: "ディレクトリ名を指定してください", preferredStyle: .alert)
                alert.addTextField(configurationHandler: nil)
                alert.addAction(UIAlertAction(title: "作成", style: .default) { _ in
                    guard let name = alert.textFields?[0].text else {
                        return
                    }
                    let url = self.directory.appendingPathComponent(name)
                    try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                    self.reload()
                    let vc = PluginDirectoryTableViewController(directory: url)
                    self.present(vc, animated: true, completion: nil)
                })
                alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
            actionSheet.addAction(UIAlertAction(title: "ファイル", style: .default) { _ in
                let alert = UIAlertController(title: "新規ファイル", message: "ファイル名を指定してください", preferredStyle: .alert)
                alert.addTextField(configurationHandler: nil)
                alert.addAction(UIAlertAction(title: "作成", style: .default) { _ in
                    guard let name = alert.textFields?[0].text else {
                        return
                    }
                    let url = self.directory.appendingPathComponent(name)
                    if FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil) == false {
                        print("why failed?????")
                    }
                    self.reload()
                    let vc = UINavigationController(rootViewController: PluginFileEditViewController(url: url))
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
            actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in })
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func reload() {
        let entries = try! FileManager.default.contentsOfDirectory(at: self.directory, includingPropertiesForKeys: nil, options: [])
        self.directories = []
        self.files = []
        for entry in entries {
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: entry.path, isDirectory: &isDir)
            if isDir.boolValue {
                self.directories.append(entry)
            } else {
                self.files.append(entry)
            }
        }
        if isViewLoaded {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return self.directories.count
        case 1:
            return self.files.count
        default:
            fatalError("おかしい")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let url = (indexPath.section == 0 ? self.directories : self.files)[indexPath.row]
        cell.textLabel?.text = url.lastPathComponent
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let count = (section == 0 ? self.directories : self.files).count
        if count == 0 {
            return nil
        }
        let name = (section == 0 ? "ディレクトリ" : "ファイル")
        return "\(name) (\(count)件)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = PluginDirectoryTableViewController(directory: self.directories[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = UINavigationController(rootViewController: PluginFileEditViewController(url: self.files[indexPath.row]))
            self.present(vc, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func tapAddButton(_ target: Any) {
        print("tapped")
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
