//
//  AddAttachmentViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2021/11/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RZRichTextView
import Photos
import RxRelay
import RxSwift

class UpladViewModel {
    var items: [RZUploadStatusItem] = []
}

class AddAttachmentViewController: UIViewController {
    var textView: RZRichTextView?
    var timer : Timer?
    
    var viewModel: UpladViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let btn = UIButton.init(type: .custom)
        self.view.addSubview(btn)
        btn.addTarget(self, action: #selector(closeEdit), for: .touchUpInside)
        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 初始化配置
        let option = RZRichTextViewOptions.init()
        option.willInsetImage = { image in
            return image
        }
        // 打开相册
        option.openPhotoLibrary = { complete in
            let vc = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
            vc?.allowPickingImage = true
            vc?.allowPickingVideo = true
            vc?.allowTakeVideo = false
            vc?.allowTakePicture = false
            vc?.allowCrop = false
            vc?.didFinishPickingPhotosHandle = { (photos, assets, _) in
                if let image = photos?.first {
                    let asset = assets?.first as? PHAsset
                    complete(image, asset)
                }
            }
            vc?.didFinishPickingVideoHandle = { (image, asset) in
                if let image = image {
                    complete(image, asset)
                }
            }
            RZRichTextViewUtils.rz_currentViewController()?.present(vc!, animated: true, completion: nil)
        }
        // 插入了附件，这里需要对遮罩上绑定的自定义view，进行防止重复加载处理，因为在实际编写过程中，可能会出现删除，撤销操作，导致此方法重新调用
        option.didInsetAttachment = { [weak self] attach in
            // 存在重复添加的情况，比如通过撤销操作，还原了已输入的图片，这时候就需要重新布局，重新绑定上传状态等等
            let view = attach.rzrt.maskView.viewWithTag(100) as? RZUploadStatusView ?? .init()
            attach.rzrt.maskView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            view.playBtn.isHidden = attach.rzrt.type != .video
            view.closeBtn.rz.tap { [weak attach, weak self] _ in
                guard let attach = attach else { return }
                print("删除attach:\(attach.rzrt.range)")
                self?.textView?.deleteText(for: attach.rzrt.range)
            }
            
            view.playBtn.rz.tap { [weak attach, weak self] _ in
                self?.preVideo(phasset: attach?.rzrt.asset)
            }
            /// 这里禁掉，主要是方便直接预览图片和视频，实际看个人需要
            view.playBtn.isUserInteractionEnabled = false
            // 预览
            view.rz.tap { [weak self, weak attach] _ in
                self?.preVideo(phasset: attach?.rzrt.asset)
            }
            
            var item: RZUploadStatusItem? = self?.viewModel.items.first(where: { $0.attach.rzrt.identifier == attach.rzrt.identifier})
            if item == nil {
                item = .init(attach: attach)
                self?.viewModel.items.append(item!)
            }
            view.disposeBag = DisposeBag()
            item?.progress.observe(on: MainScheduler.instance).subscribe(onNext: { [weak view] progress in
                view?.progressLabel.rz.colorfulConfer(confer: { confer in
                    confer.text("模拟进度：\(progress)")?.textColor(.white).font(.systemFont(ofSize: 13))
                })
            }).disposed(by: view.disposeBag)
        }
        option.didRemovedAttachment = { attachments in
            // 已移除了
            
        }
        textView = .init(frame: .zero, options: option)
        textView?.backgroundColor = .lightGray
        self.view.addSubview(textView ?? .init())
        textView?.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(100)
            make.height.equalTo(300)
        }
         
        timer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(progressAction), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    override func viewWillAppear(_ animated: Bool) {
        timer?.fire()
    }
    deinit {
        timer?.invalidate()
        timer = nil
    }
    @objc func closeEdit() {
        self.textView?.endEditing(true)
    }
    // 预览
    @objc func preVideo(phasset: PHAsset?) {
        if let asset = phasset {
            if asset.mediaType == .video {
                let vc = TZVideoPlayerController.init()
                let type = asset.mediaType == .video ? TZAssetModelMediaTypeVideo : TZAssetModelMediaTypePhotoGif
                let model = TZAssetModel.init(asset: asset, type: type)
                vc.model = model;
                self.present(vc, animated: true, completion: nil)
            } else {
                let vc = TZGifPhotoPreviewController.init()
                let type = TZAssetModelMediaTypePhotoGif
                let model = TZAssetModel.init(asset: asset, type: type)
                vc.model = model;
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    @objc func progressAction() {
        self.viewModel.items.forEach { item in
            let f : Float = (item.progress.value + 1)
            item.progress.accept(f)
        }
    }
}

class RZUploadStatusItem {
    let attach: NSTextAttachment
    let progress: BehaviorRelay<Float> = .init(value: 0)
    
    init(attach: NSTextAttachment) {
        self.attach = attach
    }
}

class RZUploadStatusView: UIView {
    public let closeBtn = UIButton.init()
    public let playBtn = UIButton.init()
    public let progressLabel = UILabel.init()
    public var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(closeBtn)
        self.addSubview(playBtn)
        self.addSubview(progressLabel)
        
        closeBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.size.equalTo(30)
        }
        playBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(40)
        }
        progressLabel.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        closeBtn.setImage(UIImage.init(named: "close"), for: .normal)
        playBtn.setImage(UIImage.init(named: "play"), for: .normal)
        playBtn.isHidden = true
        progressLabel.backgroundColor = .init(white: 0, alpha: 0.3)
        self.tag = 100
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
