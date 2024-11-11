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
        let temphtml = (try? String.init(contentsOfFile: "/Users/rztime/Desktop/test.html")) ?? ""
        let html1 = "<body style=\"font-size:16px;color:#110000;\">\(temphtml)</body>"
        let html2 = "<body style=\"font-size:16px;color:#110000;\">\(temphtml)</body>"
        var html = html1
        btn.qtitle("测试").qtitleColor(.red)
            .qtap { [weak self] view in
                if html == html1 {
                    html = html2
                } else{
                    html = html1
                }
                self?.tableView.reloadData()
            } 

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
                let t = "<body style=\"font-size:16px;\">\(html)</body>"
                cell?.html = t
                return cell!
            }
    }
}

class TestTextCell : UITableViewCell {
    var reload: ((_ indexPath: IndexPath?) -> Void)?
    var indexPath: IndexPath = .init(row: 0, section: 0)
    
    var lastHeight: CGFloat = -1
    
    var html: String = "" {
        didSet {
            textView.html2Attributedstring(html: html)
        }
    }
    let textView = RZRichTextView.init(frame: .init(x: 15, y: 15, width: 384, height: 44), viewModel: .shared(edit: false))
        .qisScrollEnabled(false)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        let h = max(textView.frame.size.height, 80) + 30
        self.lastHeight = h
        self.contentView.snp.makeConstraints { make in
            make.height.equalTo(h)
        }
        self.contentView.qbody([
            textView.qmakeConstraints({ make in
                make.left.top.equalToSuperview().inset(15)
                make.width.equalTo(qscreenwidth - 30)
                make.height.greaterThanOrEqualTo(80)
            })
        ])
        textView.qcontentSizeChanged { [weak self] scrollView in
            guard let self = self else { return }
            let height = scrollView.frame.size.height + 30
            if self.lastHeight == height {
                return
            }
            self.lastHeight = height
            self.contentView.snp.updateConstraints({ make in
                make.height.equalTo(height)
            })
            self.reload?(self.indexPath)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
