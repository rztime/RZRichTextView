//
//  RZRichTableStyleView.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/21.
//

import UIKit
/// 用于设置列表样式（有序无序）的视图
open class RZRichTableStyleView: UIView {
    let viewModel: RZRichTextViewModel
    var stackView: UIStackView?
    public init(frame: CGRect, viewModel: RZRichTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.backgroundColor = .white
        
        let items = self.viewModel.tableStyleItems
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
                    self?.changedTableStyle(view)
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
    // 点击修改有序无序
    open func changedTableStyle(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        let mutablePara = NSMutableParagraphStyle.init()
        let type = RZInputAccessoryType(rawValue: btn.tag)
        func toolImage(type: RZInputAccessoryType) -> UIImage? {
            let p = self.viewModel.tableStyleItems.filter({$0.type == type})
            return p.first?.displayImage
        }
        var img: UIImage?
        switch type {
        case .t_ol:
            mutablePara.setTextListType(btn.isSelected ? .ol : .none)
            img = toolImage(type: .t_ol)
        case .t_ul:
            mutablePara.setTextListType(btn.isSelected ? .ul : .none)
            img = toolImage(type: .t_ul)
        default: break
        }
        self.viewModel.textView?.typingAttributes[.paragraphStyle] = mutablePara
        self.viewModel.textView?.reloadTextByUpdateTableStyle()
        self.reloadData()
        /// 刷新工具条
        if let item = self.viewModel.inputItems.first(where: { $0.type == .tableStyle }) {
            item.image = img
            self.viewModel.reloadDataWithAccessoryView?()
        }
    }
    open func reloadData() {
        guard let p = self.viewModel.textView?.typingAttributes[.paragraphStyle] as? NSParagraphStyle else { return }
        let isol = p.isol
        let isul = p.isul
        let btns: [UIButton]? = self.stackView?.arrangedSubviews as? [UIButton]
        btns?.forEach({ btn in
            let type = RZInputAccessoryType(rawValue: btn.tag)
            if type == .t_ol {
                btn.isSelected = isol
            } else if type == .t_ul {
                btn.isSelected = isul
            }
        })
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
