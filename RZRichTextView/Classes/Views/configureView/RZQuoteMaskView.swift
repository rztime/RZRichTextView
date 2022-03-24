//
//  RZQuoteMaskView.swift
//  RZRichTextView
//
//  Created by rztime on 2022/3/24.
//

import UIKit
 
open class RZQuoteMaskView: UIView {
    open var leftLine = UIView()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.addSubview(leftLine)
        leftLine.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        leftLine.backgroundColor = UIColor.init(red: 0.5, green: 0.9, blue: 0.9, alpha: 1)
        self.backgroundColor = UIColor.init(red: 0.8, green: 0.9, blue: 0.9, alpha: 1)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
