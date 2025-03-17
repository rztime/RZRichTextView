//
//  MarkDownViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2025/3/7.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import QuicklySwift
import WebKit
import RZColorfulSwift
class MarkDownViewController: UIViewController {
    let textView = UITextView().qbackgroundColor(.qhex(0xf5f5f5)).qplaceholder("请输入md格式的内容")
    let webview = WKWebView.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.qbody([
            textView.qmakeConstraints({ make in
                make.left.right.equalToSuperview().inset(10)
                make.top.equalToSuperview().inset(qnavigationbarHeight + 20)
                make.height.equalTo(400)
            }),
            webview.qmakeConstraints({ make in
                make.left.bottom.right.equalToSuperview().inset(10)
                make.top.equalTo(self.textView.snp.bottom).inset(20)
            })
        ])
        textView.qtextChanged { [weak self] textView in
            if !textView.qisZhInput(), let md = textView.text {
                let html = MarkDownRZ.parse(md) ?? ""
                self?.webview.loadHTMLString(html.mdcss, baseURL: nil)
            }
        }
    }
}

extension String {
    /// 需自行完成css样式的内容，这里只是简单写了几个
    var mdcss: String {
        return """
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta http-equiv="Content-Style-Type" content="text/css">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-size: 16px; /* 16号字体 */
            }
            table {
                border-collapse: collapse; /* 合并边框 */
                border: 1px solid #dddddd; /* 表格边框颜色和宽度 */
            }
    /* 为单元格设置边框颜色 */
            th, td {
                border: 1px solid #dddddd; /* 单元格边框颜色和宽度 */
                padding: 8px; /* 单元格内边距 */
                text-align: left; /* 文本居中 */
            }
            /* 块级代码样式 */
            pre {
                background-color: #f8f8f8; /* 浅灰色背景 */
                padding: 10px; /* 内边距 */
                border-radius: 5px; /* 圆角边框 */
                border: 1px solid #ddd; /* 浅灰色边框 */
                overflow-x: auto; /* 水平滚动条 */
                white-space: pre-wrap; /* 自动换行 */
            }
        </style>
    </head>
    <body>
        \(self)
    </body>
</html>
"""
    }
}
