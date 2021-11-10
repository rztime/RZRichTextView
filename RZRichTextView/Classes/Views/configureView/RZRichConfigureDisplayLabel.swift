//
//  RZRichConfigureDisplayLabel.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/18.
//

import UIKit

@objcMembers
open class RZRichConfigureDisplayLabel: UIView {
    open var attributedText: NSAttributedString? {
        didSet {
            textLabel.attributedText = nil // 需要重置，在某些时候，修改attributedText，部分属性预览时无法改变，重置之后在设置就没问题
            textLabel.attributedText = self.attributedText
        }
    }
    open var typingAttributes: [NSAttributedString.Key: Any]? {
        didSet {
            if !baseofline {
                let attr = NSAttributedString.init(string: self.attributedText?.string ?? "", attributes: typingAttributes)
                self.attributedText = attr
            } else {
                let strings = self.baseoflineText.components(separatedBy: "\n")
                let attr = NSMutableAttributedString.init(string: strings.first ?? "你好，Hello!", attributes: tempTypingAttributes)
                let baseofline = NSAttributedString.init(string: "正文\n", attributes: typingAttributes)
                let attr1 = NSAttributedString.init(string: strings.last ?? "Nice to meet you!", attributes: tempTypingAttributes)
                let baseofline1 = NSAttributedString.init(string: "正文\n", attributes: typingAttributes)
                attr.append(baseofline)
                attr.append(attr1)
                attr.append(baseofline1)
                self.attributedText = attr
            }
        }
    }
    private var tempHeight: CGFloat = 0
    open override var isHidden: Bool {
        didSet {
            self.snp.updateConstraints { make in
                make.height.equalTo(isHidden ? 0 : tempHeight)
            }
        }
    }
    /// 设置偏移量时，将使用到这两个参数
    open var baseofline = false
    open var tempTypingAttributes: [NSAttributedString.Key: Any]?
    open var baseoflineText = "你好，Hello！\nNice to meet you!"
    
    private var scrollView: UIScrollView = .init()
    private var textLabel: UILabel = .init()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        scrollView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.width.equalTo(self)
            make.bottom.equalToSuperview()
        } 
        textLabel.numberOfLines = 0
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.frame.size.height != 0 {
            self.tempHeight = self.frame.size.height
        }
    }
}
