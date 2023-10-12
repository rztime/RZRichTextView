//
//  RZRichParagraphStyleView.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/21.
//

import UIKit
import QuicklySwift
/// 用于修改段落样式的视图
open class RZRichParagraphStyleView: UIView {
    let viewModel: RZRichTextViewModel
    var stackView: UIStackView?
    public init(frame: CGRect, viewModel: RZRichTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.backgroundColor = .white
        
        let items = self.viewModel.paragraphItems
        let stackView = items.compactMap { [weak self] item -> UIView in
            return UIButton.init(type: .custom)
                .qtag(item.type.rawValue)
                .qimage(item.displayImage)
                .qmakeConstraints { make in
                    make.size.equalTo(30)
                }
                .qisSelectedChanged { sender in
                    sender.qborder(.qhex(0xff5555), sender.isSelected ? 1.5 : 0)
                    sender.qshadow(sender.isSelected ? .black : .clear, .init(width: 0, height: 0), radius: 3)
                }
                .qtap { [weak self] view in
                    self?.changedtextaligint(view)
                }
        }.qjoined(aixs: .horizontal, spacing: 10, align: .top, distribution: .equalSpacing)
            .qbackgroundColor(.white)
            .qshadow(.qhex(0x999999, a: 0.5), .init(width: 1, height: 1), radius: 3)
        
        self.stackView = stackView
        self.qbody([
            stackView.qmakeConstraints({ make in
                make.top.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
            })
        ])
        self.reloadData()
    }
    // 点击修改对齐方式
    open func changedtextaligint(_ btn: UIButton) {
        if btn.isSelected { return }
        guard let para = self.viewModel.textView?.getRealTypingAttributes()[.paragraphStyle] as? NSParagraphStyle else { return }
        let mutablePara = NSMutableParagraphStyle.init()
        mutablePara.setParagraphStyle(para)         
        let type = RZInputAccessoryType(rawValue: btn.tag)
        func toolImage(type: RZInputAccessoryType) -> UIImage? {
            let p = self.viewModel.paragraphItems.filter({$0.type == type})
            return p.first?.displayImage
        }
        var img: UIImage?
        switch type {
        case .p_left:
            mutablePara.alignment = .left
            img = toolImage(type: .p_left)
        case .p_center:
            mutablePara.alignment = .center
            img = toolImage(type: .p_center)
        case .p_right:
            mutablePara.alignment = .right
            img = toolImage(type: .p_right)
        default: break
        }
        mutablePara.setTextListType(para.rzTextListType)
        self.viewModel.textView?.typingAttributes[.paragraphStyle] = mutablePara
        self.viewModel.textView?.reloadParagraphStyle()
        self.reloadData()
        /// 刷新工具条
        if let item = self.viewModel.inputItems.first(where: {$0.type == .paragraph}) {
            item.image = img
            self.viewModel.reloadDataWithAccessoryView?()
        }
    }
    open func reloadData() {
        guard let p = self.viewModel.textView?.getRealTypingAttributes()[.paragraphStyle] as? NSParagraphStyle else { return }
        let index = p.alignment.rawValue
        let btns: [UIButton]? = self.stackView?.arrangedSubviews as? [UIButton]
        btns?.enumerated().forEach({ (idx,btn) in
            btn.isSelected = idx == index
        })
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
