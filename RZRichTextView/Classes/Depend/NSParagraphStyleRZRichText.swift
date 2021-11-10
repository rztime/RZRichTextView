//
//  NSParagraphStyleRZRichText.swift
//  RZRichTextView
//
//  Created by rztime on 2021/11/9.
//

import UIKit

public extension NSParagraphStyle {
    // 单例，统一一个无序列表的配置，这样相关联的列，才能合并到一个ul中
    static let ulParagraphStyle : NSMutableParagraphStyle = {
        let p = NSMutableParagraphStyle.init()
        if let string = NSAttributedString.rzrh_htmlString("<ul><li></li></ul>") {
            if let para = string.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                p.setParagraphStyle(para)
            }
        }
        return p
    }()
    // 单例，统一一个有序列表的配置，这样相关联的列，才能合并到一个ol中
    static let olParagraphStyle : NSMutableParagraphStyle = {
        let p = NSMutableParagraphStyle.init()
        if let string = NSAttributedString.rzrh_htmlString("<ol><li></li></ol>") {
            if let para = string.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                p.setParagraphStyle(para)
            }
        }
        return p
    }()
    // 获取段落里的列表信息
    func tabStyle() -> RZTextTabStyle {
        let descP = "\(self)"
        let tab : RZTextTabStyle = descP.contains(RZTextTabStyleFormat.ul) ? .ul : (descP.contains(RZTextTabStyleFormat.ol) ? .ol : .none)
        return tab
    }
    // 将段落转换到有序、无序列表，或者清除列表
    func rz_transParagraphTo(_ style: RZTextTabStyle) -> NSParagraphStyle {
        let p = NSMutableParagraphStyle.init()
        switch style {
        case .none:
            break
        case .ul:
            p.setParagraphStyle(NSParagraphStyle.ulParagraphStyle) // 设置为无序列表
        case .ol:
            p.setParagraphStyle(NSParagraphStyle.olParagraphStyle) // 设置为有序列表
        }
        p.lineSpacing                       = self.lineSpacing
        p.paragraphSpacing                  = self.paragraphSpacing
        p.alignment                         = self.alignment
        p.firstLineHeadIndent               = self.firstLineHeadIndent
        p.headIndent                        = self.headIndent
        p.tailIndent                        = self.tailIndent
        p.lineBreakMode                     = self.lineBreakMode
        p.minimumLineHeight                 = self.minimumLineHeight
        p.maximumLineHeight                 = self.maximumLineHeight
        p.baseWritingDirection              = self.baseWritingDirection
        p.lineHeightMultiple                = self.lineHeightMultiple
        p.paragraphSpacingBefore            = self.paragraphSpacingBefore
        p.hyphenationFactor                 = self.hyphenationFactor
        if #available(iOS 15.0, *) {
            p.usesDefaultHyphenation        = self.usesDefaultHyphenation
        }
        p.tabStops                          = NSParagraphStyle.init().tabStops // 置为默认的
        p.defaultTabInterval                = self.defaultTabInterval
        p.allowsDefaultTighteningForTruncation = self.allowsDefaultTighteningForTruncation
        if #available(iOS 9.0, *) {
            p.lineBreakStrategy             = self.lineBreakStrategy
        }
        return p
    }
}

