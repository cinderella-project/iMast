//
//  NewPostMediaListViewController.swift
//  iMast
//
//  Created by user on 2018/04/21.
//  Copyright © 2018年 rinsuki. All rights reserved.
//

import UIKit
import ActionClosurable
import Photos

class NewPostMediaListViewController: UIViewController {

    let newPostVC: NewPostViewController
    var transparentVC: UIViewController = TransparentViewController()
    
    @IBOutlet weak var imagesStackView: UIStackView!
    init(newPostVC: NewPostViewController) {
        self.newPostVC = newPostVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh() {
        // update image select button title
        self.newPostVC.imageSelectButton.setTitle(" "+self.newPostVC.media.count.description, for: .normal)
        
        // update image list view
        for imageView in self.imagesStackView.arrangedSubviews {
            self.imagesStackView.removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }
        if self.newPostVC.media.count > 0 {
            for (index, image) in self.newPostVC.media.enumerated() {
                let imageView = UIImageView(image: image.thumbnailImage)
                imageView.ignoreSmartInvert()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                let tapGesture = UITapGestureRecognizer() { _ in
                    let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "プレビュー", style: .default, handler: { _ in
                        let viewController = UIViewController()
                        let imageView = UIImageView()
                        imageView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
                        imageView.image = UIImage(data: image.data)
                        imageView.ignoreSmartInvert()
                        imageView.contentMode = .scaleAspectFit
                        viewController.view = imageView
                        let closeGesture = UITapGestureRecognizer() { _ in
                            viewController.dismiss(animated: true, completion: nil)
                        }
                        imageView.isUserInteractionEnabled = true
                        imageView.addGestureRecognizer(closeGesture)
                        self.present(viewController, animated: true, completion: nil)
                    }))
                    alertVC.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { _ in
                        self.newPostVC.media.remove(at: index)
                        self.refresh()
                    }))
                    alertVC.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                    
                    self.present(alertVC, animated: true, completion: nil)
                }
                tapGesture.numberOfTapsRequired = 1
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tapGesture)
                self.imagesStackView.addArrangedSubview(imageView)
            }
        } else {
            let label = UILabel()
            label.alpha = 0.25
            label.text = "← から画像を追加"
            self.imagesStackView.addArrangedSubview(label)
        }
        self.imagesStackView.setNeedsLayout()
        self.imagesStackView.layoutIfNeeded()
    }
    
    func addMedia(media: UploadMedia) {
        // TODO
        self.newPostVC.media.append(media)
        self.refresh()
    }
    
    @IBAction func tapAddImage(_ sender: UIButton) {
        let pickerSelector = CustomDocumentMenuViewController(
            documentTypes:[
                "public.image"
            ],
            in: UIDocumentPickerMode.import
        )
        pickerSelector.popoverPresentationController?.sourceView = sender
        pickerSelector.popoverPresentationController?.sourceRect = sender.frame
        pickerSelector.popoverPresentationController?.delegate = self
        pickerSelector.delegate = self
        pickerSelector.addOption(withTitle: "フォトライブラリ", image: UIImage(named: "PhotosInline"), order: UIDocumentMenuOrder.first, handler: {
            print("photo-library")
            let imgPickerC = UIImagePickerController()
            print (imgPickerC.modalPresentationStyle.rawValue)
            imgPickerC.sourceType = UIImagePickerController.SourceType.photoLibrary
            imgPickerC.delegate = self
            self.transparentVC.dismiss(animated: false, completion: nil)
            self.present(imgPickerC, animated: true, completion: nil)
        })
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            pickerSelector.addOption(withTitle: "写真を撮る", image: UIImage(named: "Camera"), order: UIDocumentMenuOrder.first, handler: {
                print("camera")
                let imgPickerC = UIImagePickerController()
                imgPickerC.sourceType = UIImagePickerController.SourceType.camera
                imgPickerC.delegate = self
                self.transparentVC.dismiss(animated: false, completion: nil)
                self.present(imgPickerC, animated: true, completion: nil)
            })
        }
        pickerSelector.delegate = self
        self.transparentVC.modalPresentationStyle = .overFullScreen
        pickerSelector.parentVC = self.transparentVC
        pickerSelector.popoverPresentationController?.permittedArrowDirections = .down
        self.present(self.transparentVC, animated: true) {
            self.transparentVC.present(pickerSelector, animated: true, completion: nil)
        }
    }
}

