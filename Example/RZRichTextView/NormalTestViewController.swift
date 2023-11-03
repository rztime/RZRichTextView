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
    let textView = UITextView().qbackgroundColor(.lightGray)
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.view.qbody([
            textView.qmakeConstraints({ make in
                make.left.right.equalToSuperview().inset(10)
                make.top.equalToSuperview().inset(100)
                make.height.equalTo(400)
            })
        ])
        textView.rz.colorfulConfer { confer in
        }
        textView.layoutIfNeeded()
    }
    

}
