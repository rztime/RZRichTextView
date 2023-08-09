//
//  RZLinkInputViewController.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/24.
//

import UIKit
import QuicklySwift
/// 输入链接的弹窗视图
open class RZLinkInputViewController: UIAlertController {
    private var text: String?
    private var link: String?
    private var finish: ((_ text: String?, _ link: String?) -> Void)?
    private var confirm: UIAlertAction?
    private var linkTF: UITextField?
    private var titleTF: UITextField?
    
    public func configure() {
        let aciton1 = UIAlertAction.init(title: "确认", style: .default) { [weak self] _ in
            let link = self?.textFields?.first?.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let text = self?.textFields?.last?.text ?? ""
            self?.finish?(text.isEmpty ? nil : text, link.isEmpty ? nil : link)
        }
        confirm = aciton1
        self.addTextField { tf in
            tf.clearButtonMode = .always
            tf.placeholder = "超链接地址"
        }
        self.addTextField { tf in
            tf.clearButtonMode = .always
            tf.placeholder = "超链接标题"
        }
        linkTF = self.textFields?.first
        linkTF?.text = link?.removingPercentEncoding
        linkTF?.addTarget(self, action: #selector(textFieldDidChanged(_ :)), for: .editingChanged)
        
        titleTF = self.textFields?.last
        titleTF?.text = text
        titleTF?.addTarget(self, action: #selector(textFieldDidChanged(_ :)), for: .editingChanged)
        
        let action0 = UIAlertAction.init(title: "放弃操作", style: .cancel) { _ in
            
        }
        let action2 = UIAlertAction.init(title: "取消超链接", style: .default) { [weak self]  _ in
            let link: String? = nil
            let text = self?.textFields?.last?.text ?? ""
            self?.finish?(text.isEmpty ? nil : text, link)
        }
        if !(text?.isEmpty ?? true) {
            self.addAction(action2)
        }
        self.addAction(aciton1)
        self.addAction(action0)
        confirm?.isEnabled = false
    }
    
    public class func show(text: String?, link: String?, finish:((_ text: String?, _ link: String?) -> Void)?) {
        let t = (text?.isEmpty ?? true) ? "插入超链接" : "编辑超链接"
        let vc = RZLinkInputViewController.init(title: t, message: nil, preferredStyle: .alert)
        vc.text = text
        vc.link = link
        vc.finish = finish
        vc.configure()
        qAppFrame.present(vc, animated: true, completion: nil)
    }
    @objc public func textFieldDidChanged(_ textField: UITextField) {
        if (self.linkTF?.text?.isEmpty ?? true) || (self.titleTF?.text?.isEmpty ?? true) {
            self.confirm?.isEnabled = false
        } else {
            self.confirm?.isEnabled = true
        }
    }
}
