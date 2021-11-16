//
//  DictionaryRZRichText.swift
//  RZRichTextView
//
//  Created by rztime on 2021/11/10.
//

import UIKit

public extension RZRichTextBase where T == Dictionary<NSAttributedString.Key, Any> {
    func tabStyle() -> RZTextTabStyle {
        if let p = self.rt[.paragraphStyle] as? NSParagraphStyle {
            return p.rt.tabStyle()
        }
        return .none
    }
    
    func transParagraphTo(_ tab: RZTextTabStyle) -> [NSAttributedString.Key: Any] {
        var attr = self.rt
        if let p = attr[.paragraphStyle] as? NSParagraphStyle {
            let newp = p.rt.transParagraphTo(tab)
            attr[.paragraphStyle] = newp
            return attr
        }
        return attr
    }
}
