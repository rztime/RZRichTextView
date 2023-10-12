//
//  RZAttachmentInfo.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/24.
//

import UIKit
import Photos
import QuicklySwift

public class RZAttachmentOption {
    static var share = RZAttachmentOption.init()
    var viewclass: UIView.Type = RZAttachmentInfoLayerView.self
 
    public init() {
    }
    ///  需要替换附件视图的话，用此方法, 需要实现RZAttachmentInfoLayerProtocol协议
    public class func register(attachmentLayer view: UIView.Type) {
        RZAttachmentOption.share.viewclass = view
    }
}

/// 附件信息，infoLayer属于添加在textView上的空白视图，需要自行设置一个View加载其上，
/// 可以参考RZCustomRichTextViewModel
/// viewModel.reloadAttachmentInfoIfNeed 里实现初始化显示视图，并绑定好界面显示以及上传状态，最终src、poster，即对应资源的链接
public class RZAttachmentInfo: NSObject {
    public enum AttachmentType: Int {
        case image
        case video
        case audio
    }
    /// 文件上传时的状态
    public enum AttachmentUploadStatus {
        case idle
        case uploading(progress: CGFloat)   /// 上传中  0.0-1
        case complete(success: Bool, info: String?)    /// 上传完成时，为false表示失败, info表示要显示的提示
    }
    /// 附件类型
    public var type: AttachmentType = .image
    /// 图片
    public var image: UIImage? {
        didSet {
            imagePublish.accept(image)
        }
    }
    /// 图片改变之后，发一个通知
    public lazy var imagePublish: QPublish<UIImage?> = .init(value: self.image)
    /// 源文件
    public var asset: PHAsset?
    /// 文件路径
    public var path: String?
    // MARK: - 上传状态，以及上传完成之后的赋值，需要自行在viewModel.reloadAttachmentInfoIfNeed里实现
    /// 上传状态
    public var uploadStatus: QPublish<AttachmentUploadStatus> = .init(value: .idle)
    /// 文件上传完成之后的src
    public var src: String?
    /// 视频上传完成之后的poster，如果有
    public var poster: String?
    /// 时长
    public var duration: CGFloat?
    /// 重新编辑时, 传true，此时没有image asset，并且 src、poster、uploadstatus都需要设置
    public var isReEdit: Bool = false
    /// 用于在添加了audio之后，audio视图的高度
    public var audioViewHeight: CGFloat
    public var maxWidth: CGFloat
    /// 当前附件对应的layer，需要将图片，进度，删除按钮等放至上边
    public let infoLayer: UIView = .init().qtag(10)
    /// 如有需要，可以用于标记上传任务
    public var identity: String = ""
    public var identity1: String = ""
    
    public init(type:RZAttachmentInfo.AttachmentType, image: UIImage?, asset: PHAsset?, filePath: String?, maxWidth: CGFloat, audioHeight: CGFloat, isReEdit: Bool = false) {
        self.maxWidth = maxWidth
        self.audioViewHeight = audioHeight
        self.image = image
        super.init()
        self.type = type
        self.asset = asset
        self.path = filePath
        self.isReEdit = isReEdit
    }
}

/// 给附件添加信息
public extension NSTextAttachment {
    static var attachmentinfokey = "attachmentinfokey"
    /// 用于编辑时，附件相关信息存取
    var rzattachmentInfo: RZAttachmentInfo? {
        set {
            objc_setAssociatedObject(self, &NSTextAttachment.attachmentinfokey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = objc_getAssociatedObject(self, &NSTextAttachment.attachmentinfokey) as? RZAttachmentInfo {
                return obj
            }
            return nil
        }
    }
    /// 将info创建为附件
    class func createWithinfo(_ info: RZAttachmentInfo) -> Self {
        let attachment = Self.init()
        attachment.rzattachmentInfo = info
        switch info.type {
        case .image, .video:
            let size = (info.image?.size ?? .init(width: 1, height: 1)).qscaleto(maxWidth: info.maxWidth)
            attachment.image = UIColor.clear.qtoImage(size)
            break
        case .audio:
            let size = CGSize.init(width: info.maxWidth, height: info.audioViewHeight)
            attachment.image = UIColor.clear.qtoImage(size)
            break
        }
        return attachment
    }
}
