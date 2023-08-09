//
//  CustomRichTextViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2023/8/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import QuicklySwift
import RZRichTextView

class CustomRichTextViewController: UIViewController {
    let viewModel = RZRichTextViewModel.shared()
    lazy var textView = RZRichTextView.init(frame: .init(x: 15, y: 0, width: qscreenwidth - 30, height: 300), viewModel: viewModel)
        .qbackgroundColor(.qhex(0xf5f5f5))
        .qplaceholder("请输入正文")
        .qisHidden(false)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        /// 添加一个自定义custom1功能，功能实现的话，请在RZCustomRichTextViewModel.RZRichViewModel()里的didClickedAccessoryItem里实现
        viewModel.inputItems.insert(.init(type: .custom1, image: UIColor.red.qtoImage(.init(width: 23, height: 23)), highlight:  UIColor.blue.qtoImage(.init(width: 23, height: 23))), at: 0)
        
        self.view.qbody([
            textView.qmakeConstraints({ make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalToSuperview().inset(100)
                make.height.equalTo(300)
            }),

        ])
        let btn = UIButton.init(type: .custom)
            .qtitle("转html")
            .qtitleColor(.red)
            .qtap { [weak self] view in
                guard let self = self else { return }
                let attachments = self.textView.attachments
                if let _ = attachments.firstIndex(where: { info in
                    if case .complete(let success, _) = info.uploadStatus.value {
                        return !success
                    }
                    return true
                }) {
                    // 有未完成上传的
                    print("有未完成上传的")
                    return
                }
                let html = self.textView.code2html()
                print("\(html)")
            }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
    }
}
