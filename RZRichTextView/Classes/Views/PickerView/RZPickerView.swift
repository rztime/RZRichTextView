//
//  RZPickerView.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/15.
//

import UIKit
import SnapKit
import AudioToolbox

/// 滚动的选择控件
@objcMembers
open class RZPickerView: UIView {
    /// 总共多少列
    open var components: Int = 1
    /// 每一列多少个item
    open var numberOfRowsInComponent: ((_ component: Int) -> Int)?
    /// 每一列的item的size
    open var sizeForItem: ((_ component: Int, _ row: Int) -> CGSize)?
    /// 滚动时当前选中的item实时回调
    open var selected: ((_ component: Int, _ row: Int) -> Void)?
    /// 遮罩view的设置，可以修改颜色等等
    open var sizeForShadeView: ((_ shadeView: UIView, _ component: Int, _ row: Int) -> CGSize)?
    ///  item的标题
    open var attributedTitleFor: ((_ component: Int, _ row: Int) -> NSAttributedString?)?
    // 配置item 直接对cell里的东西进行配置
    open var itemFor: ((_ component: Int, _ row: Int, _ cell: RZPickerCollectionViewCell) -> Void)?
 
    /// 列之间的间隔
    open var componentsSpace: CGFloat = 0 {
        didSet {
            self.stackView.spacing = componentsSpace
        }
    }
    /// 显示标记item上的标记“-  - ”，默认true
    open var showGraduation: Bool = true {
        didSet {
            views.forEach { v in
                v.showGraduation = showGraduation
            }
        }
    }
    private let stackView = UIStackView()
    private var views: [RZPickerCollectionView] = []
    public init(frame: CGRect, components: Int = 1, direction: UICollectionView.ScrollDirection = .vertical) {
        self.components = components
        super.init(frame: frame)
        self.addSubview(stackView)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        self.stackView.axis = direction == .horizontal ? .vertical : .horizontal
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        for i in 0 ..< components {
            let view = RZPickerCollectionView.init(frame: .zero, direction: direction)
            view.tag = i
            view.numberOfRows = { [weak self] v in
                return self?.numberOfRowsInComponent?(v.tag) ?? 0
            }
            view.sizeForItem = { [weak self] (view, row) in
                return self?.sizeForItem?(view.tag, row) ?? .zero
            }
            view.attributedTitleForItem = { [weak self] (view, row) in
                return self?.attributedTitleFor?(view.tag, row) ?? nil
            }
            view.itemForRow = { [weak self] (view, cell, row) in
                self?.itemFor?(view.tag, row, cell)
            }
            view.selectedItem = { [weak self] (view, row) in
                self?.selected?(view.tag, row)
            }
            view.shadeView.tag = i
            view.sizeForShadeView = { [weak self] (view, row) in
                return self?.sizeForShadeView?(view, view.tag, row) ?? .init(width: 44, height: 44)
            }
            stackView.addArrangedSubview(view)
            views.append(view)
        }
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.reloadData()
    }
    
