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
            var type = super.typingAttributes
            type.removeValue(forKey: .originfontName) // 需要修正移除NSOriginalFont
            let range = self.selectedRange
            let tab = self.attributedText.tabStyleFor(range)
            if tab != type.rztabStyle(), tab == .none, self.options.enableTabStyle { // 换行的时候，取到的光标属性，是上一行的属性，这里就需删掉列表属性
                if let p = type[.paragraphStyle] as? NSParagraphStyle {
                    let newp = p.rz_transParagraphTo(tab)
                    type[.paragraphStyle] = newp
                }
            }
            return type
        }
    }
    private lazy var tempDelegate: RZRichTextViewDelegate? = .init(target: nil, delegate: self.helper)
    
    public init(frame: CGRect, options: RZRichTextViewOptions = .shared) {
        self.options = options
        super.init(frame: frame, textContainer: nil)
        self.font = self.options.normalFont
        let color = self.options.colors[2]
        self.textColor = color.color
        helper = .init(self, options: self.options) 
        notesCount = 20
        self.inputAccessoryView = kinputAccessoryView
        self.delegate = self 
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension UITextView {
    /// 获取range对应的frame
    func rectFor(range: NSRange?) -> CGRect {
        guard let range = range else {
            return .zero
        }
        let beginning = self.beginningOfDocument
        guard let star = self.position(from: beginning, offset: range.location) else { return .zero }
        guard let end = self.position(from: star, offset: range.length) else { return .zero}
        guard let textRange = self.textRange(from: star, to: end) else { return .zero}
        return self.firstRect(for: textRange)
    }
    func deleteText(for range: NSRange?) {
        if let textrange = self.textRange(for: range) {
            self.replace(textrange, withText: "")
        }
    }
    func textRange(for range: NSRange?) -> UITextRange?{
        guard let range = range else {
            return nil
        }
        let beginning = self.beginningOfDocument
        guard let star = self.position(from: beginning, offset: range.location) else { return nil }
        guard let end = self.position(from: star, offset: range.length) else { return nil }
        guard let textRange = self.textRange(from: star, to: end) else { return nil }
        return textRange
    }
    /// 获取附件文本
    @objc func richTextAttachments() -> [NSTextAttachment] {
        var attachments: [NSTextAttachment] = []
        self.attributedText.enumerateAttribute(.attachment, in: .init(location: 0, length: attributedText.length), options: .longestEffectiveRangeNotRequired) { value, range, _ in
            if let value = value as? NSTextAttachment {
                value.rzrt.range = range
                attachments.append(value)
            }
        }
        return attachments
    }
}
