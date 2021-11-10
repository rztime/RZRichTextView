//
//  RZRichFontStyleView.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/18.
//

import UIKit
import AudioToolbox

@objcMembers
open class RZRichFontStyleView: UIView {
    open var changed: (([NSAttributedString.Key: Any]) -> Void)?
    open var options: RZRichTextViewOptions
    open var typingAttributes: [NSAttributedString.Key: Any]
    open var titleLabel = UILabel()
    open var contentView = UIStackView()
      
    open var boldBtn : RZRichStyleButton = .init(type: .custom)
    open var italicBtn : RZRichStyleButton = .init(type: .custom)
    open var underlineBtn : RZRichStyleButton = .init(type: .custom)
    open var deleteBtn : RZRichStyleButton = .init(type: .custom)
    
    public init(frame: CGRect, options: RZRichTextViewOptions, typingAttributes: [NSAttributedString.Key: Any], changed: (([NSAttributedString.Key: Any]) -> Void)?) {
        self.options = options
        self.typingAttributes = typingAttributes
        super.init(frame: frame)
        self.changed = changed
        
        self.addSubview(self.titleLabel)
        self.titleLabel.text = "字体样式"
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
        [self.boldBtn, self.italicBtn, self.underlineBtn, self.deleteBtn].forEach { btn in
            self.contentView.addArrangedSubview(btn)
            btn.addTarget(self, action: #selector(btnClicked(_ :)), for: .touchUpInside)
        }
        self.setUpViews()
        self.setUpButtons()
        self.boldBtn.isHidden = !self.options.fontStyleItems.contains(RZTextViewFontStyle.bold.rawValue)
        self.italicBtn.isHidden = !self.options.fontStyleItems.contains(RZTextViewFontStyle.oblique.rawValue)
        self.underlineBtn.isHidden = !self.options.fontStyleItems.contains(RZTextViewFontStyle.underline.rawValue)
        self.deleteBtn.isHidden = !self.options.fontStyleItems.contains(RZTextViewFontStyle.deleteLine.rawValue)
    }
    
    open func setUpViews() {
        if let font = typingAttributes[NSAttributedString.Key.font] as? UIFont {
            boldBtn.isSelected = self.fontIsBold(font)
            italicBtn.isSelected = self.fontIsItal(font)
        }
        let under = (typingAttributes[NSAttributedString.Key.underlineStyle] as? Int) ?? 0
        underlineBtn.isSelected = under != 0
        let delete = (typingAttributes[NSAttributedString.Key.strikethroughStyle] as? Int) ?? 0
        deleteBtn.isSelected = delete != 0
    }
    open func fontIsBold(_ font: UIFont) -> Bool {
        return font.fontName == self.options.boldFont.fontName || font.fontName == self.options.boldObliqueFont.fontName
    }
    open func fontIsItal(_ font: UIFont) -> Bool {
        return font.fontName == self.options.obliqueFont.fontName || font.fontName == self.options.boldObliqueFont.fontName
    }
     
    @objc open func btnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender {
        case boldBtn, italicBtn:
            self.setUpFont()
        case underlineBtn:
            self.typingAttributes[.underlineStyle] = (sender.isSelected ? NSUnderlineStyle.single.rawValue : nil)
        case deleteBtn:
            self.typingAttributes[.strikethroughStyle] = (sender.isSelected ? NSUnderlineStyle.single.rawValue : nil)
        default:
            break
        }
        let attr = self.typingAttributes
        self.changed?(attr)
    }
    open func setUpFont() {
        if boldBtn.isSelected && italicBtn.isSelected {
            self.typingAttributes[NSAttributedString.Key.font] = self.options.boldObliqueFont
        } else if boldBtn.isSelected && !italicBtn.isSelected {
            self.typingAttributes[NSAttributedString.Key.font] = self.options.boldFont
        } else if !boldBtn.isSelected && italicBtn.isSelected {
            self.typingAttributes[NSAttributedString.Key.font] = self.options.obliqueFont
        } else {
            self.typingAttributes[NSAttributedString.Key.font] = self.options.normalFont
        }
    }
    open func setUpButtons() {
        let normal = self.options.normalFont.withSize(20)
        let bold = self.options.boldFont.withSize(20)
        let colorl = UIColor.init(white: 0, alpha: 0.3)
        let color = UIColor.init(white: 0, alpha: 1)
        let attr = NSAttributedString.init(string: "B", attributes: [NSAttributedString.Key.font: normal, NSAttributedString.Key.foregroundColor: colorl])
        let attr1 = NSAttributedString.init(string: "B", attributes: [NSAttributedString.Key.font: bold, NSAttributedString.Key.foregroundColor: color])
        boldBtn.setAttributedTitle(attr, for: .normal)
        boldBtn.setAttributedTitle(attr1, for: .selected)
        
        let ita = self.options.obliqueFont.withSize(20)
        let bita = self.options.boldObliqueFont.withSize(20)
        let itaattr = NSAttributedString.init(string: "I", attributes: [NSAttributedString.Key.font: ita, NSAttributedString.Key.foregroundColor: colorl])
        let itaattr1 = NSAttributedString.init(string: "I", attributes: [NSAttributedString.Key.font: bita, NSAttributedString.Key.foregroundColor: color])
        italicBtn.setAttributedTitle(itaattr, for: .normal)
        italicBtn.setAttributedTitle(itaattr1, for: .selected)
         
        let underAttr = NSAttributedString.init(string: "U", attributes: [NSAttributedString.Key.font: normal, NSAttributedString.Key.foregroundColor: colorl, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        let underAttr1 = NSAttributedString.init(string: "U", attributes: [NSAttributedString.Key.font: bold, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        underlineBtn.setAttributedTitle(underAttr, for: .normal)
        underlineBtn.setAttributedTitle(underAttr1, for: .selected)
        
        let deleteAttr = NSAttributedString.init(string: "S", attributes: [NSAttributedString.Key.font: normal, NSAttributedString.Key.foregroundColor: colorl, NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        let deleteAttr1 = NSAttributedString.init(string: "S", attributes: [NSAttributedString.Key.font: bold, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        deleteBtn.setAttributedTitle(deleteAttr, for: .normal)
        deleteBtn.setAttributedTitle(deleteAttr1, for: .selected)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objcMembers
open class RZRichStyleButton: UIButton {
    open var bgView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.insertSubview(bgView, at: 0)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 3, left: 10, bottom: 3, right: 10)).priorityLow()
        }
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 5
        bgView.isUserInteractionEnabled = false
    }
    open override var isSelected: Bool {
        didSet {
            bgView.backgroundColor = isSelected ? UIColor.init(white: 0, alpha: 0.17) : nil
            if isSelected {
                AudioServicesPlaySystemSound(1519)
            }
        }
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