    open func reloadData() {
        views.forEach { v in
            v.reloadData()
        }
    }
    open func selected(component: Int, row: Int, animated: Bool = true) {
        views[component].selecteRow(row, animated: animated)
    }
    open func selectedRowInComponent(_ component: Int) -> Int {
        return self.views[component].selectedRow
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
@objcMembers
open class RZPickerCollectionView: UIView {
    private var direction: UICollectionView.ScrollDirection = .vertical
    private var collectionView: UICollectionView?
    
    open var numberOfRows: ((RZPickerCollectionView) -> Int)?
    open var sizeForItem: ((RZPickerCollectionView, _ row: Int) -> CGSize)?
    open var attributedTitleForItem: ((RZPickerCollectionView, _ row: Int) -> NSAttributedString?)?
    open var itemForRow: ((RZPickerCollectionView, _ cell: RZPickerCollectionViewCell, _ row: Int) -> Void)?
    open var selectedItem: ((RZPickerCollectionView, _ row: Int) -> Void)?
    open var sizeForShadeView: ((UIView, _ row: Int) -> CGSize)?
    open var shadeView = UIView()
    open var selectedRow: Int = -1
    open var showGraduation: Bool = true {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    private var canSelect: Bool = false
    public init(frame: CGRect, direction: UICollectionView.ScrollDirection = .vertical) {
        super.init(frame: frame)
        self.direction = direction
        self.addSubview(shadeView)
        shadeView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }
        shadeView.backgroundColor = .init(white: 0, alpha: 0.1)
        shadeView.isUserInteractionEnabled = false
        let layout = RZPickerCollectionFlowLayout.init()
        layout.itemSize = .init(width: 44, height: 44)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = direction
        
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(RZPickerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.collectionView = collectionView
    }
    
    open func selecteRow(_ row: Int, animated: Bool) {
        self.selectedRow = row
        let indexPath = IndexPath.init(row: row, section: 0)
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self = self, let collectionView = self.collectionView, let attr = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else { return }
        
            switch self.direction {
            case .horizontal:
                let x = attr.frame.origin.x - (collectionView.frame.size.width / 2.0 - attr.frame.size.width / 2.0)
                collectionView.setContentOffset(.init(x: x, y: 0), animated: animated)
            case .vertical:
                let y = attr.frame.origin.y - (collectionView.frame.size.height / 2.0 - attr.frame.size.height / 2.0)
                collectionView.setContentOffset(.init(x: 0, y: y), animated: animated)
            @unknown default:
                break
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        canSelect = false
        super.layoutSubviews()
        self.collectionView?.reloadData()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(animatedFinish), object: nil)
        self.perform(#selector(animatedFinish), with: nil, afterDelay: 0.3)
    }
    @objc open func animatedFinish() {
        self.canSelect = true
        self.selecteRow(self.selectedRow, animated: false)
    }
    open func reloadData() {
        self.collectionView?.reloadData()
    }
}

extension RZPickerCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let number = self.numberOfRows {
            return number(self)
        }
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = self.sizeForItem {
            return size(self, indexPath.row)
        }
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            switch layout.scrollDirection {
            case .horizontal:
                return .init(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
            case .vertical:
                return .init(width: collectionView.frame.size.width, height: collectionView.frame.size.width)
            @unknown default:
                break
            }
        }
        return .zero
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? RZPickerCollectionViewCell else { return .init() }
        cell.showGraduation = self.showGraduation
        cell.direction = self.direction
        cell.textLabel.attributedText = nil
        if let attr = self.attributedTitleForItem {
            cell.textLabel.attributedText = attr(self, indexPath.row)
        }
        if let item = self.itemForRow {
            item(self, cell, indexPath.row)
        }
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        self.selecteRow(indexPath.row, animated: true)
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = self.collectionView, self.canSelect else { return }
        var idp: IndexPath?
        switch self.direction {
        case .horizontal:
            idp = collectionView.indexPathForItem(at: .init(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2.0, y: collectionView.frame.size.height / 2.0))
        case .vertical:
            idp = collectionView.indexPathForItem(at: .init(x: collectionView.frame.size.width / 2.0, y: collectionView.contentOffset.y + collectionView.frame.size.height / 2.0))
        @unknown default:
            break
        }
        guard let idp = idp, idp.row != self.selectedRow else {
            return
        }
        self.selectedRow = idp.row
        AudioServicesPlaySystemSound(1519)
        if let sizeForShade = self.sizeForShadeView {
            let temp = sizeForShade(self.shadeView, idp.row)
            if !self.shadeView.frame.size.equalTo(temp) {
                self.shadeView.snp.updateConstraints { make in
                    make.width.equalTo(temp.width)
                    make.height.equalTo(temp.height)
                }
            }
        }
        if let selected = self.selectedItem {
            selected(self, idp.row)
        }
    }
}
@objcMembers
open class RZPickerCollectionViewCell: UICollectionViewCell {
    open var textLabel: UILabel = .init()
    open var showGraduation: Bool = true {
        willSet {
            if newValue != showGraduation {
                updateLines(direction: direction, show: newValue)
            }
        }
    }
    open var direction: UICollectionView.ScrollDirection = .horizontal {
        willSet {
            if newValue != direction {
                updateLines(direction: newValue, show: showGraduation)
            }
        }
    }
    open var custom: Bool = false
    
    private let top = UIView()
    private let left = UIView()
    private let bottom = UIView()
    private let right = UIView()
    
    private var lrLines:[UIView] = []
    private var tbLines:[UIView] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.textAlignment = .center
        textLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        setupLines()
        lrLines = [left, right]
        tbLines = [top, bottom]
        updateLines(direction: self.direction, show: showGraduation)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLines() {
        [top, left, bottom, right].forEach { v in
            v.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
            self.contentView.addSubview(v)
        }
        let w = 1
        let h = 10
        top.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.textLabel.snp.top).offset(-5)
            make.width.equalTo(w)
            make.height.equalTo(h)
        }
        left.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.textLabel.snp.left).offset(-5)
            make.width.equalTo(h)
            make.height.equalTo(w)
        }
        bottom.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.textLabel.snp.bottom).offset(5)
            make.width.equalTo(w)
            make.height.equalTo(h)
        }
        right.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.textLabel.snp.right).offset(5)
            make.width.equalTo(h)
            make.height.equalTo(w)
        }
    }
    
    private func updateLines(direction: UICollectionView.ScrollDirection, show: Bool) {
        self.lrLines.forEach { v in
            v.isHidden = self.direction == .horizontal || !showGraduation
        }
        self.tbLines.forEach { v in
            v.isHidden = self.direction == .vertical || !showGraduation
        }
    }
}
@objcMembers
open class RZPickerCollectionFlowLayout: UICollectionViewFlowLayout {
    open override func prepare() {
        super.prepare()
        switch self.scrollDirection {
        case .horizontal:
            let margin = (self.collectionView?.frame.size.width ?? 0) / 2.0
            self.collectionView?.contentInset = .init(top: 0, left: margin, bottom: 0, right: margin)
        case .vertical:
            let margin = (self.collectionView?.frame.size.height ?? 0) / 2.0
            self.collectionView?.contentInset = .init(top: margin, left: 0, bottom: margin, right: 0)
        @unknown default:
            break
        }
    }
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var tempRect = rect
        let arr = super .layoutAttributesForElements(in: tempRect)
        let screenSize = UIScreen.main.bounds.size
        let collectionViewSize = self.collectionView?.frame.size ?? .zero
        let contentOffset = self.collectionView?.contentOffset ?? .zero
        switch self.scrollDirection {
        case .horizontal:
            tempRect.size.width = tempRect.size.width + screenSize.width
            tempRect.origin.x = tempRect.origin.x - screenSize.width / 2.0
            let centerX = contentOffset.x + collectionViewSize.width / 2.0
            arr?.forEach({ attributes in
                let delta = abs(attributes.center.x - centerX)
                let scale = max(1 - delta / collectionViewSize.width, 0.1)
                attributes.transform = attributes.transform.scaledBy(x: scale, y: scale)
            })
        case .vertical:
            tempRect.size.height = tempRect.size.height + screenSize.height;
            tempRect.origin.y = tempRect.origin.y - screenSize.height / 2.0;
            let centerY = contentOffset.y + collectionViewSize.height / 2.0;
            arr?.forEach({ attributes in
                let delta = abs(attributes.center.y - centerY)
                let scale = max(1 - delta / collectionViewSize.height, 0.1)
                attributes.transform = attributes.transform.scaledBy(x: scale, y: scale)
            })
        @unknown default:
            break
        }
        return arr
    }
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let collectionViewSize = self.collectionView?.frame.size ?? .zero
        var ppp = proposedContentOffset
        switch self.scrollDirection {
        case .horizontal:
            let rect: CGRect = .init(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
            let arr = super .layoutAttributesForElements(in: rect)
            let centerX = proposedContentOffset.x + collectionViewSize.width / 2.0
            var minDelta: CGFloat = CGFloat(MAXFLOAT)
            arr?.forEach({ attrs in
                if abs(minDelta) >= abs(CGFloat(attrs.center.x - centerX)) {
                    minDelta = CGFloat(attrs.center.x - centerX)
                }
            })
            ppp.x = ppp.x + minDelta
        case .vertical:
            let rect: CGRect = .init(x: 0, y: proposedContentOffset.y, width: collectionViewSize.width, height: collectionViewSize.height)
            let arr = super .layoutAttributesForElements(in: rect)
            let centerY = proposedContentOffset.y + collectionViewSize.height / 2.0
            var minDelta: CGFloat = CGFloat(MAXFLOAT)
            arr?.forEach({ attrs in
                if abs(minDelta) >= abs(CGFloat(attrs.center.y - centerY)) {
                    minDelta = CGFloat(attrs.center.y - centerY)
                }
            })
            ppp.y = ppp.y + minDelta
        @unknown default:
            break
        }
        return ppp
    }
}
