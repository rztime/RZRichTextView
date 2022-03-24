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
        if let string = NSAttributedString.rt.htmlString("<ul><li></li></ul>") {
            if let para = string.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                p.setParagraphStyle(para)
            }
        }
        return p
    }()
    // 单例，统一一个有序列表的配置，这样相关联的列，才能合并到一个ol中
    static let olParagraphStyle : NSMutableParagraphStyle = {
        let p = NSMutableParagraphStyle.init()
        if let string = NSAttributedString.rt.htmlString("<ol><li></li></ol>") {
            if let para = string.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                p.setParagraphStyle(para)
            }
        }
        return p
    }()
    private static var quoteKey = "rz_blockquoteKey"
    
    var hadquote: Bool {
        return self.headIndent == 10 && self.firstLineHeadIndent == 10
    }
}
 
public extension RZRichTextBase where T : NSParagraphStyle {
    // 获取段落里的列表信息
    func tabStyle() -> RZTextTabStyle {
        let descP = "\(self)"
        let tab : RZTextTabStyle = descP.contains(RZTextTabStyleFormat.ul) ? .ul : (descP.contains(RZTextTabStyleFormat.ol) ? .ol : .none)
        return tab
    }
    // 将段落转换到有序、无序列表，或者清除列表
    func transParagraphTo(_ style: RZTextTabStyle) -> NSParagraphStyle {
        let p = NSMutableParagraphStyle.init()
        let origin = self.rt
        p.firstLineHeadIndent               = origin.firstLineHeadIndent
        p.headIndent                        = origin.headIndent
        switch style {
        case .none:
            break
        case .ul:
            p.setParagraphStyle(NSParagraphStyle.ulParagraphStyle) // 设置为无序列表
            if origin.hadquote {
                p.firstLineHeadIndent = 0
                p.headIndent = 0
            }
        case .ol:
            p.setParagraphStyle(NSParagraphStyle.olParagraphStyle) // 设置为有序列表
            if origin.hadquote {
                p.firstLineHeadIndent = 0
                p.headIndent = 0
            }
        }

        p.lineSpacing                       = origin.lineSpacing
        p.paragraphSpacing                  = origin.paragraphSpacing
        p.alignment                         = origin.alignment
        p.tailIndent                        = origin.tailIndent
        p.lineBreakMode                     = origin.lineBreakMode
        p.minimumLineHeight                 = origin.minimumLineHeight
        p.maximumLineHeight                 = origin.maximumLineHeight
        p.baseWritingDirection              = origin.baseWritingDirection
        p.lineHeightMultiple                = origin.lineHeightMultiple
        p.paragraphSpacingBefore            = origin.paragraphSpacingBefore
        p.hyphenationFactor                 = origin.hyphenationFactor
        if #available(iOS 15.0, *) {
            p.usesDefaultHyphenation        = origin.usesDefaultHyphenation
        }
        p.tabStops                          = NSParagraphStyle.init().tabStops // 置为默认的
        p.defaultTabInterval                = origin.defaultTabInterval
        p.allowsDefaultTighteningForTruncation = origin.allowsDefaultTighteningForTruncation
        if #available(iOS 9.0, *) {
            p.lineBreakStrategy             = origin.lineBreakStrategy
        }
        return p
    }
}

