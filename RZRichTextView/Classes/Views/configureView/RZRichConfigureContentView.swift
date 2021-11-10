//
//  RZRichConfigureContentView.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/18.
//

import UIKit

@objcMembers
open class RZRichConfigureContentView: UIScrollView {
    open var contentView: UIStackView = .init()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        contentView.axis = .vertical
        contentView.spacing = 25
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } 
}
