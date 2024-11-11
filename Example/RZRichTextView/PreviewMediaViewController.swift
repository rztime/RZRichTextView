//
//  PreviewMediaViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2024/11/8.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
// 预览
class PreviewMediaViewController: UIViewController {
    let webView = WKWebView.init(frame: .zero)
    var url : String?
    init(url: String?) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.qbody([
            webView.qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
        if let url = self.url?.qtoURL {
            webView.load(URLRequest(url: url))
        } 
    }
}
