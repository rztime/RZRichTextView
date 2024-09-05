//
//  RZRichTextView.swift
//  FBSnapshotTestCase
//
//  Created by rztime on 2023/7/20.
//

import UIKit
import QuicklySwift

/// 初始化TextView时，一定要设置frame.size.width，内部附件以frame的宽度来做最宽显示处理
/// 如何使用以及配置？ 请查看demo的HowToUseDemo，直接复制代码，填充选择资源、预览资源的方法就可以了
/// https://github.com/rztime/RZRichTextView/blob/master/Example/RZRichTextView/HowToUseDemo.swift
///       需要自定义附件显示的视图，请实现RZAttachmentInfoLayerProtocol，参考RZAttachmentInfoLayerView
///       并注册        RZAttachmentOption.register(attachmentLayer: UIView)
@objcMembers
open class RZRichTextView: UITextView {
    /// 将html转换为富文本时，设置的内容
    open var html: String?
    /// viewModel处理一些配置信息
    open var viewModel: RZRichTextViewModel
    /// 工具条
    open lazy var accessoryView = RZInputAccessoryView.init(frame: .init(x: 0, y: 0, width: 300, height: 44), viewModel: self.viewModel)
    /// 历史记录，记录多少条，在vm里设置
    open var history: [RZRichHistory] = []
    /// 恢复记录，
    open var stores: [RZRichHistory] = []
    /// 第一次加载
    open var isFirstLoad = true
    /// 键盘高度
    open var keyboardHeight: CGFloat = 300
    /// 显示输入字数的label
    public let inputCountLabel = UILabel().qfont(.systemFont(ofSize: 11)).qtextColor(.lightGray)
    /// 内容改变之后的回调
    open var contentChanged: ((_ textView: RZRichTextView) -> Void)?
    /// 获取文本中的所有附件
    open var attachments: [RZAttachmentInfo] {
        let atts: [RZAttachmentInfo] = self.textStorage.rt.attachments().compactMap({$0.0.rzattachmentInfo})
        return atts
    }
    /// 是否可以编辑
    open override var isEditable: Bool {
        didSet {
            if isInit { return }
            self.viewModel.canEdit = isEditable
            if enable && isEditable {
                self.inputAccessoryView = accessoryView
            } else {
                self.inputAccessoryView = nil
            }
            self.fixAttachmentInfo()
        }
    }
    /// false时，当做普通输入框
    open var enable: Bool = true {
        didSet {
            if enable && isEditable {
                self.inputAccessoryView = accessoryView
            } else {
                self.inputAccessoryView = nil
            }
            self.fixAttachmentInfo()
        }
    }
    /// 用于计算整个内容完全显示时的高度
    open var contentTextHeight: CGFloat {
        return self.contentSize.height + self.contentInset.top + self.contentInset.bottom
    }
    /// 记录最新一次attachments，主要用于对比是否有删除的附件，然后删除额外添加的界面
    open var lastAttachments: [RZAttachmentInfo] = []
    private var isInit = true    
    /// 用于记录光标在末尾时的属性
    open var lastTexttypingAttributes: [NSAttributedString.Key: Any] = [:]
    private var lastCursorIsEnd = true
    /// viewModel可以自行设置使用一个单例，用于图片、视频、音频等附件输入时，统一处理，一定要设置frame的width
    public init(frame: CGRect, viewModel: RZRichTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame, textContainer: nil)
        self.layoutManager.allowsNonContiguousLayout = false
        isInit = false
        self.viewModel.textView = self
        self.isEditable = self.viewModel.canEdit
        if self.isEditable {
            self.inputAccessoryView = accessoryView
        }
        accessoryView.viewModel = self.viewModel
        accessoryView.clicked = { [weak self] item in
            self?.didClickedAccessoryItem(item)
        }
        self.linkTextAttributes = self.viewModel.defaultLinkTypingAttributes
        self.typingAttributes = self.viewModel.defaultTypingAttributes
        self.lastTexttypingAttributes = self.typingAttributes
        NotificationCenter.qaddKeyboardObserver(target: self, object: nil) { [weak self] keyboardInfo in
            self?.keyboardHeight = keyboardInfo.frameEnd.size.height - 44
        }
        self
            .qdidChangeSelection { [weak self] textView in
                guard let self = self else { return }
                if let _ = textView.inputView {
                    textView.inputView = nil
                    textView.reloadInputViews()
                }
                self.fixTypingAttributes()
            }
            .shouldInteractWithURL { [weak self] textView, url, range, interaction in
                if textView.isEditable {
                    self?.changeLink(range: range, link: url)
                    return false
                }
                if let s = self?.viewModel.shouldInteractWithURL {
                    return s(url.absoluteString)
                }
                return true
            }
            .qshouldChangeText { [weak self] textView, range, replaceText in
                guard let self = self else { return true }
                if textView.textStorage.length == range.location {
                    textView.typingAttributes = self.lastTexttypingAttributes
                }
                if self.viewModel.removeLinkWhenInputText, let _ = textView.typingAttributes[.link] {
                    textView.typingAttributes = self.lastTexttypingAttributes
                    textView.typingAttributes[.link] = nil
                }
                if range.length == 0 && range.location == 0 && replaceText == "", let p = textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle, p.isol || p.isul {
                    let newp = NSMutableParagraphStyle.init()
                    newp.alignment = p.alignment
                    textView.typingAttributes[.paragraphStyle] = newp
                    self.reloadTextByUpdateTableStyle()
                }
                return true
            }
            .qshouldBeginEditing({ [weak self] textView in
                if self?.isFirstLoad ?? true {
                    self?.addHistoryData()
                    self?.isFirstLoad = false
                }
                return true
            })
            .qtextChanged { [weak self] textView in
                self?.contentTextChanged()
            }
        /// 显示字数
        self.qshowToWindow { [weak self] view, showed in
            if let v = view.superview, let self = self, showed {
                v.qbody([self.inputCountLabel])
                self.inputCountLabel.snp.remakeConstraints { make in
                    switch self.viewModel.countLabelLocation {
                    case .topLeft(let x, let y):
                        make.top.equalTo(view).inset(y)
                        make.left.equalTo(view).inset(x)
                    case .topRight(let x, let y):
                        make.top.equalTo(view).inset(y)
                        make.right.equalTo(view).inset(x)
                    case .bottomLeft(let x, let y):
                        make.bottom.equalTo(view).inset(y)
                        make.left.equalTo(view).inset(x)
                    case .bottomRight(let x, let y):
                        make.bottom.equalTo(view).inset(y)
                        make.right.equalTo(view).inset(x)
                    }
                }
            }
        }
        switch self.viewModel.showcountType {
        case .hidden:
            inputCountLabel.isHidden = true
            self.contentInset  = .init(top: 5, left: 3, bottom: 5, right: 0)
        case .showcount, .showcountandall:
            inputCountLabel.isHidden = false
            self.contentInset  = .init(top: 5, left: 3, bottom: 20, right: 0)
        }
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        self.showInputCount()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 点击工具栏的操作
    open func didClickedAccessoryItem(_ item: RZInputAccessoryItem?) {
        guard let item = item else { return }
        /// 如果有自定义已经实现了方法，则不做处理
        if let res = self.viewModel.didClickedAccessoryItem, res(item) {
            return
        }
        switch item.type {
        case .none:
            break
        case .fontStyle: /// 字体样式
            if didshowInputView(RZRichFontStyleView.self) {
                self.inputView = nil
                self.reloadInputViews()
                return
            }
            let height = self.keyboardHeight < 300 ? 300 : self.keyboardHeight
            let view = RZRichFontStyleView.init(frame: .init(x: 0, y: 0, width: qscreenwidth, height: height), viewModel: self.viewModel)
            self.inputView = view
            self.reloadInputViews()
        case .tableStyle:   /// 列表样式
            if didshowInputView(RZRichTableStyleView.self) {
                self.inputView = nil
                self.reloadInputViews()
                return
            }
            let height = self.keyboardHeight < 300 ? 300 : self.keyboardHeight
            let view = RZRichTableStyleView.init(frame: .init(x: 0, y: 0, width: qscreenwidth, height: height), viewModel: self.viewModel)
            self.inputView = view
            self.reloadInputViews()
        case .paragraph:    /// 段落样式
            if didshowInputView(RZRichParagraphStyleView.self) {
                self.inputView = nil
                self.reloadInputViews()
                return
            }
            let height = self.keyboardHeight < 300 ? 300 : self.keyboardHeight
            let view = RZRichParagraphStyleView.init(frame: .init(x: 0, y: 0, width: qscreenwidth, height: height), viewModel: self.viewModel)
            self.inputView = view
            self.reloadInputViews()
        case .media:
            break
        case .link: /// 链接
            if let _ = self.inputView {
                self.inputView = nil
                self.reloadInputViews()
            }
            self.changeLink(range: self.selectedRange, link: nil)
        case .revoke:       /// 撤回
            if let last = self.history[qsafe: self.history.count - 2] {
                self.textStorage.setAttributedString(last.attr)
                self.typingAttributes = last.typingAttributes
                self.selectedRange = last.selectedRange
            }
            if let current = self.history[qsafe: self.history.count - 1] {
                self.stores.insert(current, at: 0)
                self.history.remove(at: self.history.count - 1)
            }
            self.reloadRevokeAndRestore()
        case .restore:  ///  恢复
            if let current = self.stores.first {
                self.textStorage.setAttributedString(current.attr)
                self.typingAttributes = current.typingAttributes
                self.selectedRange = current.selectedRange
                self.stores.removeFirst()
                self.history.append(current)
            }
            self.reloadRevokeAndRestore()
        case .close:    /// 关闭键盘
            if let _ = self.inputView {
                self.inputView = nil
                self.reloadInputViews()
            } else {
                self.endEditing(true)
            }
        default: break
        }
    }
    /// 显示了inputView
    open func didshowInputView(_ objclass: AnyClass) -> Bool {
        guard let inputView = self.inputView else { return false }
        return inputView.isKind(of: objclass)
    }
    /// 刷新内容 修改了typingAttributes，刷新内容
    open func reloadText() {
        defer {
            self.fixTypingAttributes()
        }
        guard selectedRange.length > 0 else { return }
        self.textStorage.addAttributes(self.typingAttributes, range: selectedRange)
        self.selectedRange = selectedRange
        self.contentTextChanged()
    }
    /// 修改段落样式，需要将样式写入typingAttributes
    open func reloadParagraphStyle() {
        defer {
            self.fixTypingAttributes()
        }
        guard let paragraph = self.typingAttributes[.paragraphStyle] as? NSParagraphStyle else { return }
        var ranges = self.attributedText.rt.paragraphRanges(for: selectedRange)
        if ranges.count == 0 {
            ranges.append(self.selectedRange)
        }
        ranges.forEach { range in
            self.textStorage.addAttribute(.paragraphStyle, value: paragraph, range: range)
        }
        self.selectedRange = selectedRange
        self.contentTextChanged()
    }
    /// 修改了列表样式时更新,需要将样式写入typingAttributes
    open func reloadTextByUpdateTableStyle() {
        defer {
            self.fixTypingAttributes()
        }
        guard let paragraph = self.typingAttributes[.paragraphStyle] as? NSParagraphStyle else { return }
        let ranges = self.attributedText.rt.paragraphRanges(for: self.selectedRange)
        ranges.forEach { range in
            self.textStorage.addAttribute(.paragraphStyle, value: paragraph, range: range)
        }
        self.selectedRange = selectedRange
        self.contentTextChanged()
    }
    /// 编辑链接
    open func changeLink(range: NSRange, link: URL?) {
        defer {
            self.fixTypingAttributes()
        }
        let string = self.textStorage.attributedSubstring(from: range).string
        if string.count == 0, !self.canInsertContent() {
            self.viewModel.morethanInputLength?()
            return
        }
        RZLinkInputViewController.show(text: string, link: link?.absoluteString) { [weak self] text, link in
            guard let self = self else { return }
            if let link = link, link.count > 0 {
                self.textStorage.addAttribute(.link, value: link as Any, range: range)
            } else {
                self.textStorage.removeAttribute(.link, range: range)
            }
            if let temp = text ?? link {
                var typingattri = self.typingAttributes
                typingattri[.link] = link
                let attr = NSAttributedString.init(string: temp, attributes: typingattri)
                self.textStorage.replaceCharacters(in: range, with: attr)
                self.selectedRange = NSRange.init(location: range.lowerBound + attr.length, length: 0)
            }
            self.contentTextChanged()
        }
    }
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        if v == self {
            if let _ = self.inputView {
                self.inputView = nil
                self.reloadInputViews()
            }
        }
        return v
    }
    deinit {
        /// infoLayer里info有相互引用，所以这里强行移除，用于释放
        let vs = self.subviews.filter({$0.tag == 10})
        vs.forEach({$0.qremoveAllSubViews()})
    }
}
public extension RZRichTextView {
    /// 判断当前是否可以写入内容，超字数后，不可插入
    /// 如通过工具栏功能，选择插入附件、链接等等功能时，字数已达上限，此时进行了附件操作，但是插入之后又被截掉，导致操作无效，所以需提前判断
    func canInsertContent() -> Bool {
        if self.viewModel.maxInputLenght == 0 { return true }
        let selectedRange = self.selectedRange
        if selectedRange.location == 0 { return true }
        let x = self.textStorage.attributedSubstring(from: .init(location: 0, length: selectedRange.location)).string.count
        return x < self.viewModel.maxInputLenght
    }
    /// 添加历史记录
    func addHistoryData() {
        let history = RZRichHistory(attr: self.textStorage, selectedRange: self.selectedRange, typingAttributes: self.typingAttributes)
        self.history.append(history)
        if self.history.count > self.viewModel.historyCount + 1 {
            self.history.removeFirst()
        }
        if let value = self.viewModel.lockInputItems.first(where: {$0.type == .revoke}) {
            value.selected = self.history.count > 1
        }
        self.stores.removeAll()
        if let value = self.viewModel.lockInputItems.first(where: {$0.type == .restore}) {
            value.selected = false
        }
        self.accessoryView.reloadData()
    }
    /// 插入附件
    func insetAttachment(_ attachmentinfo: RZAttachmentInfo) {
        let attachment = NSTextAttachment.createWithinfo(attachmentinfo)
        let attr = NSMutableAttributedString.init(attachment: attachment)
        attr.addAttributes(self.typingAttributes, range: .init(location: 0, length: attr.length))
        self.textStorage.replaceCharacters(in: self.selectedRange, with: attr)
        self.selectedRange = NSRange.init(location: self.selectedRange.lowerBound + attr.length, length: 0)
        if let d = self.delegate {
            d.textViewDidChange?(self)
        } else {
            self.contentTextChanged()
        }
    }
    /// 删除附件
    func removeAttachment(_ attachmentInfo: RZAttachmentInfo?) {
        guard let attachmentInfo = attachmentInfo else { return }
        attachmentInfo.infoLayer.removeFromSuperview()

        let ats = self.textStorage.rt.attachments()
        ats.reversed().forEach { [weak self] attachment, range in
            if attachment.rzattachmentInfo == attachmentInfo {
                self?.textStorage.deleteCharacters(in: range)
            }
        }
        if let d = self.delegate {
            d.textViewDidChange?(self)
        } else {
            self.contentTextChanged()
        }
    }
    /// 插入了附件之后，需要fix附件相关的界面
    func fixAttachmentInfo() {
        /// 修正一下附件在textView中的位置，当设置了列表的时候，附件显示宽度被压缩，此时重新设置一下附件宽高
        func fixAttachmentBounds() {
            self.textStorage.ensureAttributesAreFixed(in: .init(location: 0, length: self.textStorage.length))
            self.layoutIfNeeded()
            self.textStorage.enumerateAttribute(.attachment, in: .init(location: 0, length: self.textStorage.length)) { [weak self] value, range, _ in
                guard let self = self, let value = value as? NSTextAttachment, let info = value.rzattachmentInfo else { return }
                var frame = self.qfistRect(for: range)
                /// 某些机型可能会出现无法获取位置，导致计算错误，这个地方使用这个兜底
                if frame.origin.x.isInfinite || frame.origin.x.isNaN {
                    frame = .init(x: 5, y: 0, width: 0, height: 0)
                }
                var size: CGSize?
                let lineWidth = self.frame.size.width - frame.minX - 5   // 当前行附件可显示的最大宽度
                let edgeinsets = (info.infoLayer.subviews.first { v -> Bool in
                    if let _ = v as? RZAttachmentInfoLayerProtocol {
                        return true
                    }
                    return false
                } as? RZAttachmentInfoLayerProtocol)?.imageViewEdgeInsets ?? .init(top: 15, left: 3, bottom: 0, right: 15)
                switch info.type {
                case .image, .video:
                    if let image = info.image {
                        let imageMaxWidth = lineWidth - (edgeinsets.left + edgeinsets.right) // 图片可显示的最大宽度
                        let imageSize = image.size.qscaleto(maxWidth: imageMaxWidth)        // 图片真实size
                        let realSize = CGSize.init(width: imageSize.width + (edgeinsets.left + edgeinsets.right), height: imageSize.height + (edgeinsets.top + edgeinsets.bottom)) // 附件的真实size（是由图片+边距计算得到的）
                        if abs(frame.size.width - realSize.width) > 5 || abs(frame.size.height - realSize.height) > 10 {
                            size = realSize
                        }
                    }
                case .audio:
                    let h = self.viewModel.audioAttachmentHeight + (edgeinsets.top + edgeinsets.bottom)
                    if abs(lineWidth - frame.size.width) > 5 || abs(frame.size.height - h) > 10   {
                        size = .init(width: lineWidth, height: h)
                    }
                }
                if let size = size, size.width > 0 {
                    value.bounds = .init(origin: .zero, size: size)
                    let attr = NSMutableAttributedString.init(attributedString: .init(attachment: value))
                    attr.addAttributes(self.textStorage.attributes(at: range.location, effectiveRange: nil), range: .init(location: 0, length: attr.length))
                    let selctedRange = self.selectedRange
                    self.textStorage.replaceCharacters(in: range, with: attr)
                    self.layoutIfNeeded()
                    self.selectedRange = selctedRange
                }
            }
        }
        /// 将相关方法延迟加载，是为了在附件绘制完成之后，在获取位置
        func fixAttachmentViewFrame() {
            self.textStorage.ensureAttributesAreFixed(in: .init(location: 0, length: self.textStorage.length))
            self.layoutIfNeeded()
            var changed = false
            /// 将现有的附件额外添加的视图更新位置
            self.textStorage.enumerateAttribute(.attachment, in: .init(location: 0, length: self.textStorage.length)) { [weak self] value, range, _ in
                if let self = self, let value = value as? NSTextAttachment {
                    if let info = value.rzattachmentInfo {
                        let frame = self.rz.rectFor(range: range) ?? .zero
                        /// 在textView加载内容过程中，执行了此方法的话，frame会无法获取准确数据，所以这里要做一个判断
                        if frame.origin.x.isInfinite || frame.origin.x.isNaN ||
                            frame.origin.y.isInfinite || frame.origin.y.isNaN {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                self.fixAttachmentInfo()
                            })
                            return
                        }
                        info.infoLayer.frame = frame
                        if info.infoLayer.superview == nil {
                            self.addSubview(info.infoLayer)
                            changed = true
                        }
                        if let v = info.infoLayer.subviews.first as? RZAttachmentInfoLayerProtocol {
                            v.canEdit = self.viewModel.canEdit
                            v.showAudioName = self.viewModel.showAudioName
                        } else {
                            let infoView = RZAttachmentOption.share.viewclass.init()
                            info.infoLayer.qbody([
                                infoView.qmakeConstraints({ make in
                                    make.edges.equalToSuperview().inset(1)
                                })])
                            if let infoView = infoView as? RZAttachmentInfoLayerProtocol {
                                infoView.info = info
                                infoView.canEdit = self.viewModel.canEdit
                                infoView.showAudioName = self.viewModel.showAudioName
                                self.viewModel.reloadAttachmentInfoIfNeed?(infoView)
                            }
                        }
                    }
                }
            }
            /// 筛选出已删除的附件，并移除
            let newattachments = self.attachments
            let deletedAttachments = lastAttachments.filter { info in
                if let _ = newattachments.firstIndex(where: {$0 == info}) {
                    return false
                }
                return true
            }
            deletedAttachments.forEach({ $0.infoLayer.removeFromSuperview() })
            if deletedAttachments.count > 0 {
                changed = true
            }
            /// 记录现有的
            self.lastAttachments = newattachments
            if changed {
                self.viewModel.attachmentInfoChanged?(newattachments)
            }
        }
        fixAttachmentBounds()
        DispatchQueue.main.async {
            fixAttachmentViewFrame()
            self.fixTextlistNum()
        }
    }
    /// 内容改变之后，需要修复附件的位置、以及判断是否超字数
    func contentTextChanged() {
        defer {
            self.contentChanged?(self)
            ///  重新校验显示placeholder
            DispatchQueue.main.async {
                self.fixAttachmentInfo()
                self.showInputCount()
                self.showPlaceHolder()
            }
        }
        if self.isFirstResponder {
            /// 在有中文输入拼音高亮时，不做处理
            let language = UIApplication.shared.textInputMode?.primaryLanguage
            if language?.hasPrefix("zh-Han") ?? false {
                let position = self.position(from: (self.markedTextRange ?? .init()).start, offset: 0)
                if position != nil {
                    return
                }
            }
        }
        /// 如果超过字数限制，则将移除超过的内容
        let max: Int = Int(self.viewModel.maxInputLenght)
        let text = self.textStorage.string
        let length = text.count
        if length > max, self.isEditable {
            let newText = text.qsubstring(emoji: .count, to: max) as NSString
            if newText.length < self.textStorage.length {
                self.textStorage.replaceCharacters(in: .init(location: newText.length, length: self.textStorage.length - newText.length), with: "")
                self.viewModel.morethanInputLength?()
            }
        }
        self.addHistoryData()
    }
    /// 显示输入字符串个数
    func showInputCount() {
        switch self.viewModel.showcountType {
        case .hidden: break
        case .showcount:
            self.inputCountLabel.text = "\(self.textStorage.string.count)"
        case .showcountandall:
            self.inputCountLabel.text = "\(self.textStorage.string.count)/\(self.viewModel.maxInputLenght)"
        }
    }
    /// 刷新撤回、恢复的item
    func reloadRevokeAndRestore() {
        if let value = self.viewModel.lockInputItems.first(where: {$0.type == .revoke}) {
            value.selected = self.history.count > 1
        }
        if let value = self.viewModel.lockInputItems.first(where: {$0.type == .restore}) {
            value.selected = self.stores.count > 0
        }
        self.accessoryView.reloadData()
        self.fixAttachmentInfo()
        self.showPlaceHolder()
    }
    /// fix光标在末尾时的属性
    /// 光标在末尾时，修改了属性但是未输入内容，移开之后再回来，修改的属性会丢失，所以这里加一个fix
    func fixTypingAttributes() {
        if self.textStorage.length == self.selectedRange.location {
            if self.lastCursorIsEnd {
                /// 当光标在末尾的时候，记录一下末尾的属性
                self.lastTexttypingAttributes = self.typingAttributes
            } else {
                self.typingAttributes = self.lastTexttypingAttributes
            }
        }
        self.lastCursorIsEnd = self.selectedRange.location == self.textStorage.length || self.selectedRange.upperBound == self.textStorage.length
    }
    /// 获取真实的属性
    func getRealTypingAttributes() -> [NSAttributedString.Key: Any] {
        if self.textStorage.length == self.selectedRange.location {
            return self.lastTexttypingAttributes
        }
        return self.typingAttributes
    }
}
public extension RZRichTextView {
    /// 是否显示隐藏placeholder
    func showPlaceHolder() {
        DispatchQueue.main.async {
            /// 有序无序列表会占用
            let show = self.textStorage.length == 0 && self.subviews.filter({$0.isKind(of: RZTextListView.self)}).count == 0
            self.qtextViewHelper.placeHolderLabel?.isHidden = !show
        }
    }
    /// 修复有序无序列表的序列号
    func fixTextlistNum() {
        self.subviews.filter({$0.isKind(of: RZTextListView.self)}).forEach({$0.removeFromSuperview()})
        let all = self.textStorage.rt.allParapraghRange()
        var temp : [(String, NSRange, NSParagraphStyle, [NSAttributedString.Key: Any])] = []
        var index = 0
        var lastType = NSParagraphStyle.RZTextListType.none
        all.forEach { range in
            var dict: [NSAttributedString.Key: Any] = [:]
            if range == self.selectedRange {
                dict = self.typingAttributes
            } else if range.location < self.textStorage.length {
                dict = self.textStorage.attributes(at: range.location, effectiveRange: nil)
            } else {
                dict = self.lastTexttypingAttributes
            }
            if let p = dict[.paragraphStyle] as? NSParagraphStyle {
                if p.isol {
                    if lastType == .ol {
                        index += 1
                    } else {
                        index = 1
                    }
                    lastType = .ol
                    temp.append(("\(index).", range, p, dict))
                } else if p.isul {
                    if lastType == .ul {
                        index += 1
                    } else {
                        index = 1
                    }
                    lastType = .ul
                    temp.append((viewModel.ulSymbol, range, p, dict))
                } else {
                    lastType = .none
                    index = 0
                }
            } else {
                lastType = .none
                index = 0
            }
        }
        temp.forEach { (index, range, p, dict) in
            if index != "" {
                let rect = self.qcaretRect(for: range.location)
                let view = RZTextListView.init().qframe(.init(x: 3, y: rect.origin.y, width: 30, height: rect.size.height))
                    .qfont(viewModel.ulSymbolFont ?? (dict[.font] as? UIFont) ?? .systemFont(ofSize: 16))
                    .qtextColor((dict[.foregroundColor] as? UIColor) ?? .black)
                    .qtext("\(index)")
                    .qtextAliginment(viewModel.ulSymbolAlignment)
                self.addSubview(view)
            }
        }
    }
}
/// 历史记录
open class RZRichHistory {
    let attr: NSAttributedString
    let selectedRange: NSRange
    let typingAttributes: [NSAttributedString.Key: Any]
    
    init(attr: NSAttributedString, selectedRange: NSRange, typingAttributes: [NSAttributedString.Key : Any]) {
        self.attr = NSAttributedString.init(attributedString: attr)
        self.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length)
        let newtyping: NSMutableDictionary = .init()
        newtyping.addEntries(from: typingAttributes)
        self.typingAttributes = newtyping as! [NSAttributedString.Key : Any]
    }
}
/// 用于显示列表的序号， 这个是为了方便找到列表view
public class RZTextListView: UILabel {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.textAlignment = .right
        self.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
