//
//  TableViewViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2023/10/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import RZRichTextView
import QuicklySwift

class TableViewViewController: UIViewController {
    let tableView = UITableView.init(frame: .qfull, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.qbody([
            tableView.qmakeConstraints({ make in
                make.edges.equalToSuperview()
            }),
        ])
        
        let btn = UIButton.init(type: .custom)
        self.navigationItem.rightBarButtonItem = .init(customView: btn)
        btn.qtitle("测试").qtitleColor(.red)
            .qtap { [weak self] view in
                self?.tableView.reloadData()
            }
//        tableView.isScrollEnabled = false
        
        tableView
            .qnumberofRows { section in
                return 1
            }
            .qcell { [weak self] tableView, indexPath in
                var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TestTextCell
                if cell == nil {
                    cell = TestTextCell.init(style: .default, reuseIdentifier: "cell")
                    cell?.reload = { [weak self] _ in
                        self?.tableView.reloadData()
                    }
                }
                var html = try? String.init(contentsOfFile: "/Users/rztime/Desktop/test.html")
                cell?.textView.html2Attributedstring(html: html)
                return cell!
            }
    }
}

class TestTextCell : UITableViewCell {
    let textView = RZRichTextView.init(frame: .init(x: 10, y: 10, width: qscreenwidth - 20, height: 300), viewModel: .shared(edit: false))
    var reload: ((_ indexPath: IndexPath?) -> Void)?
    var indexPath: IndexPath = .init(row: 0, section: 0)
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(textView)
        self.contentView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
        var first = true
        textView.qcontentSizeChanged { [weak self] scrollView in
            if first {
                first = false
                return
            }
            let x: CGFloat = 10
            let height = scrollView.contentTextHeight
            scrollView.frame = .init(x: x, y: x, width: qscreenwidth - 2 * x, height: height)

            let h = Int(height + 2 * x)
            if h != Int(self?.frame.size.height ?? 0) {
                self?.contentView.snp.updateConstraints({ make in
                    make.height.equalTo(h)
                }) 
                DispatchQueue.main.async {
                    self?.reload?(self?.indexPath)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
