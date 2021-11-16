//
//  NSAttributedStringRZRichText.swift
//  RZRichTextView
//
//  Created by rztime on 2021/11/3.
//

import UIKit
import Photos

public extension RZRichTextBase where T == NSAttributedString.Key {
    // 添加一个列表的key
    static let tabStyle: NSAttributedString.Key = NSAttributedString.Key(rawValue: "tabStyle")
    static let originfontName : NSAttributedString.Key = NSAttributedString.Key(rawValue: "NSOriginalFont")
}

public extension RZRichTextBase where T == NSRange {
    func maxLength() -> NSInteger {
        let r = self.rt
        return r.location + r.length
    }
}

// MARK: 获取段落所在range相关
public extension RZRichTextBase where T : NSAttributedString {
    ///  range所选区域的所在段落
    func parapraghRange(for range: NSRange) -> NSRange {
        let string = NSString.init(string: self.rt.string)
        var star: Int = 0
        var end: Int = 0
        var ptr: Int = 0
        string.getParagraphStart(&star, end: &end, contentsEnd: &ptr, for: range)
        return .init(location: star, length: end - star)
    }
    //  range所在区域的所有段落ranges
    func paragraphRanges(for range: NSRange) -> [NSRange] {
        let all = self.allParapraghRange()
        let length = self.rt.length
        let res = all.filter({ tempRang in
            if range.rt.maxLength() < tempRang.location {
                return false
            }
            if tempRang.rt.maxLength() <= range.location, tempRang.rt.maxLength() != length {
                return false
            }
            return true
        })
        return res
    }
    /// 当前文本的所有段落
    func allParapraghRange() -> [NSRange] {
        var ranges: [NSRange] = []
        var range: NSRange = .init(location: 0, length: 0)
        while range.location < self.rt.length {
            let rg = self.parapraghRange(for: range)
            ranges.append(rg)
            range.location = rg.location + rg.length
        }
        return ranges
    }
    /// 获得range所在段落的富文本
    func paragraphAttributedSubString(form range: NSRange) -> NSAttributedString {
        let para = self.parapraghRange(for: range)
        return self.rt.attributedSubstring(from: para)
    }
}

// MARK: 列表类型符相关
public extension RZRichTextBase where T : NSAttributedString {
    /// 获取range所在位置的段落首位的制表符长度
    func tabStyleLengthFor(_ range: NSRange) -> NSInteger {
        let rg = self.parapraghRange(for: range)
        let p = self.rt.attributedSubstring(from: rg)
        let p1 = p.rt.removeHeadTabString()
        return p.length - p1.length
    }
    /// 获取range所在位置的列表符类型
    func tabStyleFor(_ range: NSRange) -> RZTextTabStyle {
        let location = range.location >= self.rt.length ? (range.location - 1) : range.location
        let t = max(location, 0)
        var enable = true
        if self.rt.length == 0 { // nsattributedString不存在，且没有段落属性时，就不执行，否则直接调用self.attribute(.paragraphStyle, at: t, effectiveRange: nil)会crash
            enable = false
            self.rt.enumerateAttribute(.paragraphStyle, in: .init(location: 0, length: 0), options: []) { p, _, _ in
                if let _ = p as? NSParagraphStyle {
                    enable = true
                }
            }
        }
        guard enable, let para = self.rt.attribute(.paragraphStyle, at: t, effectiveRange: nil) as? NSParagraphStyle else { return .none}
        return para.rt.tabStyle()
    }
    /// 文本开头是否是tab，是就返回range
    func headTabRange() -> NSRange? {
        let string = self.rt.string
        if let range = string.rt.rangesWith(pattern: RZTextTabStyleFormat.tabPattern)?.first, range.location == 0 {
            return range
        }
        return nil
    }
    /// 移除最开头的tab制表符
    func removeHeadTabString() -> NSAttributedString {
        let at = self.rt
        if let range = self.headTabRange() {
            return at.attributedSubstring(from: .init(location: range.rt.maxLength(), length: at.length - range.rt.maxLength()))
        }
        return at
    }
    /// 统一制表符 制表符属于私有属性，所以默认配置在iOS中有区别，将制表符所有的段落，转换到和iOS中的默认相同，这样在显示上才不会错位
    func unifyTabstyle() -> NSAttributedString {
        let tempAttr = NSMutableAttributedString.init(attributedString: self.rt)
        tempAttr.enumerateAttribute(.paragraphStyle, in: .init(location: 0, length: tempAttr.length), options: []) { p, range, _ in
            if let p = p as? NSParagraphStyle {
                let tab = p.rt.tabStyle()
                let temp = p.rt.transParagraphTo(tab)
                tempAttr.addAttribute(.paragraphStyle, value: temp, range: range)
            }
        }
        return tempAttr
    }
    /// 重排序
    func resetTabOrderNumber() -> NSAttributedString {
        // 先统一制表符
        let attributedText = self.unifyTabstyle()
        // 得到所有的段落
        let allParas = attributedText.rt.allParapraghRange()
        // 按连续相同的段落的列表类型，分组， （无列表， 无序列表，有序列表）
        var allList:[[RZTextTabStyleFormat]] = []
        // 用于记录连续相同类型的段落
        var sameList: [RZTextTabStyleFormat] = []
        var i = 0
        allParas.forEach { range in
            let p = attributedText.rt.tabStyleFor(range)
            let attr = attributedText.attributedSubstring(from: range)
            if p == sameList.last?.tab || sameList.count == 0 {
                sameList.append(.init(attr, range: range, tab: p))
            } else {
                allList.append(sameList)
                sameList = [.init(attr, range: range, tab: p)]
            }
            if i == allParas.count - 1 {
                allList.append(sameList)
            }
            i += 1
        }
        let attr = NSMutableAttributedString.init()
        allList.forEach { formatters in
            // 对相同类型的分组数据进行排序
            for (i, v) in formatters.enumerated() {
                let a: NSMutableAttributedString = .init()
                
                switch v.tab {
                case .none:
                    a.append(v.attributedString)
                case .ul, .ol:
                    a.append(v.attributedString.rt.removeHeadTabString())
                    let attr = v.attributedString.attributes(at: 0, effectiveRange: nil)
                    let t = v.tab == .ul ? "\t•\t" : "\t\(i+1).\t" // 有排序时，加点或者加123序列
                    let new = NSAttributedString.init(string: t, attributes: attr)
                    a.insert(new, at: 0)
                }
                attr.append(a)
            }
        }
        return attr
    }
}
public extension RZRichTextBase where T : NSAttributedString {
    /// RZRichtext使用，替换掉属性，部分属性如果不存在，则移除之前的
    func replaceAttributes(_ attributes: [NSAttributedString.Key: Any], range: NSRange) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString.init(attributedString: self.rt)
        attr.addAttributes(attributes, range: range)
        
