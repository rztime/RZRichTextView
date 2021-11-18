//
//  RZRichTextAttachment.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/25.
//

import UIKit
import Photos
 
@objcMembers
open class RZRichAttachmentObj: NSObject {
    @objc public enum TextAttachmentType: NSInteger {
        case image  = 1
        case video  = 2
    }
    // 遮罩view，可以在上边布局绑定上传状态等等
    open var maskView : UIView = .init()
    open var range: NSRange = .init(location: 0, length: 0)
    open var identifier: String = ""
    open var image: UIImage?
    open var asset: PHAsset?
    open var type: TextAttachmentType = .image
    public init(image: UIImage?, asset: PHAsset?) {
        super.init()
        maskView.backgroundColor = .clear
        self.image = image
        self.asset = asset
        self.type = asset?.mediaType == .video ? .video : .image
        self.identifier = asset?.localIdentifier ?? "\(image?.description ?? "")"
    }
}
 
public extension NSTextAttachment {
    struct RZTextAttachmentPerpotyName {
        public static var rzinfo = "rzinfo"
    }
    class func rtCreatWith(image: UIImage, asset: PHAsset? = nil) -> NSTextAttachment {
        let attach = NSTextAttachment.init()
        attach.image = image
        let obj = RZRichAttachmentObj.init(image: image, asset: asset)
        attach.rtInfo = obj
        return attach
    }
    var rtInfo: RZRichAttachmentObj {
        set {
            objc_setAssociatedObject(self, &RZTextAttachmentPerpotyName.rzinfo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = (objc_getAssociatedObject(self, &RZTextAttachmentPerpotyName.rzinfo)) as? RZRichAttachmentObj {
                return obj
            }
            var img: UIImage?
            if let image = self.image {
                img = image
            } else if let data = self.fileWrapper?.regularFileContents, let image = UIImage.init(data: data) {
                img = image
            }
            let obj = RZRichAttachmentObj.init(image: img, asset: nil)
            self.rtInfo = obj
            return obj
        }
    }
}
