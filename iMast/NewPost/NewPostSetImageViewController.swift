//
//  NewPostSetImageViewController.swift
//  iMast
//
//  Created by rinsuki on 2017/04/30.
//  Copyright © 2017年 rinsuki. All rights reserved.
//

import UIKit

class NewPostSetImageViewController: ThemeableTableViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var autoResizeConfigShow: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let parentVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! NewPostViewController
        self.imageView.image = parentVC.image
        self.nsfwSwitch.isOn = parentVC.isNSFW
        updateAutoResizeConfigShow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        setImage(url: url, image: UIImage(data:try! Data(contentsOf: url,options:NSData.ReadingOptions.mappedIfSafe))!)
    }
    
    func updateAutoResizeConfigShow() {
        let nowAutoResizeConfig = Defaults[.autoResizeSize]
        self.autoResizeConfigShow.text = (nowAutoResizeConfig == 0 ? "無指定" : String(nowAutoResizeConfig) + "px")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath[1]
        if selectedRow == 1 { // 画像を選択
            let pickerSelector = UIDocumentMenuViewController(
                documentTypes:[
                    "public.image"
                ],
                in: UIDocumentPickerMode.import
            )
            pickerSelector.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
            pickerSelector.addOption(withTitle: "フォトライブラリ", image: UIImage(named: "PhotosInline"), order: UIDocumentMenuOrder.first, handler: {
                print("photo-library")
                let imgPickerC = UIImagePickerController()
                imgPickerC.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imgPickerC.delegate = self
                self.present(imgPickerC, animated: true, completion: nil)
            })
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                pickerSelector.addOption(withTitle: "写真を撮る", image: UIImage(named: "Camera"), order: UIDocumentMenuOrder.first, handler: {
                    print("camera")
                    let imgPickerC = UIImagePickerController()
                    imgPickerC.sourceType = UIImagePickerControllerSourceType.camera
                    imgPickerC.delegate = self
                    
                    self.present(imgPickerC, animated: true, completion: nil)
                })
            }
            pickerSelector.delegate = self
            present(pickerSelector, animated: true, completion: nil)
        } else if selectedRow == 3 { // 自動リサイズ
            let nowsentaku = Defaults[.autoResizeSize]
            let sentakusi = [ // 自動リサイズの選択肢
                0,
                1280,
                1000,
                750,
                500,
            ]
            let select = UIAlertController(
                title: "自動リサイズ",
                message: "現在: " + (nowsentaku == 0 ? "無指定" : String(nowsentaku) + "px四方に収まるサイズ"),
                preferredStyle: UIAlertControllerStyle.actionSheet
            )
            select.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)?.detailTextLabel
            for num in sentakusi {
                let title = num == 0 ? "無指定" : String(num) + "px四方に収まるサイズ"
                select.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                    Defaults[.autoResizeSize] = num
                    self.updateAutoResizeConfigShow()
                }))
            }
            select.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel))
            present(select, animated: true, completion: nil)
        } else if selectedRow == 4 { // 画像消去
            let parentVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! NewPostViewController
            self.imageView.image = nil
            parentVC.image = nil
            parentVC.isPNG = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        let url = (info[UIImagePickerControllerReferenceURL] as? URL) ?? URL(string: "https://example.com/example.jpg")!
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        setImage(url: url, image: pickedImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func setImage(url: URL, image: UIImage) {
        let parentVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! NewPostViewController
        let urlStr = url.absoluteString.lowercased()
        if urlStr.contains(".jpg") || urlStr.contains(".jpeg") { // たぶんJPEG、きっとJPEG、だよな！？
            print("maybe jpeg")
            parentVC.isPNG = false
        } else {
            parentVC.isPNG = true
        }
        selectedImage(image)
    }
    
    func selectedImage(_ image: UIImage) {
        let parentVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! NewPostViewController
        self.imageView.image = image
        parentVC.image = image
    }
    @IBAction func nsfwTap(_ sender: Any) {
        let parentVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! NewPostViewController
        parentVC.isNSFW = self.nsfwSwitch.isOn
    }
}
