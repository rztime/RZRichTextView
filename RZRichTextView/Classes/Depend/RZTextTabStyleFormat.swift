//
//  RZTextTabStyleFormat.swift
//  RZRichTextView
//
//  Created by rztime on 2021/11/9.
//

import UIKit

// 列表
@objc public enum RZTextTabStyle: NSInteger {
    case none = 0  // 无列表
    case ul   = 1  // 无序列表  主要添加是\t•\t 占用3个长度
    case ol   = 2  // 有序列表  主要是\t数字.\t 占用长度需要另行计算
}

/// 有序列表，无序列表 在iOS上不支持，所以通过增加html的ul、ol，在NSParagraphStyle里设置好有序无序列表
@objcMembers
open class RZTextTabStyleFormat {
    /// 无序列表
    public static let ul : String = "format <{disc}>"
    /// 有序列表
    public static let ol : String = "format <{decimal}.>"
    ///  用于匹配找到列表头
    public static let tabPattern : String = "\\t[0-9]+\\.\\t|\\t•\\t"
    
    open var attributedString: NSAttributedString = .init()
    open var range: NSRange = .init(location: 0, length: 0)
    open var tab: RZTextTabStyle = .none
    
    public init(_ string: NSAttributedString? = nil, range: NSRange? = nil, tab: RZTextTabStyle = .none) {
        if let string = string {
            self.attributedString = string
        }
        if let range = range {
            self.range = range
        }
        self.tab = tab
    }
}
