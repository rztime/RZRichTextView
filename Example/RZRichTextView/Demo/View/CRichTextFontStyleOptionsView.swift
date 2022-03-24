//
//  CRichTextFontStyleOptionsView.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2021/11/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RZRichTextView

class CRichTextFontStyleOptionsView: UIView {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let stackView = UIStackView()
    let options: RZRichTextViewOptions
    var typingAttributes: [NSAttributedString.Key: Any] = [:]
    
    var textStyleView: CRichTextOptionsCell?
    var fontSizeView: CRichTextOptionsCell?
    var colorView: CRichTextOptionsCell?
    var aliginView: CRichTextOptionsCell?
    
    var changed: (([NSAttributedString.Key: Any]) -> Void)?
    
    init(frame: CGRect, options: RZRichTextViewOptions, typingAttributes: [NSAttributedString.Key: Any], changed: (([NSAttributedString.Key: Any]) -> Void)?) {
        self.options = options
        super.init(frame: frame)
        self.backgroundColor = .white
        self.typingAttributes = typingAttributes
        self.changed = changed
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 5
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(self).offset(-30)
            make.width.greaterThanOrEqualTo(290)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(34)
            make.left.right.equalToSuperview().inset(15)
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let cell1 = CRichTextOptionsCell.init(frame: .zero, itemCount: 4, size: .init(width: 60, height: 30))
        cell1.textLabel.text = "文字格式"
        let images : [UIImage?] = CRichTextConfigure.fontStyleImages
        cell1.stackView.arrangedSubviews.forEach { v in
            if let v = v as? UILabel {
                let i = v.tag
                v.rz.colorfulConfer { confer in
                    confer.image(images[i])?.size(.init(width: 15, height: 15), align: .center, font: .systemFont(ofSize: 15))
                }
            }
        }
        textStyleView = cell1
        stackView.addArrangedSubview(cell1)
        
        let cell2 = CRichTextOptionsCell.init(frame: .zero, itemCount: 4, size: .init(width: 60, height: 30))
        cell2.textLabel.text = "字号"
        let cf = CRichTextConfigure.fontsizes
        let attr : [NSAttributedString?] = [
            NSAttributedString.rz.colorfulConfer(confer: { confer in
                confer.text("小")?.font(.systemFont(ofSize: cf[0])).textColor(UIColor.init(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1))
            }),
            NSAttributedString.rz.colorfulConfer(confer: { confer in
                confer.text("标准")?.font(.systemFont(ofSize: cf[1])).textColor(UIColor.init(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1))
            }),
            NSAttributedString.rz.colorfulConfer(confer: { confer in
                confer.text("大")?.font(.systemFont(ofSize: cf[2])).textColor(UIColor.init(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1))
            }),
            NSAttributedString.rz.colorfulConfer(confer: { confer in
                confer.text("超大")?.font(.systemFont(ofSize: cf[3])).textColor(UIColor.init(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1))
            }),
        ]
        cell2.stackView.arrangedSubviews.forEach { v in
            if let v = v as? UILabel {
                let i = v.tag
                v.attributedText = attr[i]
            }
        }
        fontSizeView = cell2
        stackView.addArrangedSubview(cell2)
        
        let cell3 = CRichTextOptionsCell.init(frame: .zero, itemCount: self.options.colors.count, size: .init(width: 25, height: 25))
        cell3.textLabel.text = "颜色"
        cell3.stackView.arrangedSubviews.forEach { [weak self] v in
            let i = v.tag
            v.backgroundColor = self?.options.colors[i].color
        }
        colorView = cell3
        stackView.addArrangedSubview(cell3)
        
        let cell4 = CRichTextOptionsCell.init(frame: .zero, itemCount: 4, size: .init(width: 60, height: 30))
        cell4.textLabel.text = "对齐方式"
        let aligins : [UIImage?] = [CRichTextConfigure.aliginDefaultIcon, CRichTextConfigure.aliginLeftIcon, CRichTextConfigure.aliginCenterIcon, CRichTextConfigure.aliginrightIcon]
        cell4.stackView.arrangedSubviews.forEach { v in
            if let v = v as? UILabel {
                let i = v.tag
                v.rz.colorfulConfer { confer in
                    confer.image(aligins[i])?.size(.init(width: 15, height: 15), align: .center, font: .systemFont(ofSize: 15))
                }
            }
        }
        aliginView = cell4
        stackView.addArrangedSubview(cell4)
        
        self.setupviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let v = self.frame.size.width == max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        contentView.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(v ? 60 : 15)
        }
    }
    
    public func setupviews() {
        if let font = typingAttributes[.font] as? UIFont {
            textStyleView?.stackView.arrangedSubviews[0].layer.borderWidth = self.fontIsBold(font) ? 1 : 0
            textStyleView?.stackView.arrangedSubviews[1].layer.borderWidth = self.fontIsItal(font) ? 1 : 0
            
            let size = CGFloat(font.pointSize)
            let index = CRichTextConfigure.fontsizes.firstIndex(of: size) ?? 0
            fontSizeView?.highlightIndex(index)
        }
        let under = (typingAttributes[NSAttributedString.Key.underlineStyle] as? Int) ?? 0
        textStyleView?.stackView.arrangedSubviews[2].layer.borderWidth = under != 0 ? 1 : 0
        let delete = (typingAttributes[NSAttributedString.Key.strikethroughStyle] as? Int) ?? 0
        textStyleView?.stackView.arrangedSubviews[3].layer.borderWidth = delete != 0 ? 1 : 0
        
        let color = (self.typingAttributes[.foregroundColor] as? UIColor) ?? .init(red: 0, green: 0, blue: 0, alpha: 1)
        let index = self.options.colors.firstIndex { c in
            let color1 = c.color.cgColor
            return color1 == color.cgColor
        } ?? 0
        colorView?.highlightIndex(index)
        
        let aligin: [NSTextAlignment] = [.natural, .left, .center, .right]
        let p = (typingAttributes[.paragraphStyle] as? NSParagraphStyle) ?? .init()
        let aliginindex = aligin.firstIndex(where: {$0 == p.alignment}) ?? 0
        aliginView?.highlightIndex(aliginindex)
         
        textStyleView?.stackView.arrangedSubviews.forEach({ [weak self] v in
            v.rz.tap { [weak self] v in
                let item = CRichTextConfigure.FontStyleItem.init(rawValue: v.tag) ?? .bold
                switch item {
                case .bold:
                    if let font = self?.typingAttributes[.font] as? UIFont {
                        let isI = self?.fontIsItal(font) ?? false
                        let isB = self?.fontIsBold(font) ?? false
                        
                        var ff : UIFont?
                        if isB {
                            ff = (isI ? self?.options.obliqueFont : self?.options.normalFont)?.withSize(font.pointSize)
                        } else {
                            ff = (isI ? self?.options.boldObliqueFont : self?.options.boldFont)?.withSize(font.pointSize)
                        }
                        self?.typingAttributes[.font] = ff
                        v.layer.borderWidth = isB ? 0 : 1
                    }
                case .itial:
                    if let font = self?.typingAttributes[.font] as? UIFont {
                        let isI = self?.fontIsItal(font) ?? false
                        let isB = self?.fontIsBold(font) ?? false
                        
                        var ff : UIFont?
                        if isI {
                            ff = (isB ? self?.options.boldFont : self?.options.normalFont)?.withSize(font.pointSize)
                        } else {
                            ff = (isB ? self?.options.boldObliqueFont : self?.options.obliqueFont)?.withSize(font.pointSize)
                        }
                        self?.typingAttributes[.font] = ff
                        v.layer.borderWidth = isI ? 0 : 1
                    }
                case .underLine:
                    let under = (self?.typingAttributes[NSAttributedString.Key.underlineStyle] as? Int) ?? 0
                    if under == 0 {
                        self?.typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                    } else {
                        self?.typingAttributes[.underlineStyle] = nil
                    }
                    v.layer.borderWidth = under == 0 ? 1 : 0
                case .deleteLine:
                    let delete = (self?.typingAttributes[NSAttributedString.Key.strikethroughStyle] as? Int) ?? 0
                    if delete == 0 {
                        self?.typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                    } else {
                        self?.typingAttributes[.strikethroughStyle] = nil
                    }
                    v.layer.borderWidth = delete == 0 ? 1 : 0
                }
                self?.changed?(self?.typingAttributes ?? [:])
            }
        })
        
        fontSizeView?.stackView.arrangedSubviews.forEach({ [weak self] v in
            v.rz.tap { [weak self] v in
                let size = CRichTextConfigure.fontsizes[v.tag]
                let font = self?.typingAttributes[.font] as? UIFont ?? .init()
                self?.typingAttributes[.font] = font.withSize(size)
                self?.fontSizeView?.highlightIndex(v.tag)
                self?.changed?(self?.typingAttributes ?? [:])
            }
        })
        
        colorView?.stackView.arrangedSubviews.forEach({ [weak self] v in
            v.rz.tap { [weak self] v in
                let color = self?.options.colors[v.tag].color ?? .init(red: 0, green: 0, blue: 0, alpha: 1)
                self?.typingAttributes[.foregroundColor] = color
                self?.colorView?.highlightIndex(v.tag)
                self?.changed?(self?.typingAttributes ?? [:])
            }
        })
        
        aliginView?.stackView.arrangedSubviews.forEach({ [weak self] v in
            v.rz.tap { [weak self] v in
                let np = NSMutableParagraphStyle.init()
                np.setParagraphStyle(p)
                let a = aligin[v.tag]
                np.alignment = a
                self?.typingAttributes[.paragraphStyle] = np
                self?.aliginView?.highlightIndex(v.tag)
                self?.changed?(self?.typingAttributes ?? [:])
            }
        })
    }
    public func fontIsBold(_ font: UIFont) -> Bool {
        return font.fontName == self.options.boldFont.fontName || font.fontName == self.options.boldObliqueFont.fontName
    }
    public func fontIsItal(_ font: UIFont) -> Bool {
        return font.fontName == self.options.obliqueFont.fontName || font.fontName == self.options.boldObliqueFont.fontName
    }
}

