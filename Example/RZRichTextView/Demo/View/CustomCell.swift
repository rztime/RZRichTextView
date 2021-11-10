//
//  CustomCell.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2021/11/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    let imageView = UIImageView()
    let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(textLabel)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(15)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.contentView.snp.centerY)
        }
        textLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.contentView.snp.centerY)
        }
        textLabel.font = .systemFont(ofSize: 11)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
