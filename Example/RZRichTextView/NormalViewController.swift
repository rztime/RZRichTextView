//
//  NormalViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2023/7/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import QuicklySwift
import RZRichTextView

class NormalViewController: UIViewController {
    let textView = RZRichTextView.init(frame: .init(x: 15, y: 0, width: qscreenwidth - 30, height: 300), viewModel: .shared())
        .qbackgroundColor(.qhex(0xf5f5f5))
        .qplaceholder("请输入正文")
        .qisHidden(false)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.qbody([
            textView.qmakeConstraints({ make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalToSuperview().inset(100)
                make.bottom.equalToSuperview().inset(qbottomSafeHeight)
            }),
        ])
        NotificationCenter.default.qaddKeyboardObserver(target: self, object: nil) { [weak self] keyboardInfo in
            let y = keyboardInfo.frameEnd.height
            let ishidden = keyboardInfo.isHidden
            self?.textView.snp.updateConstraints({ make in
                make.bottom.equalToSuperview().inset(ishidden ? qbottomSafeHeight : y)
            })
        }
        let btn = UIButton.init(type: .custom)
            .qtitle("转html")
            .qtitleColor(.red)
            .qtap { [weak self] view in
                guard let self = self else { return }
            }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
    }
}
