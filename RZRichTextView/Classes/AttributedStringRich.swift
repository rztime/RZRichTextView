//
//  AttributedStringRich.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/21.
//

import UIKit
import QuicklySwift

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
        var res: [NSRange] = []
        for (idx, tempRange) in all.enumerated() {
            if let _ = range.intersection(tempRange) {
                res.append(tempRange)
            } else if idx == all.count - 1 {
                if range.location >= tempRange.location && range.location <= tempRange.rt.maxLength() {
                    res.append(tempRange)
                } else if range.upperBound >= tempRange.location && range.upperBound <= tempRange.upperBound {
                    res.append(tempRange)
                }
            } else if range.location >= tempRange.rt.maxLength() {
            
            } else if range.location >= tempRange.location && range.location <= tempRange.rt.maxLength() {
                res.append(tempRange)
            } else if range.location < tempRange.location && range.rt.maxLength() > tempRange.location {
                res.append(tempRange)
            } else if range.upperBound >= tempRange.location && range.upperBound <= tempRange.upperBound {
                res.append(tempRange)
            }
        }
        return res
    }
    /// 当前文本的所有段落
    func allParapraghRange() -> [NSRange] {
        var ranges: [NSRange] = []
        var range: NSRange = .init(location: 0, length: 0)
        while range.location <= self.rt.length {
            let rg = self.parapraghRange(for: range)
            if let last = ranges.last, last == rg {
                break
            }
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
    /// 富文本，截取前后空格回车
    func trimmingCharacters(in rule: RZRichTextViewModel.RZSpaceRule) -> NSAttributedString {
        let attr = self.rt
        switch rule {
        case .none:
            return attr
        case .removeHead:
            if attr.string.hasPrefix("\t") || attr.string.hasPrefix(" ") || attr.string.hasPrefix("\n") {
                let temp = attr.attributedSubstring(from: .init(location: 1, length: attr.length - 1))
                return temp.rt.trimmingCharacters(in: .removeHead)
            }
        case .removeEnd:
            if attr.string.hasSuffix("\t") || attr.string.hasSuffix(" ") || attr.string.hasSuffix("\n") {
                let temp = attr.attributedSubstring(from: .init(location: 0, length: attr.length - 1))
                return temp.rt.trimmingCharacters(in: .removeEnd)
            }
        case .removeHeadAndEnd:
            var temp = attr.rt.trimmingCharacters(in: .removeHead)
            temp = temp.rt.trimmingCharacters(in: .removeEnd)
            return temp
        }
        return attr
    }
    /// 是否包含某个attrName
    func containsAttName(_ name: NSAttributedString.Key) -> Bool {
        var contain = false
        self.rt.enumerateAttribute(name, in: .init(location: 0, length: self.rt.length)) { value, range, stop in
            if let value = value as? NSNumber {
                if value.floatValue != 0 {
                    contain = true
                    stop.pointee = true
                }
            } else if let _ = value {
                contain = true
                stop.pointee = true
            }
        }
        return contain
    }
    /// 当前文本最开始处的段落样式
    var paragraphstyle: NSParagraphStyle? {
        if self.rt.length > 0, let p = self.rt.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            return p
        }
        return nil
    }
    /// 获取所有的附件
    func attachments() -> [(NSTextAttachment, NSRange)] {
        var res: [(NSTextAttachment, NSRange)] = []
        let attr = self.rt
        attr.enumerateAttribute(.attachment, in: .init(location: 0, length: attr.length)) { value, range, _ in
            if let value = value as? NSTextAttachment {
                res.append((value, range))
            }
        }
        return res
    }
}
public extension RZRichTextBase where T == NSRange {
    func maxLength() -> NSInteger {
        let r = self.rt
        return r.location + r.length
    }
}
