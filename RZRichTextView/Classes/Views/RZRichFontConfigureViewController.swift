//
//  RZRichFontConfigureViewController.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/17.
//

import UIKit
import Photos

@objcMembers
open class RZRichFontConfigureViewController: UIViewController {
    open var finish: (([NSAttributedString.Key: Any]) -> Void)?
    open var typingAttributes: [NSAttributedString.Key : Any]!
    open var options: RZRichTextViewOptions!
    open var backgroundView: UIView = .init()
//    open var contentView: UIStackView = .init()
    open var nav: RZRichConfigureNavView = .init(frame: .zero)
    open var displayTextLabel: RZRichConfigureDisplayLabel = .init(frame: .zero)
    open var attributeContentView: RZRichConfigureContentView = .init(frame: .zero)
    open var tempKeybordView: UIView = .init()
    open var item: RZToolBarItem = .init(type: 0)
    
    open var linkEditEnd: ((_ text: String?, _ image: UIImage?, _ asset: PHAsset?, _ url: String?) -> Void)?
    open var linkView: RZRichLinkView?
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var bounds = self.view.bounds
        bounds.origin.y = -bounds.size.height
        self.view.bounds = bounds
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            bounds.origin.y = 0
            self.view.bounds = bounds
        } completion: { _ in
            
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var bounds = self.view.bounds
        bounds.origin.y = -bounds.size.height
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.view.bounds = bounds
        } completion: { _ in
            
        }
    }
     
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.19)
        self.view.addSubview(self.backgroundView)
        self.backgroundView.addSubview(self.nav)
        self.backgroundView.addSubview(self.displayTextLabel)
        self.backgroundView.addSubview(self.attributeContentView)
        backgroundView.backgroundColor = .white
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = 10
         
        self.displayTextLabel.attributedText = NSAttributedString.init(string: "你好，Hello!\nNice to meet you!", attributes: self.typingAttributes)
        if item.items?.contains(RZTextViewFontStyle.baseOfline.rawValue) ?? false {
            self.displayTextLabel.baseofline = true
            self.displayTextLabel.tempTypingAttributes = self.typingAttributes
            self.nav.titleLabel.text = "偏移量设置"
            self.displayTextLabel.typingAttributes = self.typingAttributes
        }
        
        self.nav.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview()
            make.height.equalTo(44)
        }
        self.backgroundView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(460)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardViewChanegd(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardViewChanegd(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        nav.cancelBtn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        nav.confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        
        self.tempKeybordView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        self.configureViews()
    }
    // 配置各个界面要设置的属性的view
    open func configureViews() {
        self.fontStyleConfigure()
        self.baseofflineConfigure()
        self.strokenConfigure()
        self.shadowConfigure()
        self.expansionConfigure()
        self.paragraphConfigure()
        self.linkConfigure()
        self.tabStyleConfigure()
        self.attributeContentView.contentView.addArrangedSubview(self.tempKeybordView)
    }
    
    @objc open func cancelBtnAction() {
        NotificationCenter.default.removeObserver(self)
        self.dismiss(animated: true, completion: nil)
    }
    @objc open func confirmBtnAction() {
        NotificationCenter.default.removeObserver(self)
        self.dismiss(animated: true, completion: nil)
        if let linkView = linkView {
            let url = linkView.linkString() ?? ""
            let text = linkView.textString() ?? ""
            let image = linkView.attachmentImage()
            let asset = linkView.attachmentAsset()
            self.linkEditEnd?(text, image, asset, url)
        }
        self.finish?(self.typingAttributes)
    }
    @objc open func keyboardViewChanegd(_ noti: Notification) {
        let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        let rect = (value as AnyObject).cgRectValue ?? .zero
        let height = max(0, rect.size.height)
        self.tempKeybordView.snp.updateConstraints { make in
            make.height.equalTo(height - 100)
        }
        self.tempKeybordView.isHidden = rect.origin.y >= (UIScreen.main.bounds.size.height - 50)
        self.backgroundView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(self.tempKeybordView.isHidden ? 0 : 100)
        }
    }
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let isV = self.view.frame.size.width < self.view.frame.size.height
        var insets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
        self.backgroundView.snp.updateConstraints { make in
            make.height.equalTo(min(UIScreen.main.bounds.size.height - 100, (isV ? 460 : 250)))
        }
        let ishidden = self.displayTextLabel.isHidden
        if isV {
            self.displayTextLabel.snp.remakeConstraints { make in
                make.top.equalTo(self.nav.snp.bottom)
                make.left.right.equalToSuperview().inset(15)
                make.height.equalTo(ishidden ? 0 : 100)
            }
            self.attributeContentView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(self.displayTextLabel.snp.bottom)
            }
        } else {
            self.displayTextLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().inset(insets.left + 15)
                make.bottom.equalToSuperview()
                make.top.equalTo(self.nav.snp.bottom)
                if ishidden {
                    make.width.equalTo(0)
                } else {
                    make.right.equalTo(self.backgroundView.snp.centerX).offset(-50)
                }
            }
            self.attributeContentView.snp.remakeConstraints { make in
                make.right.equalToSuperview().inset(insets.right + 15)
                make.bottom.equalToSuperview()
                make.top.equalTo(self.displayTextLabel)
                make.left.equalTo(self.displayTextLabel.snp.right).offset(5)
            }
        }
    }
    //MARK: - 字体样式配置
    open func fontStyleConfigure() {
        let items = self.item.items ?? []
        if items.contains(RZTextViewFontStyle.bold.rawValue) || items.contains(RZTextViewFontStyle.oblique.rawValue)
            || items.contains(RZTextViewFontStyle.underline.rawValue) || items.contains(RZTextViewFontStyle.deleteLine.rawValue) {
            let view = RZRichFontStyleView.init(frame: .zero, options: self.options, typingAttributes: self.typingAttributes) { [weak self] typingAttributes in
                guard let self = self else { return }
                let orifont = (self.typingAttributes[.font] as? UIFont)?.pointSize ?? 17
                let font = (typingAttributes[.font] as? UIFont) ?? self.options.normalFont
                self.typingAttributes[.font] = font.withSize(orifont)
                self.typingAttributes[.strikethroughStyle] = typingAttributes.keys.contains(.strikethroughStyle) ?  NSUnderlineStyle.single.rawValue : nil
                self.typingAttributes[.underlineStyle] = typingAttributes.keys.contains(.underlineStyle) ?  NSUnderlineStyle.single.rawValue : nil
                self.displayTextLabel.typingAttributes = self.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(view)
        }
        if items.contains(RZTextViewFontStyle.fontSize.rawValue) {
            let font = (self.typingAttributes[NSAttributedString.Key.font] as? UIFont) ?? self.options.normalFont
            let size = font.pointSize
            let index = Int(size - 10)
            let view = RZRichTextSelectView.init(frame: .zero, rows: 91, currentIndex: index, title: "字体大小: ") { index in
                return NSAttributedString.init(string: "\(index + 10)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            } selectedIndex: { [weak self] index in
                let font = ((self?.typingAttributes[NSAttributedString.Key.font] as? UIFont) ?? self?.options.normalFont) ?? UIFont.systemFont(ofSize: 15)
                self?.typingAttributes[NSAttributedString.Key.font] = font.withSize(CGFloat(index + 10))
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(view)
            if items.contains(RZTextViewFontStyle.fontColor.rawValue) {
                let color = (self.typingAttributes[NSAttributedString.Key.foregroundColor] as? UIColor) ?? .init(red: 0, green: 0, blue: 0, alpha: 1)
                let index = self.options.colors.firstIndex(where: { c in
                    let color1 = c.color.cgColor
                    return color1 == color.cgColor
                }) ?? 0
                let view = RZRichTextSelectView.init(frame: .zero, rows: self.options.colors.count, currentIndex: index, title: "字体颜色", itemForRow: self.options.colors) { [weak self] index in
                    let color = self?.options.colors[index] ?? .init(0, 0, 0, 0)
                    self?.typingAttributes[NSAttributedString.Key.foregroundColor] = color.color
                    self?.displayTextLabel.typingAttributes = self?.typingAttributes
                }
                self.attributeContentView.contentView.addArrangedSubview(view)
            }
            if items.contains(RZTextViewFontStyle.fontBackgroundColor.rawValue) {
                let color = (self.typingAttributes[NSAttributedString.Key.backgroundColor] as? UIColor) ?? .init(red: 0, green: 0, blue: 0, alpha: 0)
                let index = self.options.colors.firstIndex(where: { c in
                    let color1 = c.color.cgColor
                    return color1 == color.cgColor
                }) ?? 0
                let view = RZRichTextSelectView.init(frame: .zero, rows: self.options.colors.count, currentIndex: index, title: "字体背景色", itemForRow: self.options.colors) { [weak self] index in
                    let color = self?.options.colors[index] ?? .init(0, 0, 0, 0)
                    self?.typingAttributes[NSAttributedString.Key.backgroundColor] = (color.r, color.g, color.b, color.a) == (0, 0, 0, 0) ? nil : color.color
                    self?.displayTextLabel.typingAttributes = self?.typingAttributes
                }
                self.attributeContentView.contentView.addArrangedSubview(view)
            }
        }
    }
    //MARK: - 偏移量设置
    open func baseofflineConfigure() {
        let items = self.item.items ?? []
        if items.contains(RZTextViewFontStyle.baseOfline.rawValue) {
            let value = (self.typingAttributes[NSAttributedString.Key.baselineOffset] as? Int) ?? 0
            let index = value + 100
            let view = RZRichTextSelectView.init(frame: .zero, rows: 201, currentIndex: index, title: "偏移量（上下标）: ") { index in
                return NSAttributedString.init(string: "\(index - 100)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            } selectedIndex: { [weak self] index in
                let value = index - 100
                self?.typingAttributes[NSAttributedString.Key.baselineOffset] = value == 0 ? nil : value
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.insertArrangedSubview(view, at: 0)
        }
    }
    //MARK: - 描边设置
    open func strokenConfigure() {
        let items = self.item.items ?? []
        if items.contains(RZTextViewFontStyle.stroken.rawValue) {
            self.nav.titleLabel.text = "描边设置"
            var value = (self.typingAttributes[NSAttributedString.Key.strokeWidth] as? Int) ?? 0
            let max = 10
            let index = value + max
            let view = RZRichTextSelectView.init(frame: .zero, rows: 21, currentIndex: index, title: "描边: ") { index in
                return NSAttributedString.init(string: "\(index - max)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            } selectedIndex: { [weak self] index in
                value = index - max
                self?.typingAttributes[NSAttributedString.Key.strokeWidth] = value == 0 ? nil : value
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.insertArrangedSubview(view, at: 0)
            
            let color = (self.typingAttributes[NSAttributedString.Key.strokeColor] as? UIColor) ?? .init(red: 0, green: 0, blue: 0, alpha: 1)
            let index1 = self.options.colors.firstIndex(where: { c in
                let color1 = c.color.cgColor
                return color1 == color.cgColor
            }) ?? 0
            let view1 = RZRichTextSelectView.init(frame: .zero, rows: self.options.colors.count, currentIndex: index1, title: "描边颜色", itemForRow: self.options.colors) { [weak self] index in
                let color = self?.options.colors[index] ?? .init(0, 0, 0, 1)
                self?.typingAttributes[NSAttributedString.Key.strokeColor] = value == 0 ? nil : color.color
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(view1)
        }
    }
    //MARK: - 阴影配置
    open func shadowConfigure() {
        let items = self.item.items ?? []
        if items.contains(RZTextViewFontStyle.shadow.rawValue) {
            self.nav.titleLabel.text = "阴影设置"
            // 阴影作为一个对象，这里需要复制一份，否则替换修改之后，原文之前的阴影都会改变
            let shadow = NSShadow.init()
            let tempShadow = (self.typingAttributes[NSAttributedString.Key.shadow] as? NSShadow)
            shadow.shadowBlurRadius = tempShadow?.shadowBlurRadius ?? 0
            shadow.shadowColor = tempShadow?.shadowColor
            shadow.shadowOffset = tempShadow?.shadowOffset ?? .init(width: 0, height: 0)
            
            let color: UIColor = (shadow.shadowColor as? UIColor) ?? .init(red: 0, green: 0, blue: 0, alpha: 0)
            let index = self.options.colors.firstIndex(where: { c in
                let color1 = c.color.cgColor
                return color1 == color.cgColor
            }) ?? 0
            let colorView = RZRichTextSelectView.init(frame: .zero, rows: self.options.colors.count, currentIndex: index, title: "阴影颜色", itemForRow: self.options.colors) { [weak self] index in
                let color = self?.options.colors[index] ?? .init(0, 0, 0, 0)
                if (color.r, color.g, color.b, color.a) == (0, 0, 0, 0) {
                    shadow.shadowColor = nil
                    self?.typingAttributes[NSAttributedString.Key.shadow] = nil
                } else {
                    shadow.shadowColor = color.color
                    self?.typingAttributes[NSAttributedString.Key.shadow] = shadow
                }
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(colorView)
            
            let view = RZRichTextSelectView.init(frame: .zero, rows: 21, currentIndex: Int(shadow.shadowBlurRadius), title: "阴影范围: ", titleForRow: { index in
                return NSAttributedString.init(string: "\(index)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }) { [weak self] index in
                shadow.shadowBlurRadius = CGFloat(index)
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(view)
            
            let max = 100
            let y = Int(shadow.shadowOffset.height) + max
            let offsetY = RZRichTextSelectView.init(frame: .zero, rows: 201, currentIndex: y, title: "阴影位置(上下): ", titleForRow: { index in
                return NSAttributedString.init(string: "\(index - max)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }) { [weak self] index in
                var offset = shadow.shadowOffset
                offset.height = CGFloat(index - max)
                shadow.shadowOffset = offset
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(offsetY)
            
            let x = Int(shadow.shadowOffset.width) + max
            let offsetX = RZRichTextSelectView.init(frame: .zero, rows: 201, currentIndex: x, title: "阴影位置(左右): ", titleForRow: { index in
                return NSAttributedString.init(string: "\(index - max)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }) { [weak self] index in
                var offset = shadow.shadowOffset
                offset.width = CGFloat(index - max)
                shadow.shadowOffset = offset
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(offsetX)
        }
    }
    //MARK: - 拉伸配置
    open func expansionConfigure() {
        let items = self.item.items ?? []
        if items.contains(RZTextViewFontStyle.expansion.rawValue) {
            self.nav.titleLabel.text = "拉伸设置"
            let max = 20
            let exp = (self.typingAttributes[NSAttributedString.Key.expansion] as? Float) ?? 0.0
            let index = Int(exp * 10) + 20
            let view = RZRichTextSelectView.init(frame: .zero, rows: 41, currentIndex: index, title: "拉伸: ", titleForRow: { index in
                return NSAttributedString.init(string: "\(Int(index - max))", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }) { [weak self] index in
                let value = Float(index - max) / 10.0
                self?.typingAttributes[NSAttributedString.Key.expansion] = value == 0 ? nil : value
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(view)
        }
    }
    //MARK: - 段落样式配置
    open func paragraphConfigure() {
        if self.item.type != RZTextViewToolbarItem.paragraph.rawValue {
            return
        }
        self.nav.titleLabel.text = "段落样式设置"
        self.displayTextLabel.attributedText = NSAttributedString.init(string: "前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落前一段落\n后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落后一段落", attributes: self.typingAttributes)
        let items = self.item.items ?? []
        let paragraph = NSMutableParagraphStyle.init()
        if let tempP = self.typingAttributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle {
            paragraph.setParagraphStyle(tempP)
        }
        if items.contains(RZTextViewFontStyle.paragraphAlignment.rawValue) {
            let view = RZRichAlignmentView.init(frame: .zero, options: self.options, aliginment: paragraph.alignment) { [weak self] aligment in
                paragraph.alignment = aligment
                self?.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraph
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(view)
        }
        if items.contains(RZTextViewFontStyle.paragraphlineMultiple.rawValue) {
            let opts = ["单倍行距", "1.5倍行距", "2倍行距", "3倍行距"]
            let values = [1, 1.5, 2, 3]
            let index = values.firstIndex(where: {$0 == paragraph.lineHeightMultiple}) ?? 0
            let linespace = RZRichTextSelectView.init(frame: .zero, rows: opts.count, currentIndex: index, title: "行间距: ", titleForRow: { index in
                return NSAttributedString.init(string: "\(opts[index])", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }, size: .init(width: 90, height: 44)) { [weak self] index in
                let v = values[index]
                paragraph.lineHeightMultiple = v
                self?.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraph
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(linespace)
        }
        if items.contains(RZTextViewFontStyle.paragraphlineSpace.rawValue) {
            let index = Int(paragraph.lineSpacing)
            let linespace = RZRichTextSelectView.init(frame: .zero, rows: 51, currentIndex: index, title: "固定行间距: ", titleForRow: { index in
                return NSAttributedString.init(string: "\(index)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }, size: .init(width: 44, height: 44)) { [weak self] index in
                paragraph.lineSpacing = CGFloat(index)
                self?.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraph
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(linespace)
        }
        if items.contains(RZTextViewFontStyle.paragraphspace.rawValue) {
            let index = Int(paragraph.paragraphSpacing)
            let linespace = RZRichTextSelectView.init(frame: .zero, rows: 51, currentIndex: index, title: "段间距: ", titleForRow: { index in
                return NSAttributedString.init(string: "\(index)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }, size: .init(width: 44, height: 44)) { [weak self] index in
                paragraph.paragraphSpacing = CGFloat(index)
                self?.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraph
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(linespace)
        }
        if items.contains(RZTextViewFontStyle.paragraphspaceBefore.rawValue) {
            let index = Int(paragraph.paragraphSpacingBefore)
            let linespace = RZRichTextSelectView.init(frame: .zero, rows: 51, currentIndex: index, title: "段后间距: ", titleForRow: { index in
                return NSAttributedString.init(string: "\(index)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }, size: .init(width: 44, height: 44)) { [weak self] index in
                paragraph.paragraphSpacingBefore = CGFloat(index)
                self?.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraph
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(linespace)
        }
        if items.contains(RZTextViewFontStyle.paragraphFirstLineHeadIndent.rawValue) {
            let font = self.typingAttributes[NSAttributedString.Key.font] as? UIFont ?? self.options.normalFont
            let index: Int = Int((paragraph.firstLineHeadIndent / font.pointSize * 10.0 / 5.0))
            let linespace = RZRichTextSelectView.init(frame: .zero, rows: 51, currentIndex: index, title: "首行缩进（字符): ", titleForRow: { index in
                return NSAttributedString.init(string: "\(Float(index * 5)/10.0)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }, size: .init(width: 44, height: 44)) { [weak self] index in
                let value = CGFloat(index * 5)/10.0 * font.pointSize
                paragraph.firstLineHeadIndent = value
                self?.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraph
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(linespace)
        }
        if items.contains(RZTextViewFontStyle.paragraphFirstLineHeadIndent.rawValue) {
            let font = self.typingAttributes[NSAttributedString.Key.font] as? UIFont ?? self.options.normalFont
            let index: Int = Int((paragraph.headIndent / font.pointSize * 10.0 / 5.0))
            let linespace = RZRichTextSelectView.init(frame: .zero, rows: 51, currentIndex: index, title: "非首行缩进（字符): ", titleForRow: { index in
                return NSAttributedString.init(string: "\(Float(index * 5)/10.0)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }, size: .init(width: 44, height: 44)) { [weak self] index in
                let value = CGFloat(index * 5)/10.0 * font.pointSize
                paragraph.headIndent = value
                self?.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraph
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(linespace)
        }
        if items.contains(RZTextViewFontStyle.paragraphTailIndent.rawValue) {
            let font = self.typingAttributes[NSAttributedString.Key.font] as? UIFont ?? self.options.normalFont
            let index: Int = Int((paragraph.tailIndent / font.pointSize))
            let linespace = RZRichTextSelectView.init(frame: .zero, rows: 51, currentIndex: index, title: "整体缩进（字符): ", titleForRow: { index in
                return NSAttributedString.init(string: "\(index)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
            }, size: .init(width: 44, height: 44)) { [weak self] index in
                let value = CGFloat(index) * font.pointSize
                paragraph.tailIndent = value
                self?.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraph
                self?.displayTextLabel.typingAttributes = self?.typingAttributes
            }
            self.attributeContentView.contentView.addArrangedSubview(linespace)
        }
    }
    // MARK: - 链接配置
    open func linkConfigure() {
        let items = self.item.items ?? []
        if items.contains(RZTextViewFontStyle.linkAttachment.rawValue) {
            self.displayTextLabel.isHidden = true
            let view = RZRichLinkView.init(frame: .zero, options: self.options)
            self.linkView = view
            self.attributeContentView.contentView.addArrangedSubview(view)
        }
    }
    // MARK: - 列表
    open func tabStyleConfigure() {
        let items = self.item.items ?? [] 
        if items.contains(RZTextViewFontStyle.tabStyle.rawValue) {
            self.displayTextLabel.attributedText = NSAttributedString.init(string: "列表\n列表", attributes: self.typingAttributes)
            let view = RZRichTabStyleView.init(frame: .zero, options: self.options, typingAttributes: self.typingAttributes) { [weak self] type in
                guard let self = self else { return }
                let attr: NSMutableAttributedString = .init()
                switch type {
                case .none:
                    attr.append(NSAttributedString.init(string: "列表\n列表"))
                case .ul:
                    if let string = NSAttributedString.rt.htmlString("<ul><li>列表</li><li>列表</li></ul>") {
                        attr.append(string)
                    }
                case .ol:
                    if let string = NSAttributedString.rt.htmlString("<ol><li>列表</li><li>列表</li></ol>") {
                        attr.append(string)
                    }
                }
                self.typingAttributes[NSAttributedString.Key.rt.tabStyle] = type
                attr.addAttributes(self.typingAttributes, range: .init(location: 0, length: attr.length))
                self.displayTextLabel.attributedText = attr
            }
            self.attributeContentView.contentView.addArrangedSubview(view)
        }
    }
}