        if !attributes.keys.contains(.backgroundColor) {
            attr.removeAttribute(.backgroundColor, range: range)
        }
        if !attributes.keys.contains(.baselineOffset) {
            attr.removeAttribute(.baselineOffset, range: range)
        }
        if let v = (attributes[.baselineOffset] as? Int), v == 0 {
            attr.removeAttribute(.baselineOffset, range: range)
        }
        if !attributes.keys.contains(.strokeWidth) {
            attr.removeAttribute(.strokeWidth, range: range)
            attr.removeAttribute(.strokeColor, range: range)
        }
        if let v = (attributes[.strokeWidth] as? Int), v == 0 {
            attr.removeAttribute(.strokeWidth, range: range)
            attr.removeAttribute(.strokeColor, range: range)
        }
        if !attributes.keys.contains(.shadow) {
            attr.removeAttribute(.shadow, range: range)
        }
        if !attributes.keys.contains(.expansion) {
            attr.removeAttribute(.expansion, range: range)
        }
        if !attributes.keys.contains(.underlineStyle) {
            attr.removeAttribute(.underlineStyle, range: range)
            attr.removeAttribute(.underlineColor, range: range)
        }
        if let v = (attributes[.underlineStyle] as? Int), v == 0 {
            attr.removeAttribute(.underlineStyle, range: range)
            attr.removeAttribute(.underlineColor, range: range)
        }
        if !attributes.keys.contains(.strikethroughStyle) {
            attr.removeAttribute(.strikethroughStyle, range: range)
            attr.removeAttribute(.strikethroughColor, range: range)
        }
        if let v = (attributes[.strikethroughStyle] as? Int), v == 0 {
            attr.removeAttribute(.strikethroughStyle, range: range)
            attr.removeAttribute(.strikethroughColor, range: range)
        }
        
        if !attributes.keys.contains(.kern) {
            attr.removeAttribute(.kern, range: range)
        }
        if let v = (attributes[.kern] as? Int), v == 0 {
            attr.removeAttribute(.kern, range: range)
        }
        return attr
    }

    /// 将html转换为富文本
    static func htmlString(_ html: String?) -> NSAttributedString? {
        guard let html = html, html.count > 0 else {return nil}
        if let data = html.data(using: String.Encoding.unicode) {
            if let attr = try? NSMutableAttributedString.init(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                return attr
            }
        }
        return nil
    }
}

public extension RZRichTextBase where T : NSAttributedString {
    // 获取selectedRange对应位置的attrName的前后关联range
    func rangeFor(attrName: NSAttributedString.Key, with selectedRange: NSRange) -> NSRange? {
        let pr = self.parapraghRange(for: selectedRange)
        var ranges : [NSRange] = []
        self.rt.enumerateAttribute(attrName, in: pr, options: []) { _, range, _ in
            ranges.append(range)
        }
        for range in ranges {
            if range.location <= selectedRange.location && range.rt.maxLength() >= selectedRange.location {
                return range
            }
        }
        return nil
    }
}

public extension RZRichTextBase where T : NSMutableAttributedString {
    /// 将富文本转换成对应的段落样式
    func mutableTransParagraphTo(_ style: RZTextTabStyle) {
        var flag = false
        self.rt.enumerateAttribute(.paragraphStyle, in: .init(location: 0, length: self.rt.length), options: []) { p, range, _ in
            if let p = p as? NSParagraphStyle {
                flag = true
                let temp = p.rt.transParagraphTo(style)
                self.rt.addAttribute(.paragraphStyle, value: temp, range: range)
            }
        }
        if !flag {
            let p = NSParagraphStyle.init()
            self.rt.addAttribute(.paragraphStyle, value: p, range: .init(location: 0, length: self.rt.length))
            self.mutableTransParagraphTo(style)
        }
    }
}
