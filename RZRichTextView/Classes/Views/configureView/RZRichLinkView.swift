//
//  RZRichLinkView.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/20.
//

import UIKit
import Photos

@objcMembers
open class RZRichLinkView: UIView {
    open var contentView = UIView()
    
    open var linkTitleLabel = UILabel.init()
    open var linkTextField = UITextField.init()
    open var textLabel = UILabel.init()
    open var textField = UITextField.init()
    open var attachmentLabel = UILabel.init()
    open var attachmentBtn = UIButton.init(type: .custom)
    
    open var deleteBtn = UIButton.init(type: .custom)
    
    open var image: UIImage? {
        didSet {
            attachmentBtn.setImage(image ?? options.icon_attachment, for: .normal)
            deleteBtn.isHidden = image == nil
        }
    }
    open var asset: PHAsset?
    
    open var options: RZRichTextViewOptions
    
    public init(frame: CGRect, options: RZRichTextViewOptions) {
        self.options = options
        
        super.init(frame: frame)
        self.addSubview(contentView)
        
        contentView.addSubview(linkTitleLabel)
        contentView.addSubview(linkTextField)
        contentView.addSubview(textLabel)
        contentView.addSubview(textField)
        contentView.addSubview(attachmentLabel)
        contentView.addSubview(attachmentBtn)
        contentView.addSubview(deleteBtn)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        linkTitleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(44)
        }
        linkTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(linkTitleLabel.snp.bottom)
            make.height.equalTo(linkTitleLabel)
        }
        textLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(linkTextField.snp.bottom)
            make.height.equalTo(linkTitleLabel)
        }
        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(textLabel.snp.bottom)
            make.height.equalTo(linkTitleLabel)
        }
        attachmentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(textField.snp.bottom)
            make.height.equalTo(linkTitleLabel)
        }
        attachmentBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(attachmentLabel.snp.bottom)
            make.height.equalTo(60)
            make.width.equalTo(60)
            make.bottom.equalToSuperview()
        }
        deleteBtn.snp.makeConstraints { make in
            make.centerX.equalTo(attachmentBtn.snp.right)
            make.centerY.equalTo(attachmentBtn.snp.top)
            make.size.equalTo(30)
        }
       
        linkTitleLabel.text = "链接:"
        linkTextField.placeholder = "请输入链接"
        linkTextField.keyboardType = .URL
        
        textLabel.text = "文本:"
        textField.placeholder = "请输入文本"
        attachmentLabel.text = "添加附件:"
        attachmentBtn.addTarget(self, action: #selector(addAttachment), for: .touchUpInside)
        
        deleteBtn.setImage(options.icon_delete, for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteAttachment), for: .touchUpInside)
        
        [linkTitleLabel, textLabel, attachmentLabel].forEach { label in
            label.font = .systemFont(ofSize: 15)
            label.textColor = UIColor.init(white: 0, alpha: 0.5)
        }
        
        [linkTextField, textField].forEach { tf in
            tf.font = .systemFont(ofSize: 15)
            let line = self.creatLine()
            tf.addSubview(line)
            line.snp.makeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAciton))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
        attachmentBtn.setImage(options.icon_attachment, for: .normal)
        deleteBtn.isHidden = true
    }
    @objc open func tapAciton() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    open func creatLine() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.06)
        return view
    }
    @objc open func addAttachment() {
        self.options.openPhotoLibrary?({[weak self] (image, asset) in
            self?.image = image
            self?.asset = asset
        })
    }
    @objc open func deleteAttachment() {
        self.image = nil
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func linkString() -> String? {
        return linkTextField.text
    }
    open func textString() -> String? {
        return textField.text
    }
    open func attachmentImage() -> UIImage? {
        return self.image
    }
    open func attachmentAsset() -> PHAsset? {
        return self.asset
    }
}
