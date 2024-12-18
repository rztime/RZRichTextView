//
//  HTML2AttrViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2023/7/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import QuicklySwift
import RZRichTextView

class HTML2AttrViewController: UIViewController {

    lazy var textView = RZRichTextView.init(frame: .init(x: 16, y: 100, width: qscreenwidth - 32, height: 180), viewModel: .shared(edit: true))
//        .qisScrollEnabled(false)
        .qbackgroundColor(.qhex(0xf5f5f5))
        .qplaceholder("请输入内容")
//        .qlinkTextAttributes([.foregroundColor: UIColor.red])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.qbody([
            UIScrollView.qbody([
                textView.qmakeConstraints({ make in
                    make.left.equalToSuperview().inset(16)
                    make.top.bottom.equalToSuperview()
                    make.height.equalTo(500)
                    make.width.equalTo(qscreenwidth - 32)
                }),
            ]).qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
        let btn = UIButton.init(type: .custom)
            .qtitle("转html")
            .qtitleColor(.red)
            .qtap { [weak self] view in
                guard let self = self else { return }            
                let html = self.textView.code2html()
                print("-----html:\n\(html)")
            }
        
        /// 上传完成时，可以点击
        textView.viewModel.uploadAttachmentsComplete.subscribe({ [weak btn] value in
            btn?.isEnabled = value
            btn?.alpha = value ? 1 : 0.3
        }, disposebag: btn)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
        let html = (try? String.init(contentsOfFile: "/Users/rztime/Desktop/test.html")) ?? ""
        let t = html.toHtml()
        textView.html2Attributedstring(html: t)
    }
}
