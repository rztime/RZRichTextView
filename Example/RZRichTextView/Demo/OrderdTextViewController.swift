//
//  OrderdTextViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2021/11/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RZRichTextView
import RZColorfulSwift

class OrderdTextViewController: UIViewController {

    let textView = RZRichTextView.init(frame: .zero, options: .shared)
//    let textView = UITextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let btn = UIButton.init(type: .custom)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        btn.addTarget(self, action: #selector(closeAciton), for: .touchUpInside)
        self.view.addSubview(textView)
        self.navigationItem.rightBarButtonItem = .init(title: "转换", style: .plain, target: self, action: #selector(transformTohtml))
        
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(100)
            make.height.equalTo(300)
        }
        textView.font = .systemFont(ofSize: 17)
        //\t•\t
        let text1 = "<ol><li>456</li></ol>"
        let text2 = "<ul><li>456</li><li>012</li><li>678</li></ul>"
        let ori = NSAttributedString.rz.colorfulConfer { confer in
            confer.htmlString(text1)?.font(.systemFont(ofSize: 17)).textColor(.black)
            confer.htmlString(text2)?.font(.systemFont(ofSize: 17)).textColor(.black)
            confer.text("\n\n")?.font(.systemFont(ofSize: 17)).textColor(.black)
            confer.text("哈哈哈")?.font(.systemFont(ofSize: 17)).textColor(.black).paragraphStyle?.addTab(.ol)
        } ?? .init()
        // 如果通过addTab的方式加了列表序号， 需要resetTabOrderNumber 才会排序
        textView.attributedText = ori.rt.resetTabOrderNumber()
    }
    @objc func transformTohtml() {
        let html = self.textView.attributedText.rz.codingToHtmlWithImagesURLSIfHad(urls: ["http://www.baidu.com"]) ?? ""
        print("\(html)")
        if let attr = self.textView.attributedText {
            let newattr = NSMutableAttributedString.init(attributedString: attr)
            newattr.removeAttribute(.rt.originfontName, range: .init(location: 0, length: newattr.length))
            self.textView.attributedText = newattr
        }
    }
    @objc func closeAciton() {
        self.textView.endEditing(true)
    }
}
 
extension ParagraphStyleRZ {
    @discardableResult
    public func addTab(_ tab: RZTextTabStyle) -> Self {
        let p = paragraph.rt.transParagraphTo(tab)
        paragraph.setParagraphStyle(p)
        return self
    }
}