fileprivate class TransparentViewController: UIViewController {
    override func viewDidLoad() {
        let touchGesture = UITapGestureRecognizer() { _ in
            let _ = self.alertWithPromise(title: "内部エラー", message: "このダイアログはでないはずだよ\n(loc: TransparentViewController.viewDidLoad.touchGesture)").then {
                self.dismiss(animated: false, completion: nil)
            }
        }
        touchGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(touchGesture)
    }
}

fileprivate class CustomDocumentMenuViewController: UIDocumentMenuViewController {
    var parentVC: UIViewController? = nil
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: {
            if let parentVC = self.parentVC {
                if parentVC.modalPresentationStyle == .overFullScreen {
                    parentVC.dismiss(animated: false, completion: completion)
                }
            } else {
                completion?()
            }
        })
    }
}

extension NewPostMediaListViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.transparentVC.dismiss(animated: false, completion: nil)
    }
}

extension NewPostMediaListViewController: UIDocumentPickerDelegate {
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.transparentVC.dismiss(animated: true, completion: nil)
        self.present(documentPicker, animated: true, completion: nil)
    }
}

extension NewPostMediaListViewController: UIDocumentMenuDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let data = try! Data(contentsOf: url, options:NSData.ReadingOptions.mappedIfSafe)
        self.addMedia(media: UploadMedia(type: url.pathExtension.lowercased() == "png" ? .png : .jpeg, data: data, thumbnailImage: UIImage(data: data)!))
    }
}

extension NewPostMediaListViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        if #available(iOS 11.0, *), let url = info[.imageURL] as? URL {
            let data = try! Data(contentsOf: url, options:NSData.ReadingOptions.mappedIfSafe)
            self.addMedia(media: UploadMedia(type: url.pathExtension.lowercased() == "png" ? .png : .jpeg, data: data, thumbnailImage: UIImage(data: data)!))
        } else if let assetUrl = info[.referenceURL] as? URL {
            let assets = PHAsset.fetchAssets(withALAssetURLs: [assetUrl], options: nil)
            guard let asset = assets.firstObject else {
                self.alert(title: "エラー", message: "failed to fetch assets")
                return
            }
            if asset.mediaType == .image {
                PHImageManager.default().requestImageData(for: asset, options: nil) { (data, dataUTI, orientation, info) in
                    guard let data = data else {
                        self.alert(title: "エラー", message: "failed to fetch data from PHImageManager")
                        return
                    }
                    self.addMedia(media: UploadMedia(type: dataUTI == "public.jpeg" ? .jpeg : .png, data: data, thumbnailImage: UIImage(data: data)!))
                }
            } else {
                self.alert(title: "エラー", message: "unknown mediaType: \(asset.mediaType.rawValue)")
            }
        } else if let image = info[.originalImage] as? UIImage {
            // たぶんここに来るやつはカメラなので適当にjpeg圧縮する
            guard let data = image.jpegData(compressionQuality: 1) else {
                self.alert(title: "エラー", message: "failed to jpeg encode")
                return
            }
            self.addMedia(media: UploadMedia(type: .jpeg, data: data, thumbnailImage: image))
        } else {
            self.alert(title: "エラー", message: "image is nil(loc: NewPostMediaListViewController.imagePickerController)")
            return
        }
    }
}

extension NewPostMediaListViewController: UINavigationControllerDelegate {
}
