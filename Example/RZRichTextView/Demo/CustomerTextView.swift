//
//  CustomerTextView.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2021/11/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RZRichTextView
import RxSwift
import RxCocoa

class CustomerTextView: UIViewController {

    enum CToolBarItem: NSInteger {
        case cimage = 100
        case cfont = 101
        case cvideo = 102
        case clink = 103
    }
    var textView: RZRichTextView?
    
    let dispose = DisposeBag()
    var cheight : CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let options = RZRichTextViewOptions.shared
        
        options.obliqueFont = UIFont.init(name: "XinYuGongHeXieSong-L-Light", size: 15) ?? .italicSystemFont(ofSize: 15) // 斜体
        options.boldObliqueFont = .init(name: "XinYuGongHeXieSong-B-Bold", size: 15) ?? .boldSystemFont(ofSize: 15)  // 粗斜体
        
        options.icon_revoke = CRichTextConfigure.revokeIcon
        options.icon_restore = CRichTextConfigure.reStoreIcon
        options.icon_revokeEnable = nil
        options.icon_restoreEnable = nil
        // 不需要移除link属性
        options.shouldRemoveLinkWhenEditing = false
        
        options.colors = [
            .init(161, 161, 161, 1),
            .init(117, 117, 117, 1),
            .init(25, 25, 25, 1),
            .init(255, 246, 0, 1),
            .init(255, 0, 0, 1),
            .init(3, 132, 225, 1),
            .init(0, 236, 28, 1),
            .init(120, 0, 255, 1),
        ]
        
        let tooleBars: [RZToolBarItem] = [
            .init(type: CToolBarItem.cimage.rawValue, image: CRichTextConfigure.imageIcon, selectedImage: nil, selected: false, exparams: nil, items: nil),
            .init(type: CToolBarItem.cfont.rawValue, image: CRichTextConfigure.fontIcon, selectedImage: CRichTextConfigure.fontHightIcon, selected: false, exparams: nil, items: nil),
            .init(type: CToolBarItem.cvideo.rawValue, image: CRichTextConfigure.videoIcon, selectedImage: nil, selected: false, exparams: nil, items: nil),
            .init(type: CToolBarItem.clink.rawValue, image: CRichTextConfigure.linkIcon, selectedImage: nil, selected: false, exparams: nil, items: nil),
        ]
        options.toolbarItems = tooleBars
        
        options.didSelectedToolbarItem = { [weak self] (item, index) in
            self?.textView?.becomeFirstResponder()
            switch item.type {
            case CToolBarItem.cimage.rawValue:
                let vc = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
                vc?.allowPickingImage = true
                vc?.allowPickingVideo = false
                vc?.allowTakeVideo = false
                vc?.allowTakePicture = false
                vc?.allowCrop = false
                vc?.didFinishPickingPhotosHandle = { [weak self] (photos, assets, _) in
                    if let image = photos?.first {
                        let asset = assets?.first as? PHAsset
                        self?.textView?.helper?.insert(text: nil, image: image, asset: asset)
                    }
                }
                RZRichTextViewUtils.rz_currentViewController()?.present(vc!, animated: true, completion: nil)
            case CToolBarItem.cfont.rawValue:
                if let textView = self?.textView {
                    item.selected = !item.selected
                    if item.selected {
                        textView.inputView = CRichTextFontStyleOptionsView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self?.cheight ?? 0), options: textView.options, typingAttributes: textView.typingAttributes, changed: { [weak self] typingAttributes in
                            guard let textView = self?.textView else {
                                return
                            }
                            textView.typingAttributes = typingAttributes
                            textView.helper?.insert(text: nil, image: nil, changeParagraph:true)
                        })
                    } else {
                        textView.inputView?.removeFromSuperview()
                        textView.inputView = nil
                    }
                    textView.reloadInputViews()
                }
                break
            case CToolBarItem.cvideo.rawValue:
                let vc = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
                vc?.allowPickingImage = false
                vc?.allowPickingVideo = true
                vc?.allowTakeVideo = false
                vc?.allowTakePicture = false
                vc?.allowCrop = false
                vc?.didFinishPickingVideoHandle = { (image, asset) in
                    if let image = image {
                        self?.textView?.helper?.insert(text: nil, image: image, asset: asset)
                    }
                }
                RZRichTextViewUtils.rz_currentViewController()?.present(vc!, animated: true, completion: nil)
            case CToolBarItem.clink.rawValue:
                if let range = self?.textView?.selectedRange {
                    self?.changeURL(range: range, url: nil)
                }
            default: break
            }
            self?.textView?.kinputAccessoryView.reloadData()
            return false
        }
        
        let textView = RZRichTextView.init(frame: .zero, options: options)
        
        self.view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(100)
            make.height.equalTo(400)
        }
        
        textView.font = options.normalFont.withSize(15)
        textView.textColor = options.colors[2].color
        
        textView.backgroundColor = .lightGray 
        textView.kinputAccessoryView.closeBtn.isHidden = true
        
        [textView.kinputAccessoryView.leftBtn, textView.kinputAccessoryView.rightBtn].forEach { b in
            b.snp.updateConstraints { make in
                make.width.equalTo(44)
            }
        }
        self.textView = textView
        textView.delegate = self
        
        _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification).take(until: self.rx.deallocated)
                    .subscribe(onNext: { [weak self] (notify) in
                        let keyboardFrame = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                        self?.cheight = keyboardFrame.height - 44
                    }).disposed(by: dispose)
    }
    func changeURL(range: NSRange, url: URL?) {
        let string = self.textView?.attributedText.attributedSubstring(from: range).string
        CLinkInputViewContrller.show(text: string, link: url?.absoluteString) {[weak self] (text, url) in
            guard let textView = self?.textView else {
                return
            }
            let tempText = text ?? url
            var typingAttributes = textView.typingAttributes
            typingAttributes[NSAttributedString.Key.link] = url
            textView.typingAttributes = typingAttributes
            textView.helper?.insert(text: tempText, replaceRange: range)
        }
    }
}
extension CustomerTextView: UITextViewDelegate {
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.changeURL(range: characterRange, url: URL)
        return false
    }
}

