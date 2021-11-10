//
//  DictionaryRZRichText.swift
//  RZRichTextView
//
//  Created by rztime on 2021/11/10.
//

import UIKit

public extension Dictionary {
    func rztabStyle() -> RZTextTabStyle {
        if let attr = self as? [NSAttributedString.Key: Any], let p = attr[.paragraphStyle] as? NSParagraphStyle {
            return p.tabStyle()
        }
        return .none
    }
    
    func rzTransParagraphTo(_ tab: RZTextTabStyle) -> [NSAttributedString.Key: Any] {
        if var attr = self as? [NSAttributedString.Key: Any], let p = attr[.paragraphStyle] as? NSParagraphStyle {
            let newp = p.rz_transParagraphTo(tab)
            attr[.paragraphStyle] = newp
            return attr
        }
        return (self as? [NSAttributedString.Key : Any]) ?? [:]
    }
}
