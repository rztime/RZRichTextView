//
//  LabelRZRich.swift
//  RZRichTextView
//
//  Created by rztime on 2023/8/7.
//

import UIKit
import Kingfisher
import QuicklySwift

public extension UILabel {

    /// UILabel中，html转富文本，使用方式参考demo里
    /// - Parameters:
    ///   - html: html
    ///   - sizeChanged: 当附件更新的时候，通常UILabel的高度会发生变化，此时如果自适应的话，可能需要刷新界面
    ///   - preview: 预览，有可能是链接，有可能是附件，附件的话tapActionId:类似"<NSTextAttachment: 0x600002243cd0>"
    func html2AttributedString(html: String?,
                               sizeChanged:(() -> Void)? = nil,
                               preview: ((_ tapActionId: String) -> Void)? = nil) {
        if html == self.html {
            return
        }
        self.html = html
        self.attributedText = nil
        let needPreView = preview != nil
        let preview = preview
        if needPreView {
            self.rz.tapAction { label, tapActionId, range in
                preview?(tapActionId)
            }
        }

        let max = max(self.preferredMaxLayoutWidth, self.frame.size.width)
        let t = html?.html2Attributedstring(options: .defaultForLabel(max, 60)) ?? .init()
        let attr = NSMutableAttributedString.init(attributedString: t)
        attr.enumerateAttribute(.link, in: .init(location: 0, length: attr.length)) { value, range, _ in
            if let value = value as? URL {
                attr.addAttributes([.rztapLabel: value.absoluteString], range: range)
            } else if let value = value as? String {
                attr.addAttributes([.rztapLabel: value], range: range)
            }
        }
        func fix(attachment: NSTextAttachment, range: NSRange) {
            if let info = attachment.rzattachmentInfo, let image = info.image {
                attachment.image = image
                var bounds = attachment.bounds
                bounds.size = image.size.qscaleto(maxWidth: bounds.width)
                attachment.bounds = bounds
            }
            /// 此时富文本如果没有赋值到Label中，表示还在设置Attr
            guard let attr = self.attributedText else {
                if needPreView {
                    attr.addAttributes([.rztapLabel: "\(attachment)"], range: range)
                }
                return
            }
            let temp = NSMutableAttributedString(attributedString: attr)
            let attach = NSMutableAttributedString(attachment: attachment)
            if needPreView {
                attach.addAttributes([.rztapLabel: "\(attachment)"], range: .init(location: 0, length: 1))
            }
            temp.replaceCharacters(in: range, with: attach)
            self.attributedText = temp
            sizeChanged?()
        }
        let ats = attr.rt.attachments()
        for at in ats {
            if let info = at.0.rzattachmentInfo {
                /// 如果本地已经加载过图片了，则不需要异步即可实现富文本
                switch info.type {
                case .image, .video:
                    let url = info.poster?.qtoURL ?? info.src?.qtoURL
                    if let c = RZRichTextViewConfigure.shared.async_imageBy {
                        let complete: ((String?, UIImage?) -> Void)? = { [weak info] source, image in
                            info?.image = image
                            info?.image = UILabel.creatAttachmentInfoView(info, width: max)
                            fix(attachment: at.0, range: at.1)
                        }
                        c(url?.absoluteString, complete)
                    } else {
                        UIImage.asyncImageBy(url?.absoluteString) { [weak info] image in
                            info?.image = image
                            info?.image = UILabel.creatAttachmentInfoView(info, width: max)
                            fix(attachment: at.0, range: at.1)
                        }
                    }
                case .audio:
                    info.image = UILabel.creatAttachmentInfoView(info, width: max)
                    fix(attachment: at.0, range: at.1)
                }
            }
        }
        self.attributedText = attr
    }
}
private var htmlkey: UInt8 = 2
public extension UILabel {
    /// 将html转换为富文本时，设置的内容
    var html: String? {
        set {
            objc_setAssociatedObject(self, &htmlkey, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            if let res = objc_getAssociatedObject(self, &htmlkey) as? String {
                return res
            }
            return nil
        }
    }
    class func creatAttachmentInfoView(_ info: RZAttachmentInfo?, width: CGFloat) -> UIImage? {
        let view = RZAttachmentOption.share.viewclass.init(frame: .init(x: 0, y: 0, width: width, height: 0))
        qappKeyWindow.qbody([
            view.qmakeConstraints({ make in
                make.left.equalToSuperview().offset(-width)
                make.width.equalTo(width)
                make.top.equalToSuperview()
            })
        ])
        if let view = view as? RZAttachmentInfoLayerProtocol {
            view.info = info
            view.canEdit = false
        }
        let image = view.qtoImage()
        view.removeFromSuperview()
        return image
    }
}