class CRichTextOptionsCell : UIView {
    let textLabel = UILabel()
    let stackView = UIStackView()
    
    init(frame: CGRect, itemCount: NSInteger, size: CGSize) {
        super.init(frame: frame)
        
        self.addSubview(textLabel)
        self.addSubview(stackView)
        stackView.spacing = 10
        stackView.axis = .horizontal
        
        for i in 0 ..< itemCount {
            let label = UILabel.init()
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 3
            label.layer.borderColor = UIColor.init(red: 1, green: 70/255.0, blue: 70/255.0, alpha: 1).cgColor
            label.layer.borderWidth = 0
            label.textAlignment = .center
            label.tag = i
            label.backgroundColor = UIColor.init(red: 246/255.0, green: 248/255.0, blue: 253/255.0, alpha: 1)
            stackView.addArrangedSubview(label)
            label.snp.makeConstraints { make in
                make.size.equalTo(size)
            }
        }
        textLabel.font = .systemFont(ofSize: 14, weight: .medium)
        textLabel.textColor = UIColor.init(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1)
        
        textLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalTo(30)
        }
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(textLabel.snp.bottom)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func highlightIndex(_ index: Int) {
        for (i, v) in stackView.arrangedSubviews.enumerated() {
            v.layer.borderWidth = index == i ? 1 : 0
        }
    }
}
