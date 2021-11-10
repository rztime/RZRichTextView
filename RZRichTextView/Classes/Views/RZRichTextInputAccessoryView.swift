//
//  RZRichTextInputAccessoryView.swift
//  FBSnapshotTestCase
//
//  Created by rztime on 2021/10/15.
//

import UIKit

@objcMembers
open class RZRichTextInputAccessoryView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    open var cellForItemAt:((UICollectionView, RZToolBarItem, Int) -> UICollectionViewCell)?
    open var didSelected:((RZToolBarItem, Int) -> Void)?
    
    open var rightToolBar: UIStackView = .init()
    open var closeBtn = UIButton.init(type: .custom)
    open var leftBtn = UIButton.init(type: .custom)
    open var rightBtn = UIButton.init(type: .custom)
    
    open var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())

    open var options: RZRichTextViewOptions
    public init(frame: CGRect, options: RZRichTextViewOptions) {
        self.options = options
        super.init(frame: frame)
        self.addSubview(rightToolBar)
        self.addSubview(collectionView)
        
        self.closeBtn.setImage(options.icon_endEdit, for: .normal)
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = .init(width: 44, height: 44)
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 44)
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(RZRichTextAccessoryViewCell.self, forCellWithReuseIdentifier: "RZRichTextAccessoryViewCell")
        options.willRegisterAccessoryViewCell?(collectionView)
        rightToolBar.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(rightToolBar.snp.left)
        }
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        
        rightToolBar.addArrangedSubview(leftBtn)
        rightToolBar.addArrangedSubview(rightBtn)
        rightToolBar.addArrangedSubview(closeBtn)
        rightToolBar.axis = .horizontal
        rightToolBar.spacing = 1
        
        [leftBtn, rightBtn, closeBtn].forEach { btn in
            btn.snp.makeConstraints { make in
                make.width.equalTo(30)
                make.height.equalTo(44)
            }
        }
        
        leftBtn.setImage(self.options.icon_revoke, for: .normal)
        leftBtn.setImage(self.options.icon_revokeEnable, for: .selected)
        rightBtn.setImage(self.options.icon_restore, for: .normal)
        rightBtn.setImage(self.options.icon_restoreEnable, for: .selected)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        let size = UIScreen.main.bounds.size
        let offset: CGFloat
        if #available(iOS 11.0, *) {
            offset = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? 44 : 0
        } else {
            offset = 0
        }
        let normal = size.width < size.height
        rightToolBar.snp.updateConstraints { make in
            make.right.equalToSuperview().inset(normal ? 0 : offset)
        }
        collectionView.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(normal ? 0 : offset)
        }
        self.reloadData()
    }
    @objc open func closeBtnAction() {
        self.didSelected?(.init(type: RZTextViewToolbarItem.endEdit.rawValue), -1)
    }
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.options.toolbarItems.count
    }
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.options.toolbarItems[indexPath.row]
        if let cell = self.options.accessoryViewCellFor?(collectionView, item, indexPath) {
            return cell
        }
        guard let cell: RZRichTextAccessoryViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RZRichTextAccessoryViewCell", for: indexPath) as? RZRichTextAccessoryViewCell else { return .init(frame: .zero) }
        cell.imageView.image = item.displayImage()
        return cell
    }
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.options.toolbarItems[indexPath.row]
        self.didSelected?(item, indexPath.row)
    }
}

@objcMembers
open class RZRichTextAccessoryViewCell: UICollectionViewCell {
    open lazy var imageView: UIImageView = .init()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(22)
        }
        imageView.contentMode = .scaleAspectFill
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
