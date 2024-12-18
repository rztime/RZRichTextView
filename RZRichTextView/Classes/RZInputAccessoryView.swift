//
//  RZInputAccessoryView.swift
//  FBSnapshotTestCase
//
//  Created by rztime on 2023/7/20.
//

import UIKit
import QuicklySwift
/// 工具栏视图
open class RZInputAccessoryView: UIView {
    open var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
        .qbackgroundColor(.clear)
    open var stackView = QStackView.qbody(.horizontal, 0, .fill, .equalSpacing, nil)
        .qshowType(.horizontal, type: .height)
        .qbackgroundColor(.white)
        .qshadow(.qhex(0x000000, a: 0.3), .init(width: 0, height: 3), radius: 6)
    
    open var viewModel: RZRichTextViewModel
    /// 点击了某个项
    open var clicked:((_ item: RZInputAccessoryItem?) -> Void)?
    
    public init(frame: CGRect, viewModel: RZRichTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.backgroundColor = .white
        
        self.viewModel.reloadDataWithAccessoryView = { [weak self] in
            self?.reloadData()
        }
        
        self.qbody([
            collectionView.qmakeConstraints({ make in
                make.left.top.bottom.equalToSuperview()
                make.right.equalTo(self.stackView.snp.left).offset(-3)
            }),
            stackView.qmakeConstraints({ make in
                make.top.right.bottom.equalToSuperview()
                make.width.equalTo(0)
            }),
            UIView().qmakeConstraints({ make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }).qbackgroundColor(.qhex(0x000000, a: 0.3))
        ])
        let layout = UICollectionViewFlowLayout.init()
                .qitemSize(.init(width: 44, height: 44))
                .qminimumLineSpacing(3)
                .qminimumInteritemSpacing(3)
                .qscrollDirection(.horizontal)
                .qsectionInset(.init(top: 0, left: 10, bottom: 0, right: 5))
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        collectionView
            .qregistercell(RZInputAccessoryItemView.self, "cell")
            .qnumberofRows { [weak self] section in
                let items = self?.viewModel.inputItems.filter({$0.enable})
                return items?.count ?? 0
            }
            .qcell { [weak self] collectionView, indexPath in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? RZInputAccessoryItemView
                cell?.item =  self?.viewModel.inputItems[qsafe: indexPath.row]
                return cell ?? .init()
            }
            .qdidSelectItem { [weak self] collectionView, indexPath in
                collectionView.deselectItem(at: indexPath, animated: false)
                let items:[RZInputAccessoryItem]? = self?.viewModel.inputItems.filter({$0.enable})
                self?.clicked?(items?[qsafe: indexPath.row])
            }
        self.reloadData()
    }
    
    open func reloadData() {
        self.collectionView.reloadData()
        let lockitems: [RZInputAccessoryItem] = self.viewModel.lockInputItems.filter({$0.enable})
        if lockitems.count > self.stackView.arrangedSubviews.count {
            let need = lockitems.count - self.stackView.arrangedSubviews.count
            for _ in 0..<need {
                let imageView = RZInputAccessoryItemLockView().qcontentMode(.center)
                self.stackView.qbody([
                    imageView.qmakeConstraints({ make in
                        make.size.equalTo(44)
                    })
                    .qtap({ [weak self] view in
                        self?.clicked?(view.item)
                    })
                ])
            }
        }
        self.stackView.arrangedSubviews.enumerated().forEach { (idx, view) in
            if let view = view as? RZInputAccessoryItemLockView, let item = lockitems[qsafe: idx] {
                view.item = item
                view.isHidden = false
                view.isUserInteractionEnabled = item.selected
            } else {
                view.isHidden = true
            }
        }
        self.stackView.snp.updateConstraints { make in
            make.width.equalTo(lockitems.count * 44)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class RZInputAccessoryItemView: UICollectionViewCell {
    open var imageView: UIImageView = .init()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.qbody([
            imageView.qmakeConstraints({ make in
                make.center.equalToSuperview()
            })
        ])
    }
    
    open var item: RZInputAccessoryItem? {
        didSet {
            self.imageView.image = item?.displayImage
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
open class RZInputAccessoryItemLockView: UIImageView {
    open var item: RZInputAccessoryItem? {
        didSet {
            self.image = item?.displayImage
            self.alpha = (item?.selected ?? false) ? 1 : 0.3
        }
    }
}
