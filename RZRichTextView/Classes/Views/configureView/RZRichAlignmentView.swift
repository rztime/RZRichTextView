//
//  RZRichAlignmentView.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/19.
//

import UIKit

@objcMembers
open class RZRichAlignmentView: UIView {
    open var changed: ((NSTextAlignment) -> Void)?
    open var options: RZRichTextViewOptions
    open var titleLabel = UILabel()
    open var contentView = UIStackView()
    open var defaultBtn : RZRichStyleButton = .init(type: .custom)
    open var leftBtn : RZRichStyleButton = .init(type: .custom)
    open var centerBtn : RZRichStyleButton = .init(type: .custom)
    open var rightBtn : RZRichStyleButton = .init(type: .custom)
    
    public init(frame: CGRect, options: RZRichTextViewOptions, aliginment: NSTextAlignment, changed: ((NSTextAlignment) -> Void)?) {
        self.options = options
        super.init(frame: frame)
        self.changed = changed
        
        self.addSubview(self.titleLabel)
        self.titleLabel.text = "段落样式"
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
        [self.defaultBtn, self.leftBtn, self.centerBtn, self.rightBtn].forEach { btn in
            self.contentView.addArrangedSubview(btn)
            btn.addTarget(self, action: #selector(btnClicked(_ :)), for: .touchUpInside)
        }
        
        self.defaultBtn.setImage(self.options.icon_dqdefault, for: .normal)
        self.leftBtn.setImage(self.options.icon_dqleft, for: .normal)
        self.centerBtn.setImage(self.options.icon_dqcenter, for: .normal)
        self.rightBtn.setImage(self.options.icon_dqright, for: .normal)
        
        self.defaultBtn.tag = NSTextAlignment.natural.rawValue
        self.leftBtn.tag = NSTextAlignment.left.rawValue
        self.centerBtn.tag = NSTextAlignment.center.rawValue
        self.rightBtn.tag = NSTextAlignment.right.rawValue
        
        switch aliginment {
        case .left:
            self.leftBtn.isSelected = true
        case .center:
            self.centerBtn.isSelected = true
        case .right:
            self.rightBtn.isSelected = true
        case .natural:
            self.defaultBtn.isSelected = true
        default:
            break
        }
    }
     
    @objc open func btnClicked(_ sender: UIButton) {
        [self.defaultBtn, self.leftBtn, self.centerBtn, self.rightBtn].forEach { btn in
            btn.isSelected = btn == sender
        }
        self.changed?(NSTextAlignment.init(rawValue: sender.tag) ?? .natural)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
