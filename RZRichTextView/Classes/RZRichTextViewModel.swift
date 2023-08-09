//
//  RZRichTextViewModel.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/20.
//

import UIKit
import QuicklySwift
import RZColorfulSwift

open class RZRichTextViewModel: NSObject {
    /// 工具栏collectionview里的操作，可以修改，有需要时，修改图片
    open lazy var inputItems: [RZInputAccessoryItem] = [
        /// 音视频图片可以单独成功能，也可以直接一个meida统一
//        .init(type: .image, image: RZRichImage.imageWith("media"), highlight: RZRichImage.imageWith("media")),
//        .init(type: .video, image: RZRichImage.imageWith("video"), highlight: RZRichImage.imageWith("video")),
//        .init(type: .audio, image: RZRichImage.imageWith("audio"), highlight: RZRichImage.imageWith("audio")),
        
        .init(type: .media, image: RZRichImage.imageWith("media"), highlight: RZRichImage.imageWith("media")),
        .init(type: .fontStyle, image: RZRichImage.imageWith("f_default"), highlight: RZRichImage.imageWith("f_hight")),
        .init(type: .tableStyle, image: RZRichImage.imageWith("ol"), highlight: RZRichImage.imageWith("ul")),
        .init(type: .paragraph, image: RZRichImage.imageWith("p_left"), highlight: RZRichImage.imageWith("p_left")),
        .init(type: .link, image: RZRichImage.imageWith("link"), highlight: RZRichImage.imageWith("link"))
    ]
    /// 固定到工具栏的操作
    open lazy var lockInputItems: [RZInputAccessoryItem] = [
        .init(type: .revoke, image: RZRichImage.imageWith("revoke"), highlight: RZRichImage.imageWith("revoke")),
        .init(type: .restore, image: RZRichImage.imageWith("restore"), highlight: RZRichImage.imageWith("restore")),
        .init(type: .close, image: RZRichImage.imageWith("k_end"), highlight: RZRichImage.imageWith("k_end"), selected: true),
    ]
    /// 段落样式
    open lazy var paragraphItems: [RZInputAccessoryItem] = [
        .init(type: .p_left, image: RZRichImage.imageWith("p_left"), highlight: nil),
        .init(type: .p_center, image: RZRichImage.imageWith("p_center"), highlight: nil),
        .init(type: .p_right, image: RZRichImage.imageWith("p_right"), highlight: nil),
    ]
    /// 列表样式
    open lazy var tableStyleItems: [RZInputAccessoryItem] = [
        .init(type: .t_ol, image: RZRichImage.imageWith("ol"), highlight: nil),
        .init(type: .t_ul, image: RZRichImage.imageWith("ul"), highlight: nil)
    ]
  
    /// 在输入文本时，移除链接（仅通过点击工具栏链接或者已输入的链接进行操作）
    open var removeLinkWhenInputText: Bool = true
    /// 字体大小
    open lazy var font_sizes: [(Int, String)] = [
        (12, "小"),
        (16, "标准"),
        (18, "大"),
        (20, "超大"),
    ]
    /// 删除icon
    open lazy var deleteIcon = RZRichImage.imageWith("delete")
    /// 播放icon
    open lazy var playIcon = RZRichImage.imageWith("play")
    /// 字体颜色
    open lazy var fontColors : [UIColor] = [
        .qrgba(161, 161, 161, a: 1),
        .qrgba(117, 117, 117, a: 1),
        .qrgba(25, 25, 25, a: 1),
        .qrgba(255, 246, 0, a: 1),
        .qrgba(255, 0, 0, a: 1),
        .qrgba(3, 132, 225, a: 1),
        .qrgba(0, 236, 28, a: 1),
        .qrgba(120, 0, 255, a: 1),
    ]
    /// 默认颜色
    open lazy var defaultColor: UIColor = .qrgba(25, 25, 25, a: 1)
    /// 当前vm对应的textView
    open weak var textView: RZRichTextView?
    /// 默认字体样式, 如果需要修改，直接设置
    open lazy var defaultTypingAttributes: [NSAttributedString.Key : Any] = [:]
    /// 需要刷新工具栏时，调用此block
    open var reloadDataWithAccessoryView: (() -> Void)?
    /// 用于记录输入历史可撤回次数
    open var historyCount: Int = 20
    /// 需要自定义工具条内容时，需要实现并返回true，返回false时走内部方法
    open var didClickedAccessoryItem: ((_ item: RZInputAccessoryItem) -> Bool)?
    /// 如果有必要，可以刷新附件显示信息
    /// 有新的附件插入时，需在附件的infoLayer上，绑定操作（上传、删除、预览等等）
    open var reloadAttachmentInfoIfNeed: ((_ attachmentInfo: RZAttachmentInfoLayerProtocol) -> Void)?
    /// 上传附件是否完成的功能
    public let uploadAttachmentsComplete: QPublish<Bool> = .init(value: true)
    /// 附件在textView里最大宽度
    open lazy var attachmentMaxWidth: CGFloat = (self.textView?.frame.size.width ?? 300) - 10
    /// 音频附件在textview里的高度
    open lazy var audioAttachmentHeight: CGFloat = 60
    /// 最多输入字数（0无限制）
    open lazy var maxInputLenght: UInt = 0
    /// 超出输入上限时，会调用此block
    open var morethanInputLength: (() -> Void)?
    /// 输入字数显示方式
    public enum RZShowCountType {
        case hidden         // 隐藏
        case showcount      // 仅显示已输入字数
        case showcountandall // 显示输入和总限制字数
    }
    /// 显示字数类型
    open lazy var showcountType: RZShowCountType = .hidden

