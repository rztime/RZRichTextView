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

    lazy var textView = RZRichTextView.init(frame: .init(x: 16, y: 100, width: qscreenwidth - 32, height: 80), viewModel: .shared(edit: true))
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
                    make.top.equalToSuperview()
                    make.height.equalTo(300)
                    make.width.equalTo(qscreenwidth - 32)
                }),
            ]).qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
        textView.textContainerInset = .init(top: 8, left: 0, bottom: 20, right: 0)
//        NotificationCenter.qaddKeyboardObserver(target: self, object: nil) { [weak self] keyboardInfo in
//            let y = keyboardInfo.frameEnd.height
//            let ishidden = keyboardInfo.isHidden
//            self?.textView.snp.updateConstraints({ make in 
//                make.bottom.equalToSuperview().inset(ishidden ? qbottomSafeHeight : y)
//            })
//        }
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
                let h = self.textView.attributedText.rz.codingToCompleteHtml()!
                let html = self.textView.code2html()
                print("\(html)")
            }
        
        /// 上传完成时，可以点击
        textView.viewModel.uploadAttachmentsComplete.subscribe({ [weak btn] value in
            btn?.isEnabled = value
            btn?.alpha = value ? 1 : 0.3
        }, disposebag: btn)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
        
        var html = try? String.init(contentsOfFile: "/Users/rztime/Desktop/test.html")
        html = """
<p style=\"margin:0.0px 0.0px 0.0px 0.0px;font-size:16.0px;\"><span style=\"color:#191919;font-size:16.0px;\">I yu</span></p><br/><p style=\"margin:0.0px 0.0px 0.0px 0.0px;font-size:16.0px;\"><span style=\"color:#191919;font-size:16.0px;\"><a href=\"https\">百度一下</a></span><span style=\"color:#191919;font-size:16.0px;\"></span></p><p style=\"margin:0.0px 0.0px 0.0px 0.0px;font-size:16.0px;\"><span style=\"color:#191919;font-size:16.0px;\">生活的</span></p>
"""
        let t = "<body style=\"font-size:16px;color:#110000;\">\(html ?? "")</body>"
        textView.html2Attributedstring(html: t)

    }
}
