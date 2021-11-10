//
//  RZRichTextSelectView.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/18.
//

import UIKit

@objcMembers
open class RZRichTextSelectView: UIView {
    open var titleLabel: UILabel = .init()
    open var pickerView: RZPickerView = .init(frame: .zero, components: 1, direction: .horizontal)
    open var rows: Int = 0
    open var currentValue: Int = 0
    open var sizeForItem: CGSize = .init(width: 44, height: 44)
    open var titleForRow: ((Int) -> NSAttributedString?)?
    open var itemForRow: [RZRichColor]?
    open var selectedIndex: ((Int) -> Void)?
    open var title: String = ""
    
    public init(frame: CGRect, rows:Int, currentIndex: Int, title: String, titleForRow:((Int) -> NSAttributedString?)? = nil, itemForRow:[RZRichColor]? = nil, size:CGSize = .init(width: 44, height: 44), selectedIndex:((Int) -> Void)?) {
        super.init(frame: frame)
        self.title = title
        self.rows = rows
        self.sizeForItem = size
        self.selectedIndex = selectedIndex
        self.titleForRow = titleForRow
        self.itemForRow = itemForRow
        
        self.addSubview(titleLabel)
        self.addSubview(self.pickerView)
        self.pickerView.backgroundColor = UIColor.init(white: 0, alpha: 0.03)
        self.pickerView.layer.cornerRadius = 5
        self.pickerView.layer.masksToBounds = true
        self.titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalTo(44)
        }
        self.pickerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.height.equalTo(44)
        }
        
        self.pickerView.numberOfRowsInComponent = { [weak self] _ in
            return self?.rows ?? 0
        }
        self.pickerView.sizeForItem = { [weak self] (_, _) in
            return self?.sizeForItem ?? .zero
        }
        if titleForRow != nil {
            self.pickerView.attributedTitleFor = { [weak self] (component, row) in
                return self?.titleForRow?(row) ?? nil
            }
        }
        if (itemForRow?.count ?? 0) > 0 {
            self.pickerView.itemFor = { [weak self] (_, row, cell) in
                if !cell.custom {
                    cell.textLabel.snp.makeConstraints { make in
                        make.size.equalTo(26)
                    }
                    cell.textLabel.textColor = .init(white: 0, alpha: 0.5)
                    cell.textLabel.layer.masksToBounds = true
                    cell.textLabel.layer.cornerRadius = 13
                    cell.textLabel.layer.borderWidth = 2
                    cell.textLabel.layer.borderColor = UIColor.init(white: 0, alpha: 0.03).cgColor
                    cell.custom = true
                }
                let color = self?.itemForRow?[row] ?? .init(0, 0, 0, 1)
                cell.textLabel.backgroundColor = color.color
                if color.r == 0, color.g == 0, color.b == 0, color.a == 0 {
                    cell.textLabel.text = "无"
                } else {
                    cell.textLabel.text = nil
                }
            }
        }
        self.pickerView.selected = { [weak self] (_, row) in
            self?.selectedIndex?(row)
            self?.updateTitle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.pickerView.selected(component: 0, row: currentIndex, animated: false)
            self?.updateTitle()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open func updateTitle() {
        let attr = NSMutableAttributedString.init(string: self.title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 0.5)])
        if let attr1 = self.pickerView.attributedTitleFor?(0, self.pickerView.selectedRowInComponent(0)) {
            attr.append(attr1)
        }
        self.titleLabel.attributedText = attr
    }
}
