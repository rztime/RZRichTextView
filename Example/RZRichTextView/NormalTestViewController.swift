//
//  NormalTestViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2023/10/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import QuicklySwift
import RZColorfulSwift

class NormalTestViewController: UIViewController {
    let textView = UITextView().qbackgroundColor(.qhex(0xf7f7f7))//.qisEditable(false).qisScrollEnabled(false)
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        let btn = UIButton.init(type: .custom).qtitle("设置").qtitleColor(.red)
        self.navigationItem.rightBarButtonItem = .init(customView: btn)
        self.view.qbody([
            UIScrollView()
                .qmakeConstraints({ make in
                    make.edges.equalToSuperview()
                })
                .qbody([
                    textView.qmakeConstraints({ make in
                        make.left.right.equalToSuperview().inset(10)
                        make.width.equalTo(qscreenwidth - 20)
                        make.top.equalToSuperview().inset(10)
                        make.bottom.equalToSuperview()
                        make.height.equalTo(500)
                    })
                ])
         
        ])
        let html = (try? String.init(contentsOfFile: "/Users/rztime/Desktop/test.html"))
        let t = "<body style=\"font-size:16px;color:#110000;\">\(html ?? "")</body>"
        textView.rz.colorfulConfer { confer in
            confer.htmlString(t)
        }
        btn.qtap { view in
            self.textView.isEditable = false
        }
    }
}
