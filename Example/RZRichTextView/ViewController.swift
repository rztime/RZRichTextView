//
//  ViewController.swift
//  RZRichTextView
//
//  Created by rztime on 07/20/2023.
//  Copyright (c) 2023 rztime. All rights reserved.
//

import UIKit
import RZRichTextView
import QuicklySwift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        QuicklyAuthorization.result(with: .photoLibrary) { result in
            if !result.granted {
                print("---- 请给相册权限")
            }
        }
        
        let items: [(UIViewController.Type, String)] = [
            (NormalViewController.self, "正常使用"),
            (HTML2AttrViewController.self, "html转富文本"),
            (CustomRichTextViewController.self, "自定义编辑器"),
            (LabelLoadHtmlViewController.self, "UILabel加载html"),
            (TestViewController.self, "测试")
        ]
        
        
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.qnumberofRows { section in
            return items.count
        }
        .qheightForRow { indexPath in
            return 60
        }
        .qcell { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
            let item = items[qsafe: indexPath.row]
            cell.textLabel?.text = item?.1
            cell.detailTextLabel?.text = "\(String(describing: item?.0 ?? UIViewController.self))"
            return cell
        }
        .qdidSelectRow { tableView, indexPath in
            tableView.deselectRow(at: indexPath, animated: false)
            if let item = items[qsafe: indexPath.row] {
                let vc = item.0.init()
                vc.title = item.1
                qAppFrame.pushViewController(vc)
            }
        }
        self.view.qbody([
            tableView.qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