    /// 空格回车的规则，在转换为html时，将移除
    public enum RZSpaceRule: Int {
        case none               // 不做处理
        case removeHead         // 移除开头的空格和回车
        case removeEnd          // 移除末尾空格和回车
        case removeHeadAndEnd   // 移除开头、末尾的空格和回车
    }
    /// 空格回车的规则，需要移除时，不计算入输入长度内，转换之后也将移除
    open lazy var spaceRule: RZSpaceRule = .none
    
    var attachmentInfoDispose: NSObject = .init()
    /// 附件改变之后的回调，attachments 表示当前存在的附件
    var attachmentInfoChanged: ((_ attachments: [RZAttachmentInfo]) -> Void)?
    
    /// 是否是编辑状态，true可以编辑，false时，不可删除附件以及编辑textView
    /// 初始化的时候配置此项，在编辑过程中，如果想禁用编辑，直接设置textView.isEditable = false
    open var canEdit: Bool = true
    
    public override init() {
        super.init()
        /// 默认居左
        let p = NSMutableParagraphStyle.init()
        p.alignment = .left
         
        defaultTypingAttributes[.paragraphStyle] = p
        // 默认 16 标准字体
        defaultTypingAttributes[.font] = UIFont.systemFont(ofSize: 16)
        /// 默认 字体颜色
        defaultTypingAttributes[.foregroundColor] = UIColor.qrgba(25, 25, 25, a: 1)
        
        self.attachmentInfoChanged = { [weak self] attachments in
            func checkupload() {
                var finish = true
                let attachment:[RZAttachmentInfo]? = self?.textView?.attachments
                attachment?.forEach { info in
                    if case .complete(let success, _) = info.uploadStatus.value {
                        if !success { finish = false }
                    } else {
                        finish = false
                    }
                }
                self?.uploadAttachmentsComplete.accept(finish)
            }
            
            self?.attachmentInfoDispose = .init()
            attachments.forEach { [weak self] info in
                info.uploadStatus.subscribe({ value in
                    checkupload()
                }, disposebag: self?.attachmentInfoDispose)
            }
        }
    }
}

public class RZRichImage: NSObject {
    public class func imageWith(_ name: String) -> UIImage? {
        let bundle = Bundle.init(for: Self.self)
        guard let url = bundle.url(forResource: "RZRichTextView", withExtension: "bundle") else { return nil }
        guard let tempbundle = Bundle.init(url: url) else { return nil }
        let fileName = "\(name)@3x"
        var imgPath = tempbundle.path(forResource: fileName, ofType: "png")
        if let imgPath = imgPath {
            return .init(contentsOfFile: imgPath)
        }
        imgPath = tempbundle.path(forResource: "RZRichTextView.bundle/\(fileName)", ofType: "png")
        if let imgPath = imgPath {
            return .init(contentsOfFile: imgPath)
        }
        return nil
    }
}
