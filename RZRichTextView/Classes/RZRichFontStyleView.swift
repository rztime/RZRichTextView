//
//  RZRichFontStyleView.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/20.
//

import UIKit
import QuicklySwift
import RZColorfulSwift
/// 字体样式view
open class RZRichFontStyleView: UIView {
    public enum ReloadType {
        case all
        case style
        case size
        case color
    }
    
    open var scrollView = UIScrollView()
    // 样式
    open var B = UIButton.init(type: .custom)
        .qAttributedTitle(.rz.colorfulConfer(confer: {$0.text("B")?.font(UIFont.rzboldFont.withSize(16)).textColor(.black)}))
    open var I = UIButton.init(type: .custom)
        .qAttributedTitle(.rz.colorfulConfer(confer: {$0.text("I")?.font(UIFont.systemFont(ofSize: 16)).textColor(.black).obliqueness(0.1)}))
    open var U = UIButton.init(type: .custom)
        .qAttributedTitle(.rz.colorfulConfer(confer: {$0.text("U")?.font(.systemFont(ofSize: 16)).textColor(.black).underlineStyle(.single)}))
    open var S = UIButton.init(type: .custom)
        .qAttributedTitle(.rz.colorfulConfer(confer: {$0.text("S")?.font(.systemFont(ofSize: 16)).textColor(.black).strikethroughStyle(.single)}))

    // 字号
    open var size_stackView: UIStackView?
    
    // 颜色
    open var color_stackView: UIStackView?
    
