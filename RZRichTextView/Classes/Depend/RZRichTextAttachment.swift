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
    public override init() {
        super.init()
        maskView.backgroundColor = .clear
    }
}

public extension NSTextAttachment {
    struct RZTextAttachmentPerpotyName {
        public static var rzinfo = "rzinfo"
    }
    
    class func creatWith(image: UIImage, asset: PHAsset? = nil) -> NSTextAttachment {
        let attach = NSTextAttachment.init()
        attach.image = image
        let obj = RZRichAttachmentObj.init()
        obj.asset = asset
        obj.image = image
        obj.type = asset?.mediaType == .video ? .video : .image
        obj.identifier = asset?.localIdentifier ?? "\(image.description)"
        attach.rzrt = obj
        return attach
    }
    var rzrt: RZRichAttachmentObj {
        set {
            objc_setAssociatedObject(self, &RZTextAttachmentPerpotyName.rzinfo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &RZTextAttachmentPerpotyName.rzinfo)) as! RZRichAttachmentObj
        }
    }
}
