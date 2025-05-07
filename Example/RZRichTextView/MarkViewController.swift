//
//  MarkViewController.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2025/3/21.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import RZColorfulSwift
import QuicklySwift
import RZRichTextView
/// 需要标记某些文本(比如敏感词、错误文本等等)
class MarkViewController: UIViewController {
    let textView = RZRichTextView.init(frame: .init(x: 15, y: 100, width: qscreenwidth - 30, height: 300), viewModel: .shared())
        .qbackgroundColor(.qhex(0xf5f5f5))
        .qplaceholder("请输入正文")
        .qisHidden(false)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.qbody([textView])
        test1()
//        test2()
        let btn1 = UIButton(type: .custom).qtitle("测试1").qtitleColor(.blue)
            .qtap { [weak self] view in
                guard let attr = self?.textView.attributedText else { return }
                attr.enumerateAttribute(.init("fix"), in: .init(location: 0, length: attr.length)) { id, range, stop in
                    if let id = id as? String, id == "error1" {
                        self?.textView.selectedRange = range
                        stop.pointee = true
                    }
                }
            }
        let btn2 = UIButton(type: .custom).qtitle("测试2").qtitleColor(.blue)
            .qtap { [weak self] view in
                guard let attr = self?.textView.attributedText else { return }
                attr.enumerateAttribute(.init("fix"), in: .init(location: 0, length: attr.length)) { id, range, stop in
                    if let id = id as? String, id == "error2" {
                        self?.textView.selectedRange = range
                        stop.pointee = true
                    }
                }
            }
        self.view.qbody([
            [btn1, btn2].qjoined(aixs: .vertical, spacing: 20, align: .center, distribution: .equalSpacing)
                .qmakeConstraints({ make in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(self.textView.snp.bottom).offset(10)
                })
            
        ])
    }
    func test1() {
        // 原始内容
        let orginHtml = """
        <p><span style="text-size:18px;color: black;">你好，在做标记文本，用于带入属性，比如有👌别错字，或者它其，或者其他需要标记的东西</span></p>
        """
        /// 比如说知道“别错字”， “它其”分别的位置在哪里
        var marks: [(id: String, location: NSRange)] = [("error1", NSRange(location: 67, length: 3)),
                                                     ("error2", NSRange(location: 73, length: 2)),]
        /// 倒序排一下
        marks = marks.sorted(by: { v1, v2 in
            return v1.location.location > v2.location.location
        })
        var htmlString = orginHtml
        marks.forEach { id, location in
            /// 如果需要多重标记，即位置可能存在交叉，那么可以设置key = id，只要id唯一，富文本里一个位置可以加多个key
            let custom = String.rzcustomMark(key: "fix", id: id)
            let star = custom.start
            let end = custom.end
            /// 在需要标记的文本前后加上标记[#ios-mark-star-\(key)-\(id)#] [#ios-mark-end-\(key)-\(id)#]
            htmlString.insert(contentsOf: end, at: htmlString.index(htmlString.startIndex, offsetBy: location.upperBound))
            htmlString.insert(contentsOf: star, at: htmlString.index(htmlString.startIndex, offsetBy: location.lowerBound))
        }
        let result = htmlString
        textView.html2Attributedstring(html: result)
        let attr = textView.textStorage
        /// 遍历所有的自定义属性，可以做相应的操作，如标记颜色，或者添加备注等等
        attr.enumerateAttribute(.init(rawValue: "fix"), in: .init(location: 0, length: attr.length)) { [weak self] id, range, _ in
            if let id = id as? String {
                print("id:\(id) :\(range)")
                self?.textView.textStorage.addAttribute(.backgroundColor, value: UIColor.red, range: range)
            }
        }
    }
}
