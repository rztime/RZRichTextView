//
//  RZRichTextViewHelper.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/17.
//

import UIKit
import Photos

@objcMembers
open class RZRichTextViewHelper: NSObject, UITextViewDelegate {
    open weak var textView: RZRichTextView?
    open var options: RZRichTextViewOptions
    open var isFirstUse: Bool = true
    /// 会记录 textViewDidChange回调时，产生的所有的操作步骤，会保存notesCount + 1条
    open var history: [(NSAttributedString?, NSRange, [NSAttributedString.Key: Any])] = []
    open var stores: [(NSAttributedString?, NSRange, [NSAttributedString.Key: Any])] = []

    // 最大记录撤回数量
    open var notesCount: Int = 20
    /// 配置viewcontroller的类，可以修改继承
    open var configureViewController: RZRichFontConfigureViewController.Type = RZRichFontConfigureViewController.self
    // 记录的文本中的附件，可能不准确，如果需要请遍历NSAttributedString
    open var attachments: [NSTextAttachment] = []
    
    public init(_ textView: RZRichTextView, options: RZRichTextViewOptions) {
        self.options = options
        super.init()
        self.textView = textView
        
        self.textView?.kinputAccessoryView.didSelected = { [weak self] (item, index) in
            self?.didSelectedToolbarItem(item, index: index)
        }
        self.textView?.kinputAccessoryView.leftBtn.addTarget(self, action: #selector(revokeAction), for: .touchUpInside)
        self.textView?.kinputAccessoryView.rightBtn.addTarget(self, action: #selector(restoreAction), for: .touchUpInside)
    }
    /// 工具条点击事件
    open func didSelectedToolbarItem(_ item: RZToolBarItem, index: Int) {
        AudioServicesPlaySystemSound(1519)
        let res = self.options.didSelectedToolbarItem?(item, index) ?? true
        guard res else { return }
        guard let textView = textView else {
            return
        }
        switch item.type {
        case RZTextViewToolbarItem.endEdit.rawValue:
            UIApplication.shared.keyWindow?.endEditing(true)
        case RZTextViewToolbarItem.image.rawValue:
            self.options.openPhotoLibrary?({ [weak self] (image, asset) in
                self?.insert(text: nil, image: image, asset: asset)
            })
        case RZTextViewToolbarItem.font.rawValue,
            RZTextViewToolbarItem.baseOfline.rawValue,
            RZTextViewToolbarItem.stroken.rawValue,
            RZTextViewToolbarItem.shadow.rawValue,
            RZTextViewToolbarItem.expansion.rawValue,
            RZTextViewToolbarItem.paragraph.rawValue,
            RZTextViewToolbarItem.tabStyle.rawValue,
            RZTextViewToolbarItem.link.rawValue:
            let vc = configureViewController.init()
            vc.typingAttributes = textView.typingAttributes
            vc.options = self.options
            vc.item = item
            vc.finish = { [weak self, weak item] typingAttributes in
                guard let self = self, let textView = self.textView else { return }
                textView.typingAttributes = typingAttributes
                if item?.type == RZTextViewToolbarItem.tabStyle.rawValue {  // 制表列表，需要单独处理
                    if let style = textView.typingAttributes[NSAttributedString.Key.rt.tabStyle] as? RZTextTabStyle {
                        self.insetOrDeleteTabStyle(style)
                    }
                } else {
                    let change = (item?.type == RZTextViewToolbarItem.paragraph.rawValue)
                    self.insert(text: nil, image: nil, changeParagraph:change)
                }
            }
            vc.linkEditEnd = { [weak self] (text, image, asset, url) in
                guard let textView = self?.textView else {
                    return
                }
                var tempText: String? = text
                // 如果没有文字和图片，只有url，则把url当做文本插入
                if !(url?.isEmpty ?? true), text?.isEmpty ?? true, image == nil {
                    tempText = url
                }
                if !(url?.isEmpty ?? true) {
                    var typingAttributes = textView.typingAttributes
                    typingAttributes[NSAttributedString.Key.link] = url
                    textView.typingAttributes = typingAttributes
                }
                self?.insert(text: tempText, image: image, asset: asset)
            }
            RZRichTextViewUtils.rz_presentViewController(vc, animated: true)
        default:
            break
        }
    }
    // 插入文字或图片(视频),insetRange表示插入的位置，nil时，插入到selectedRange
    open func insert(text: String? = nil, image: UIImage? = nil, asset: PHAsset? = nil, changeParagraph: Bool = false, replaceRange: NSRange? = nil) {
        guard let textView = self.textView else {
            return
        }
        let tempAttr = NSMutableAttributedString.init()
        var attachment: NSTextAttachment?
        if let image = image {
            var tempImage: UIImage? = image
            if let insert = self.options.willInsetImage {
                tempImage = insert(image)
            }
            if let tempImage = tempImage {
                let attach = NSTextAttachment.rtCreatWith(image: tempImage, asset: asset)
                attach.bounds = self.tempImageCover(image: tempImage)
                textView.addSubview(attach.rtInfo.maskView)
                let attr = NSAttributedString.init(attachment: attach)
                tempAttr.append(attr)
                attachment = attach
            }
        }
        if let text = text {
            let attr = NSAttributedString.init(string: text)
            tempAttr.append(attr)
        }
        tempAttr.addAttributes(textView.typingAttributes, range: .init(location: 0, length: tempAttr.length))
        let textAttributedstring = NSMutableAttributedString.init(attributedString: textView.attributedText)
        var range = replaceRange ?? textView.selectedRange
        if tempAttr.length > 0 || (tempAttr.length == 0 && (replaceRange?.length ?? 0) > 0) {  // 有文字输入时，替换插入
            if range.length > 0 {
                textAttributedstring.replaceCharacters(in: range, with: tempAttr)
            } else {
                textAttributedstring.insert(tempAttr, at: range.location)
            }
            range.location = range.location + tempAttr.length
            range.length = 0
        } else { // 无文字输入时，修改所选内容属性
            let attr = NSMutableAttributedString.init(attributedString: textAttributedstring.attributedSubstring(from: range))
            let newAttr = attr.rt.replaceAttributes(textView.typingAttributes, range: .init(location: 0, length: attr.length))
            textAttributedstring.replaceCharacters(in: range, with: newAttr)
            if replaceRange != nil {
                range.length = 0
            }
        }
        let typing = textView.typingAttributes
        if changeParagraph {
            let tempRange = textAttributedstring.rt.parapraghRange(for: range)
            let p = typing[.paragraphStyle] as? NSParagraphStyle ?? .init()
            textAttributedstring.addAttributes([.paragraphStyle: p], range: tempRange)
        }
        textView.attributedText = self.options.enableTabStyle ? textAttributedstring.rt.resetTabOrderNumber() : textAttributedstring
        textView.selectedRange = range
        if changeParagraph {
            textView.typingAttributes = typing
        }
        textView.delegate?.textViewDidChange?(textView)
        if let attachment = attachment {
            textView.options.didInsetAttachment?(attachment)
        }
    }
    /// 这个方法只是转化获取在textView中的位置大小，并不会修改图片大小
    open func tempImageCover(image: UIImage) -> CGRect {
        var size = image.size
        let viewsize = textView?.frame.size ?? .zero
        if size.width > viewsize.width - 20 {
            size.width = viewsize.width - 20
            size.height = size.height * size.width / image.size.width
        }
        return .init(x: 0, y: 0, width: size.width, height: size.height)
    }
    // 撤销
    @objc open func revokeAction() {
        self.revokeText(revoke: true)
    }
    // 还原
    @objc open func restoreAction() {
        self.revokeText(revoke: false)
    }
    // 撤销 或者还原
    open func revokeText(revoke: Bool) {
        guard let textView = textView else {
            return
        }
        defer {
            textView.kinputAccessoryView.leftBtn.isSelected = history.count > 1
            textView.kinputAccessoryView.rightBtn.isSelected = stores.count > 0
            self.reviseImageMaskViewFrame()
        }
        if revoke {
            if history.count <= 1 {
                return
            }
            if let now = history.last {
                self.stores.append(now)
            }
            let value = history[(history.count - 2)]
            textView.attributedText = value.0
            textView.selectedRange = value.1
            textView.typingAttributes = value.2
            history.removeLast()
        } else {
            if stores.count == 0 {
                return
            }
            if let value = stores.last {
                history.append(value)
                textView.attributedText = value.0
                textView.selectedRange = value.1
                textView.typingAttributes = value.2
                stores.removeLast()
            }
        }
    }
    // 添加历史
    open func addToHistory() {
        guard let textView = self.textView else { return }
        history.append((textView.attributedText, textView.selectedRange, textView.typingAttributes))
        if history.count > (notesCount + 1) {
            history.removeFirst()
        }
        stores.removeAll()
        textView.kinputAccessoryView.leftBtn.isSelected = history.count > 1
        textView.kinputAccessoryView.rightBtn.isSelected = false
    }
    /// 插入图片，或者视频时，UI分离，在TextAttachment里添加一个遮罩View，每次文本修改之后，会重新计算图片的位置，可以在maskView上添加自定义UI
    open func reviseImageMaskViewFrame() {
        // 放在主线程，保证在插入图片之后，先在textView中绘制完成，然后才能拿到正确的图片位置
        self.textView?.setNeedsLayout()
        guard let textView = self.textView else { return }
        let attachments: [NSTextAttachment]? = textView.rt.richTextAttachments()
        attachments?.forEach { [weak self] attach in
            guard let self = self, let textView = self.textView else { return }
            let view = attach.rtInfo.maskView
            let rect = textView.rt.rectFor(range: attach.rtInfo.range)
            view.frame = rect
            if view.superview != textView {
                textView.addSubview(view)
                self.options.didInsetAttachment?(attach)
            } 
        }
        let removed = self.attachments.filter { attach in
            if let _ = attachments?.first(where: {$0 == attach}) {
               return false
            }
            return true
        }
        removed.forEach { attach in
            attach.rtInfo.maskView.removeFromSuperview()
        }
        self.attachments = attachments ?? []
        if removed.count > 0 {
            self.options.didRemovedAttachment?(removed)
        }
    }
    /// 添加或删除列表符
    open func insetOrDeleteTabStyle(_ style: RZTextTabStyle) {
        guard let textView = textView else {
            return
        }
        var attributedText = NSMutableAttributedString.init(attributedString: textView.attributedText)
        if attributedText.length == 0, style != .none {
            attributedText = NSMutableAttributedString.init(string: "\n", attributes: textView.typingAttributes)
        }
        let selectedRange = textView.selectedRange
        // 得到range所在的所有行
        let ranges = attributedText.rt.paragraphRanges(for: selectedRange)
        var rangesAttrs : [NSMutableAttributedString] = []
        ranges.forEach { range in
            // 转换
            let tempAttr : NSMutableAttributedString = attributedText.attributedSubstring(from: range).rt.removeHeadTabString().mutableCopy() as? NSMutableAttributedString ?? .init()
            tempAttr.rt.mutableTransParagraphTo(style)
            rangesAttrs.append(tempAttr)
        }
        // 倒叙的方式替换
        for (i, range) in ranges.enumerated().reversed() {
            let attr = rangesAttrs[i]
            attributedText.replaceCharacters(in: range, with: attr)
        }
        let new = attributedText.rt.resetTabOrderNumber()
        let newRange = RZRichTextViewUtils.newRangeFor(origin: textView.attributedText, range: selectedRange, new: new)
        textView.attributedText = new
        DispatchQueue.main.async {
            textView.selectedRange = newRange
        }
    }
    /// MARK: - delegate事件
    open func textViewDidBeginEditing(_ textView: UITextView) {
        if self.isFirstUse {
            self.addToHistory()
            self.isFirstUse = false
        }
    }
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if !self.options.enableTabStyle {
            return true
        }
        func removeLink() {
            var typingAttributes = textView.typingAttributes
            typingAttributes[NSAttributedString.Key.link] = nil
            textView.typingAttributes = typingAttributes
        }
        // 是否需要移除超链接输入，如果不需要移除，那么需要自己实现开头和结尾移除超链接
        if self.options.shouldRemoveLinkWhenEditing {
            removeLink()
        } else {
            if let _ = textView.typingAttributes[.link], let pr = textView.attributedText.rt.rangeFor(attrName: .link, with: range) {
                if range.location < pr.location || range.location >= pr.rt.maxLength() || (range.location == pr.location && range.rt.maxLength() > pr.rt.maxLength()) {
                    removeLink()
                }
            }
        }
        var range = range
        let tab = textView.attributedText.rt.tabStyleFor(range)
        if tab == .none {
            return true
        }
        // 删除制表符
        func deleteTab() -> Bool {
            if let p = textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle {
                let newp = p.rt.transParagraphTo(.none)
                textView.typingAttributes[.paragraphStyle] = newp
                let headLength = textView.attributedText.rt.tabStyleLengthFor(range) - 1
                self.insert(text: "", changeParagraph: true, replaceRange: .init(location: range.location - headLength, length: range.length + headLength))
                return false
            }
            return true
        }
        if text == "", range.length > 0 {
            // 删除文字操作
            let text = textView.attributedText.attributedSubstring(from: range)
            if text.string.hasPrefix("\t") {
                // 如果是删除制表符，判断\t是否切是段落开头，制表符所占range之内，则删除
                let pr = textView.attributedText.rt.parapraghRange(for: range)
                let headLength = textView.attributedText.rt.tabStyleLengthFor(range)
                if range.location >= pr.location + headLength {
                    return true
                }
                return deleteTab()
            }
            if text.string.hasPrefix("\n"), tab == .ol {
                self.insert(text: "", replaceRange: range)
                return false
            }
            return true
        }
        if text == "\n", range.length == 0 {
            let p = textView.attributedText.rt.paragraphAttributedSubString(form: range).rt.removeHeadTabString()
            if p.length == 1, p.string == "\n" { // 未输入文本，回车的话，就去掉制表符
                range.location -= 1
                range.length += 1
                return deleteTab()
            } else {
                self.insert(text: "\n", replaceRange: range)
            }
            return false
        }
        return true
    }
    // 改变了光标的range，
    open func textViewDidChangeSelection(_ textView: UITextView) {
        if !self.options.enableTabStyle {
            return
        }
        let selectedRange = textView.selectedRange
        let textString = (textView.text as NSString)
        if selectedRange.rt.maxLength() >= textString.length {
            if textString.hasSuffix("\n"), textView.attributedText.rt.tabStyleFor(selectedRange) != .none { // 当最后一个字符为"\n"，计算所有行时，是无法得到最后的光标所在行，所以这里-1，不让光标在\n后
                textView.selectedRange = .init(location: selectedRange.location, length: selectedRange.length - 1)
            }
            return
        }
        let tab = textView.attributedText.rt.tabStyleFor(selectedRange)
        if tab == .none {
            return
        }
        let rg = textView.attributedText.rt.parapraghRange(for: selectedRange)
        let headLength = textView.attributedText.rt.tabStyleLengthFor(selectedRange)
        if selectedRange.location - rg.location >= headLength {
            return
        }
        // 让光标，无法选中或移动到制表符上
        let end = selectedRange.rt.maxLength()
        let star = rg.location + headLength
        textView.selectedRange = NSRange.init(location: star, length: end - star)
    }
    // 文本内容改变，需要调用，用于重新设置附件view的frame
    open func textViewDidChange(_ textView: UITextView) {
        reviseImageMaskViewFrame()
        let range = textView.markedTextRange
        let pos = textView.position(from: textView.beginningOfDocument, offset: 0)
        if range != nil, pos != nil {
            return
        }
        self.addToHistory()
    }
}
