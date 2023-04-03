//
//  RZRichTextView.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/15.
//

import UIKit

@objcMembers
open class RZRichTextView: UITextView, UITextViewDelegate {
    /// 所有的属性设置在helper中，如果需要，可以继承RZRichTextViewHelper，并重写方法，然后设置helper
    open var helper: RZRichTextViewHelper? {
        didSet {
            self.tempDelegate?.delegate = helper
        }
    }
    /// 相关的图片配置、工具条配置等等信息
    open var options: RZRichTextViewOptions
    // 最大记录撤回数量
    open var notesCount: Int = 20 {
        didSet {
            helper?.notesCount = notesCount
        }
    }
    // 工具条
    open lazy var kinputAccessoryView = RZRichTextInputAccessoryView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44), options: self.options)

    open override var delegate: UITextViewDelegate? {
        set {
            tempDelegate?.target = newValue
            super.delegate = tempDelegate
        }
        get {
            return tempDelegate
        }
    }
 
    open override var typingAttributes: [NSAttributedString.Key : Any] {
        set {
            super.typingAttributes = newValue
        }
        get {
            var type: [NSAttributedString.Key : Any] = super.typingAttributes
            type.removeValue(forKey: .rt.originfontName) // 需要修正移除NSOriginalFont
            let range = self.selectedRange
            let tab = self.attributedText.rt.tabStyleFor(range)
            if tab != type.rt.tabStyle(), tab == .none, self.options.enableTabStyle { // 换行的时候，取到的光标属性，是上一行的属性，这里就需删掉列表属性
                if let p = type[.paragraphStyle] as? NSParagraphStyle {
                    let newp = p.rt.transParagraphTo(tab)
                    type[.paragraphStyle] = newp
                }
            }
            return type
        }
    }
    private var tempDelegate: RZRichTextViewDelegate?
    
    public init(frame: CGRect, options: RZRichTextViewOptions = .shared) {
        self.options = options
        super.init(frame: frame, textContainer: nil)
        self.font = self.options.normalFont
        let color = self.options.colors[2]
        self.textColor = color.color
        helper = .init(self, options: self.options)
        tempDelegate = .init(target: nil, delegate: self.helper)
        notesCount = 20
        self.inputAccessoryView = kinputAccessoryView
        self.delegate = self 
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension RZRichTextBase where T : UITextView {
    /// 找到range所在位置的frame，能拿到的是range.location 的 x.y 以及最后一个 range.length的maxY
    /// x, y,代表 range.location位置，是准确的，
    /// width: 默认取的textView宽度，不应当取用，要按各自需求设置，是不准确的，
    /// height 取的最后一个字的maxY - y
    func tempRectFor(range: NSRange?) -> CGRect {
        guard let range = range else {
            return .zero
        }
        let textView = self.rt
        let beginning = textView.beginningOfDocument

        guard let star = textView.position(from: beginning, offset: range.location) else { return .zero }
        guard let end = textView.position(from: beginning, offset: range.location + range.length) else { return .zero}
        let c1 = textView.caretRect(for: star)
        let c2 = textView.caretRect(for: end)
        let rect: CGRect = .init(x: c1.minX, y: c1.minY, width: textView.frame.size.width, height: c2.maxY - c1.minY)
        return rect
    }
    /// 获取range对应的frame, 这个frame只适合单排的获取，多行的时候，用temRectFor(range) 然后
    func rectFor(range: NSRange?) -> CGRect {
        guard let range = range else {
            return .zero
        }
        let textView = self.rt
        let beginning = textView.beginningOfDocument
        guard let star = textView.position(from: beginning, offset: range.location),
              let end = textView.position(from: star, offset: range.length),
              let textRange = textView.textRange(from: star, to: end) else { return .zero }
        return textView.firstRect(for: textRange)
    }
    func deleteText(for range: NSRange?) {
        if let textrange = self.textRange(for: range) {
            self.rt.replace(textrange, withText: "")
        }
    }
    func textRange(for range: NSRange?) -> UITextRange?{
        guard let range = range else {
            return nil
        }
        let textView = self.rt
        let beginning = textView.beginningOfDocument
        guard let star = textView.position(from: beginning, offset: range.location) else { return nil }
        guard let end = textView.position(from: star, offset: range.length) else { return nil }
        guard let textRange = textView.textRange(from: star, to: end) else { return nil }
        return textRange
    }
    /// 获取附件文本
    func richTextAttachments() -> [NSTextAttachment] {
        var attachments: [NSTextAttachment] = []
        self.rt.attributedText.enumerateAttribute(.attachment, in: .init(location: 0, length: self.rt.attributedText.length), options: .longestEffectiveRangeNotRequired) { value, range, _ in
            if let value = value as? NSTextAttachment {
                value.rtInfo.range = range
                attachments.append(value)
            }
        }
        return attachments
    }
}