struct CRichTextConfigure {
    enum FontStyleItem: Int {
        case bold = 0
        case itial = 1
        case underLine = 2
        case deleteLine = 3
    }
    // 和FontStyleItem一一对应
    static let fontStyleImages: [UIImage?] = [CRichTextConfigure.boldIcon, CRichTextConfigure.itialIcon, CRichTextConfigure.underLineIcon, CRichTextConfigure.deleteLineIcon]
    
    static let imageIcon = UIImage.init(named: "rt_imageIcon")
    static let fontIcon = UIImage.init(named: "rt_fontStyleIcon")
    static let fontHightIcon = UIImage.init(named: "rt_fontStyleIcon_hight")
    static let videoIcon = UIImage.init(named: "rt_videoIcon")
    static let linkIcon = UIImage.init(named: "rt_linkIcon")
    static let revokeIcon = UIImage.init(named: "rt_revokeIcon")
    static let reStoreIcon = UIImage.init(named: "rt_restoreIcon")
    static let boldIcon = UIImage.init(named: "rt_boldIcon")
    static let itialIcon = UIImage.init(named: "rt_itailIcon")
    static let underLineIcon = UIImage.init(named: "rt_underLineIcon")
    static let deleteLineIcon = UIImage.init(named: "rt_deleteLineIcon")
    static let aliginDefaultIcon = UIImage.init(named: "rt_aligin_default")
    static let aliginLeftIcon = UIImage.init(named: "rt_aliginLeftIcon")
    static let aliginCenterIcon = UIImage.init(named: "rt_aliginCenterIcon")
    static let aliginrightIcon = UIImage.init(named: "rt_aliginRightIcon")
    
    static let fontsizes : [CGFloat] = [12, 15, 17, 19]
}

class CLinkInputViewContrller: UIAlertController {
    class func show(text: String?, link: String?, finish:((_ text: String?, _ link: String?) -> Void)?) {
        let t = (text?.isEmpty ?? true) ? "插入超链接" : "编辑超链接"
        let vc = CLinkInputViewContrller.init(title: t, message: nil, preferredStyle: .alert)
        vc.addTextField { t1 in
            
        }
        vc.addTextField { t2 in
            
        }
        vc.textFields?.first?.text = link?.removingPercentEncoding
        vc.textFields?.first?.placeholder = "请输入超链接地址"
        vc.textFields?.last?.text = text
        vc.textFields?.last?.placeholder = "请输入超链接标题"
        let action0 = UIAlertAction.init(title: "放弃操作", style: .cancel) { _ in
            
        }
        let aciton1 = UIAlertAction.init(title: "确认", style: .default) { [weak vc] _ in
            let link = vc?.textFields?.first?.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let text = vc?.textFields?.last?.text
            finish?(text, (link?.isEmpty ?? true) ? nil : link)
        }
        let action2 = UIAlertAction.init(title: "取消超链接", style: .default) { [weak vc]  _ in
            let link: String? = nil
            let text = vc?.textFields?.last?.text
            finish?(text, link)
        }
        if !(text?.isEmpty ?? true) {
            vc.addAction(action2)
        }
        vc.addAction(aciton1)
        vc.addAction(action0)
        RZRichTextViewUtils.rz_currentViewController()?.present(vc, animated: true, completion: nil)
    }
}
