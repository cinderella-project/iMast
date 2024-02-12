//
//  NewPostMediaListViewController.swift
//  iMast
//
//  Created by rinsuki on 2018/04/21.
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
//

import UIKit
import MobileCoreServices
import AVFoundation
import AVKit
import Photos
import Ikemen
import iMastiOSCore

class NewPostMediaListViewController: UIViewController {
    let viewModel: NewPostViewModel
    var inline: Bool
    
    // TODO: contact じゃないのに使っていいの? アクセシビリティ周りマズそう
    let addButton = UIButton(type: .contactAdd)
    let imagesStackView = UIStackView() ※ { v in
        v.distribution = .fillEqually
    }

    init(viewModel: NewPostViewModel, inline: Bool) {
        self.viewModel = viewModel
        self.inline = inline
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if inline {
            view.addSubview(imagesStackView)
            imagesStackView.spacing = 8
            imagesStackView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(8)
                make.height.equalTo(72)
            }
        } else {
            let stackView = UIStackView(arrangedSubviews: [
                addButton,
                imagesStackView,
            ])
            stackView.spacing = 8
            view.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.center.equalTo(view.safeAreaLayoutGuide)
                make.size.equalTo(view.safeAreaLayoutGuide).inset(8)
            }
            addButton.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(1/5.0).inset(4)
            }
            let menu = UIMenu(children: [
                UIAction(
                    title: L10n.NewPost.Media.Picker.photoLibrary,
                    image: UIImage(systemName: "rectangle.on.rectangle"),
                    handler: { [weak self] _ in
                        self?.addFromPhotoLibrary()
                    }
                ),
                UIAction(
                    title: L10n.NewPost.Media.Picker.takePhoto,
                    image: UIImage(systemName: "camera.fill"),
                    handler: { [weak self] _ in
                        #if !os(visionOS)
                        self?.addFromCamera()
                        #endif
                    }
                ),
                UIAction(
                    title: "ブラウズ",
                    image: UIImage(systemName: "ellipsis"),
                    handler: { [weak self] _ in
                        #if !os(visionOS)
                        guard let strongSelf = self else { return }
                        let pickerVC = UIDocumentPickerViewController(forOpeningContentTypes: [.image], asCopy: true)
                        pickerVC.delegate = strongSelf
                        strongSelf.present(pickerVC, animated: true, completion: nil)
                        #endif
                    }
                ),
            ])
            addButton.preferredMenuElementOrder = .fixed
            addButton.menu = menu
            addButton.showsMenuAsPrimaryAction = true
        }
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh() {
        // update image list view
        for imageView in self.imagesStackView.arrangedSubviews {
            self.imagesStackView.removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }
        if viewModel.media.count > 0 {
            for (index, media) in viewModel.media.enumerated() {
                let imageView = UIImageView(image: media.thumbnailImage)
                imageView.ignoreSmartInvert()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.tag = index
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCurrentMedia(sender:)))
                tapGesture.numberOfTapsRequired = 1
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tapGesture)
                if inline {
                    imageView.snp.makeConstraints { make in
                        make.width.equalTo(imageView.snp.height)
                    }
                }
                self.imagesStackView.addArrangedSubview(imageView)
            }
        } else {
            let label = UILabel()
            label.textColor = .secondaryLabel
            label.text = L10n.NewPost.addImageFromButton
            self.imagesStackView.addArrangedSubview(label)
        }
        self.imagesStackView.setNeedsLayout()
        self.imagesStackView.layoutIfNeeded()
    }
    
    func addMedia(media: UploadableMedia) {
        viewModel.media.append(media)
        self.refresh()
    }
    
    func addFromPhotoLibrary() {
        let imgPickerC = UIImagePickerController()
        imgPickerC.sourceType = .photoLibrary
        #if os(visionOS)
        // TODO: visionOS でも動画に対応する
        imgPickerC.mediaTypes = [kUTTypeImage as String]
        #else
        imgPickerC.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        #endif
        imgPickerC.videoExportPreset = AVAssetExportPresetPassthrough
        showImagePickerController(imgPickerC)
    }
    
    #if !os(visionOS)
    func addFromCamera() {
        let imgPickerC = UIImagePickerController()
        imgPickerC.sourceType = .camera
        showImagePickerController(imgPickerC)
    }
    #endif
    
    func showImagePickerController(_ imgPickerC: UIImagePickerController) {
        imgPickerC.delegate = self
        present(imgPickerC, animated: true, completion: nil)
    }
    
    @objc func tapCurrentMedia(sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        let media = viewModel.media[index]

        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: L10n.NewPost.Media.preview, style: .default, handler: { _ in
            switch media.format {
            case .png, .jpeg:
                let viewController = UIViewController()
                let imageView = UIImageView()
                imageView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
                imageView.image = UIImage(data: media.data)
                imageView.ignoreSmartInvert()
                imageView.contentMode = .scaleAspectFit
                viewController.view = imageView
                let closeGesture = UITapGestureRecognizer(target: viewController, action: #selector(viewController.close))
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(closeGesture)
                self.present(viewController, animated: true, completion: nil)
            case .mp4:
                guard let url = media.url else {
                    return
                }
                let viewController = AVPlayerViewController()
                viewController.player = AVPlayer(url: url)
                self.present(viewController, animated: true, completion: nil)
            }
        }))
        alertVC.addAction(UIAlertAction(title: L10n.NewPost.Media.delete, style: .destructive, handler: { _ in
            self.viewModel.media.remove(at: index)
            self.refresh()
        }))
        alertVC.addAction(UIAlertAction(title: L10n.Localizable.cancel, style: .cancel, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

// TODO: 新しい document picker の delegate に対応してこちらも開放する
#if !os(visionOS)
extension NewPostMediaListViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let data = try! Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
        self.addMedia(media: UploadableMedia(format: url.pathExtension.lowercased() == "png" ? .png : .jpeg, data: data, url: nil, thumbnailImage: UIImage(data: data)!))
    }
}
#endif

