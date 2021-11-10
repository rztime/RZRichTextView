//
//  RZRichConfigureNavView.swift
//  FBSnapshotTestCase
//
//  Created by rztime on 2021/10/18.
//

import UIKit

@objcMembers
open class RZRichConfigureNavView: UIView {
    open var cancelBtn = UIButton.init()
    open var titleLabel = UILabel.init()
    open var confirmBtn = UIButton.init()
    
    public init(frame: CGRect, title: String? = "文本设置") {
        super.init(frame: frame)
        setUpBtn(btn: cancelBtn, title: "取消", color: .init(white: 0, alpha: 0.5))
        setUpBtn(btn: confirmBtn, title: "确定", color: .init(red: 0, green: 0.7, blue: 0.4, alpha: 0.6))
        self.titleLabel.text = title
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.titleLabel.font = .systemFont(ofSize: 16)
        self.titleLabel.textColor = .init(white: 0, alpha: 0.7)
        
        cancelBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
        }
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        var insets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
        self.cancelBtn.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(insets.left)
        }
        self.confirmBtn.snp.updateConstraints { make in
            make.right.equalToSuperview().inset(insets.right)
        }
    }
     
    open func setUpBtn(btn: UIButton, title: String, color: UIColor) {
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        self.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(50)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