    open var viewModel: RZRichTextViewModel
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public init(frame: CGRect, viewModel: RZRichTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.backgroundColor = .white
        
        /// 字体样式
        [B, I, U, S].forEach { [weak self] btn in
            btn.qcornerRadius(3, true)
                .qbackgroundColor(.qhex(0xf3f9f9))
                .qcornerRadius(3, true)
                .qmakeConstraints({ make in
                    make.size.equalTo(CGSize.init(width: 60, height: 30))
                })
                .qisSelectedChanged { sender in
                    sender.qborder(.qhex(0xff5555), sender.isSelected ? 1 : 0)
                }
                .qtap { [weak self] view in
                    view.isSelected = !view.isSelected
                    self?.changeStyle(view)
                }
        }
        let fontstyleStackView = [B, I, U, S].qjoined(aixs: .horizontal, spacing: 10, align: .center, distribution: .equalSpacing)
        // 字号
        let label = UILabel().qtext("字号").qfont(.systemFont(ofSize: 16))
        let size_count = Int((qscreenwidth - 40) / 70)
        let sizess = self.viewModel.font_sizes.qgroup(step: size_count)
        let sizeStackView = sizess.compactMap { [weak self] items -> UIView in
            return items.compactMap { [weak self] (size, name) -> UIButton in
                return UIButton.init(type: .custom)
                    .qcornerRadius(3, true)
                    .qtitle(name)
                    .qfont(.systemFont(ofSize: CGFloat(size)))
                    .qtitleColor(.black)
                    .qbackgroundColor(.qhex(0xf3f9f9))
                    .qmakeConstraints { make in
                        make.size.equalTo(CGSize.init(width: 60, height: 30))
                    }
                    .qisSelectedChanged { sender in
                        sender.qborder(.qhex(0xff5555), sender.isSelected ? 1 : 0)
                    }
                    .qtap { [weak self] view in
                        self?.changeSize(view)
                    }
            }.qjoined(aixs: .horizontal, spacing: 10, align: .top, distribution: .equalSpacing)
        }.qjoined(aixs: .vertical, spacing: 10, align: .leading, distribution: .equalSpacing)
        self.size_stackView = sizeStackView
        
        // 颜色
        let label1 = UILabel().qtext("颜色").qfont(.systemFont(ofSize: 16))
        let lineCount = Int((qscreenwidth - 40) / 40)
        let itemss = self.viewModel.fontColors.qgroup(step: lineCount)
        let colorstackView = itemss.compactMap({ [weak self] items -> UIView in
            return items.compactMap { [weak self] color -> UIButton in
                return UIButton.init(type: .custom)
                    .qcornerRadius(2, false)
                    .qbackgroundColor(color)
                    .qmakeConstraints { make in
                        make.size.equalTo(30)
                    }
                    .qisSelectedChanged { sender in
                        sender.qborder(.qhex(0xff5555), sender.isSelected ? 1.5 : 0)
                        sender.qshadow(sender.isSelected ? .black : .clear, .init(width: 0, height: 0), radius: 3)
                    }
                    .qtap { [weak self] view in
                        self?.changeColor(view)
                    }
            }.qjoined(aixs: .horizontal, spacing: 10, align: .top, distribution: .equalSpacing)
        }).qjoined(aixs: .vertical, spacing: 10, align: .leading, distribution: .equalSpacing)
        self.color_stackView = colorstackView
        
        let stackView = [fontstyleStackView,
                         UIView.init(frame: .init(x: 0, y: 0, width: 10, height: 10)), // 间隔
                         label,
                         sizeStackView,
                         UIView.init(frame: .init(x: 0, y: 0, width: 10, height: 10)), // 间隔
                         label1,
                         colorstackView].qjoined(aixs: .vertical, spacing: 10, align: .leading, distribution: .equalSpacing)
        
        self.qbody([
            self.scrollView.qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
        self.scrollView.qbody([
            stackView.qmakeConstraints({ make in
                make.top.left.right.equalToSuperview().inset(20)
                make.width.lessThanOrEqualTo(self).offset(-40)
                make.bottom.equalToSuperview()
            })
        ])
        reloadData()
    }
    /// 改变样式
    open func changeStyle(_ btn: UIButton) {
        guard var typingAttributes = self.viewModel.textView?.getRealTypingAttributes() else { return }
        if btn == B {
            guard let font = typingAttributes[.font] as? UIFont else { return }
            let newfont: UIFont
            switch font.fontType {
            case .bold:
                newfont = UIFont.rznormalFont.withSize(font.pointSize)
            case .boldItalic:
                newfont = UIFont.rzitalicFont.withSize(font.pointSize)
            case .italic:
                newfont = UIFont.rzboldItalicFont.withSize(font.pointSize)
            case .normal:
                newfont = UIFont.rzboldFont.withSize(font.pointSize)
            }
            typingAttributes[.font] = newfont
        } else if btn == I {
            guard let font = typingAttributes[.font] as? UIFont else { return }
            let newfont: UIFont
            switch font.fontType {
            case .bold:
                newfont = UIFont.rzboldItalicFont.withSize(font.pointSize)
            case .boldItalic:
                newfont = UIFont.rzboldFont.withSize(font.pointSize)
            case .italic:
                newfont = UIFont.rznormalFont.withSize(font.pointSize)
            case .normal:
                newfont = UIFont.rzitalicFont.withSize(font.pointSize)
            }
            typingAttributes[.font] = newfont
        } else if btn == U {
            let u = U.isSelected ? 1 : 0
            typingAttributes[.underlineStyle] = u
        } else if btn == S {
            let s = S.isSelected ? 1 : 0
            typingAttributes[.strikethroughStyle] = s
        }
        self.viewModel.textView?.typingAttributes = typingAttributes
        self.viewModel.textView?.reloadText()
    }
    /// 改变字号
    open func changeSize(_ btn: UIButton) {
        if btn.isSelected { return }
        btn.isSelected = true
        guard let size = btn.titleLabel?.font.pointSize, let font = self.viewModel.textView?.getRealTypingAttributes()[.font] as? UIFont else { return }
        let newfont = font.withSize(size)
        self.viewModel.textView?.typingAttributes[.font] = newfont
        self.viewModel.textView?.reloadText()
        self.reloadData(.size)
    }
    /// 改变颜色
    open func changeColor(_ btn: UIButton) {
        if btn.isSelected { return }
        btn.isSelected = true
        self.viewModel.textView?.typingAttributes[.foregroundColor] = btn.backgroundColor
        self.viewModel.textView?.reloadText()
        self.reloadData(.color)
    }

    /// 刷新数据
    open func reloadData(_ type: RZRichFontStyleView.ReloadType = .all) {
        guard let typingAttributes = self.viewModel.textView?.getRealTypingAttributes() else { return }
        /// 刷新样式
        func reloadStyle() {
            if let font = typingAttributes[.font] as? UIFont {
                switch font.fontType {
                case .boldItalic:
                    I.isSelected = true
                    B.isSelected = true
                case .bold:
                    I.isSelected = false
                    B.isSelected = true
                case .italic:
                    I.isSelected = true
                    B.isSelected = false
                case .normal:
                    I.isSelected = false
                    B.isSelected = false
                }
            } 
            if let u = typingAttributes[.underlineStyle] as? NSNumber {
                U.isSelected = u.floatValue != 0
            } else { U.isSelected = false }
            if let s = typingAttributes[.strikethroughStyle] as? NSNumber {
                S.isSelected = s.floatValue != 0
            } else { S.isSelected = false }
        }
        /// 刷新size
        func reloadSize() {
            var size = 0
            if let font = typingAttributes[.font] as? UIFont {
                size = Int(font.pointSize)
            }
            var sizeBtns: [UIButton] = []
            size_stackView?.arrangedSubviews.forEach({ view in
                if let view = view as? UIStackView {
                    view.arrangedSubviews.forEach { view in
                        if let view = view as? UIButton {
                            sizeBtns.append(view)
                        }
                    }
                } else if let view = view as? UIButton {
                    sizeBtns.append(view)
                }
            })
            sizeBtns.forEach { btn in
                btn.isSelected = Int(btn.titleLabel?.font.pointSize ?? 0) == size
            }
        }
        /// 刷新颜色
        func reloadColor() {
            var color = UIColor.clear
            if let c = typingAttributes[.foregroundColor] as? UIColor {
                color = c
            }
            let tempcolorhex = color.qhexString
            
            var colorBtns: [UIButton] = []
            color_stackView?.arrangedSubviews.forEach({ view in
                if let view = view as? UIStackView {
                    view.arrangedSubviews.forEach { view in
                        if let view = view as? UIButton {
                            colorBtns.append(view)
                        }
                    }
                } else if let view = view as? UIButton {
                    colorBtns.append(view)
                }
            })
            colorBtns.forEach { btn in
                btn.isSelected = btn.backgroundColor?.qhexString == tempcolorhex
            }
        }
        
        switch type {
        case .all:
            reloadStyle()
            reloadSize()
            reloadColor()
        case .style:
            reloadStyle()
        case .size:
            reloadSize()
        case .color:
            reloadColor()
        }
    }
}
public extension UIFont {
    var isbold: Bool {
        return self.description.contains("bold") || self.description.contains("medium") || self.description.contains("Bold") || self.description.contains("Medium")
    }
    var isItalic: Bool {
        return self.description.contains("italic") || self.description.contains("Italic")
    }
}
