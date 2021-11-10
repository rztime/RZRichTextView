//
//  RZRichTabStyleView.swift
//  RZRichTextView
//
//  Created by rztime on 2021/11/2.
//

import UIKit
@objcMembers
open class RZRichTabStyleView: UIView {
    open var changed: ((RZTextTabStyle) -> Void)?
    open var options: RZRichTextViewOptions
    open var typingAttributes: [NSAttributedString.Key: Any]
    open var titleLabel = UILabel()
    open var contentView = UIStackView()
      
    open var custom1 : RZRichStyleButton = .init(type: .custom)
    open var custom2 : RZRichStyleButton = .init(type: .custom)
    
    public init(frame: CGRect, options: RZRichTextViewOptions, typingAttributes: [NSAttributedString.Key: Any], changed: ((RZTextTabStyle) -> Void)?) {
        self.options = options
        self.typingAttributes = typingAttributes
        super.init(frame: frame)
        self.changed = changed
        
        self.addSubview(self.titleLabel)
        self.titleLabel.text = "列表样式"
        self.titleLabel.font = .systemFont(ofSize: 15)
        self.titleLabel.textColor = UIColor.init(white: 0, alpha: 0.5)
        
        self.addSubview(contentView)
        contentView.backgroundColor =  UIColor.init(white: 0, alpha: 0.03)
        contentView.axis = .horizontal
        contentView.distribution = .fillProportionally
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true

        self.titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalTo(44)
        }
        self.contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.height.equalTo(44)
        }
        [self.custom1, self.custom2].forEach { btn in
            self.contentView.addArrangedSubview(btn)
            btn.addTarget(self, action: #selector(btnClicked(_ :)), for: .touchUpInside)
        }
        self.custom1.tag = RZTextTabStyle.ul.rawValue
        self.custom2.tag = RZTextTabStyle.ol.rawValue
        self.custom1.setImage(self.options.icon_wuxu, for: .normal)
        self.custom2.setImage(self.options.icon_youxu, for: .normal)
        
        if let para = self.typingAttributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle {
            let desc = "\(para)"
            if desc.contains(RZTextTabStyleFormat.ul) {
                self.custom1.isSelected = true
            }
            if desc.contains(RZTextTabStyleFormat.ol) {
                self.custom2.isSelected = true
            }
        }
        if self.custom1.isSelected {
            self.changed?(.ul)
        }
        if self.custom2.isSelected {
            self.changed?(.ol)
        }
    }
    
    @objc open func btnClicked(_ sender: UIButton) {
        [self.custom1, self.custom2].forEach { b in
            if b == sender {
                b.isSelected = !b.isSelected
            } else {
                b.isSelected = false
            }
        }
        let value = sender.isSelected ? sender.tag : 0
        let style = RZTextTabStyle.init(rawValue: value) ?? .none
        self.changed?(style)
    } 
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