extension NewPostMediaListViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        if let url = info[.imageURL] as? URL {
            let data = try! Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
            self.addMedia(media: UploadableMedia(format: url.pathExtension.lowercased() == "png" ? .png : .jpeg, data: data, url: nil, thumbnailImage: UIImage(data: data)!))
        } else if let url = info[.mediaURL] as? URL {
            // TODO: visionOS でも動画投稿に対応する
            #if !os(visionOS)
            Task {
                let asset = AVURLAsset(url: url)
                // サムネイルを作る
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                let cgImage = try! imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
                let thumbnailImage = UIImage(cgImage: cgImage)
                // H.264でなかったら再エンコードが必要
                // (H.265とかでもSafariなら見られるがみんなChrome使ってるので...)
                var requiredReEncoding = false
                if let videoTrack = asset.tracks(withMediaType: .video).first {
                    let formats = videoTrack.formatDescriptions as! [CMFormatDescription]
                    for (index, formatDesc) in formats.enumerated() {
                        let type = CMFormatDescriptionGetMediaType(formatDesc).toString()
                        guard type == "vide" else { continue }
                        let format = CMFormatDescriptionGetMediaSubType(formatDesc).toString()
                        guard type != "avc1" else { continue }
                        // H.264じゃないので再エンコードが必要
                        requiredReEncoding = true
                    }
                }
                let RE_ENCODING_BORDER = 40 * 1000 * 1000 // 40MB
                // 40MB越えてたら再エンコ
                if let attr = try? FileManager.default.attributesOfItem(atPath: url.path) as NSDictionary, attr.fileSize() >= RE_ENCODING_BORDER {
                    requiredReEncoding = true
                }
                // mp4にコンテナ交換
                let exportSession = AVAssetExportSession(asset: asset, presetName: requiredReEncoding ? AVAssetExportPreset1280x720 : AVAssetExportPresetPassthrough)!
                let outUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".mp4")
                print(outUrl)
                exportSession.outputFileType = AVFileType.mp4
                exportSession.outputURL = outUrl
                exportSession.shouldOptimizeForNetworkUse = true
                exportSession.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
                if exportSession.estimatedOutputFileLength >= RE_ENCODING_BORDER {
                    guard await self.confirmAsync(
                        title: "確認",
                        message: "動画をこのままエンコードすると40MBを越えそうです(予想される出力ファイルサイズ: \(exportSession.estimatedOutputFileLength)bytes)。このままエンコードしますか?",
                        okButtonMessage: "OK",
                        style: .default,
                        cancelButtonMessage: "キャンセル"
                    ) else { return }
                }
                let alert = DispatchQueue.mainSafeSync {
                    UIAlertController(title: "動画の処理中", message: "しばらくお待ちください", preferredStyle: .alert)
                }
                await self.presentAsync(alert, animated: true)
                let timer = DispatchQueue.mainSafeSync {
                    Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true, block: { @MainActor _ in
                        alert.message = "しばらくお待ちください (\(String(format: "%.1f", arguments: [exportSession.progress * 100.0]))%, est: \(exportSession.estimatedOutputFileLength))"
                    })
                }
                await exportSession.export()
                if let error = exportSession.error {
                    throw error
                }
                timer.invalidate()
//                    print((try? FileManager.default.attributesOfItem(atPath: outUrl.path)))
                let data = try! Data(contentsOf: outUrl)
                await MainActor.run {
                    alert.dismiss(animated: true, completion: nil)
                    self.addMedia(media: UploadableMedia(format: .mp4, data: data, url: outUrl, thumbnailImage: thumbnailImage))
                }
            }
            #endif
            return
        } else if let image = info[.originalImage] as? UIImage {
            // たぶんここに来るやつはカメラなので適当にjpeg圧縮する
            guard let data = image.jpegData(compressionQuality: 1) else {
                self.alert(title: "エラー", message: "failed to jpeg encode")
                return
            }
            self.addMedia(media: UploadableMedia(format: .jpeg, data: data, url: nil, thumbnailImage: image))
        } else {
            self.alert(title: "エラー", message: "image is nil(loc: NewPostMediaListViewController.imagePickerController)")
            return
        }
    }
}

extension NewPostMediaListViewController: UINavigationControllerDelegate {
}
