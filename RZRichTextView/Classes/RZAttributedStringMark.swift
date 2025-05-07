//
//  RZAttributedStringMark.swift
//  RZRichTextView
//
//  Created by rztime on 2025/3/21.
//

import UIKit
public extension String {
    func rzsubstring(with range: NSRange) -> String? {
        guard let swiftRange = Range(range, in: self) else {
            return nil
        }
        return String(self[swiftRange])
    }
    /// 根据ID生成一个开始和结束的标签
    static func rzcustomMark(key: String, id: String) -> (start: String, end: String) {
        return ("<span>[#ios-mark-start-\(key)-\(id)#]</span>",
                "<span>[#ios-mark-end-\(key)-\(id)#]</span>")
    }
}
public extension NSAttributedString {
    /// 添加自定义的标签,详情看rzmark
    /* html转换为NSAttributedString时，打标记
     如：
     <body>
     xxxx
     <span style='color:red;'>测试</span>
     xxxx
     </body>
     
     当生成NSAttributedString后，需要找到"测试"所在位置,
     那么插入:
     <span>[#ios-mark-start-key-id#]</span>
     <span>[#ios-mark-end-key-id#]</span>
    
     // key为NSAttributedString里的key，（id为\\w+：匹配字母、数字和下划线）正则："\\[#ios-mark-(start|end)-(\\w+)-(\\w+)#\\]"
     即：
     <body>
     xxxx
     <span style='color:red;'><span>[#ios-mark-start-key1-1#]</span>测试<span>[#ios-mark-end-key1-1#]</span></span>
     xxxx
     </body>
     最终生成的NSAttributedString里“测试”两个字的属性里将包含key1 = 1;
     */
    func addcustomMarkIfNeed() -> NSMutableAttributedString {
        let tempAttr = NSMutableAttributedString(attributedString: self)
        let mark = tempAttr.findMark()
        /// markRanegs,记录添加的字符串，用于删除
        var markRanges: [NSRange] = []
        mark.forEach { info in
            if let startRange = info.startRange, let endRange = info.endRange {
                let r = NSRange(location: startRange.lowerBound, length: endRange.upperBound - startRange.lowerBound)
                tempAttr.addAttribute(.init(rawValue: info.key), value: info.id, range: r)
            }
            if let s = info.startRange {
                markRanges.append(s)
            }
            if let e = info.endRange {
                markRanges.append(e)
            }
        }
        markRanges = markRanges.sorted { rg1, rg2 in
            return rg1.location > rg2.location
        }
        markRanges.forEach { rg in
            tempAttr.deleteCharacters(in: rg)
        }
        return tempAttr
    }
    func findMark() -> [RZMarkRange] {
        let string = self.string
        let pattern = "\\[#ios-mark-(start|end)-(\\w+)-(\\w+)#\\]" // 匹配star和end
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        var startDict: [String: (key: String, id: String, location: NSRange)] = [:]
        var endDict: [String: (key: String, id: String, location: NSRange)] = [:]
        for match in matches {
            if match.numberOfRanges == 4 {
                guard let label = string.rzsubstring(with: match.range(at: 1)),
                      let key = string.rzsubstring(with: match.range(at: 2)),
                      let id = string.rzsubstring(with: match.range(at: 3)) else {
                    continue
                }
                if label == "start" { startDict[id] = (key, id, match.range) }
                if label == "end" { endDict[id] = (key, id, match.range) }
            }
        }
        var result: [RZMarkRange] = []
        let keys = Array(Set(Array(startDict.keys) + Array(endDict.keys)))
        keys.forEach { key in
            let start = startDict[key]
            let end = endDict[key]
            let mark = RZMarkRange(key: (start?.key ?? end?.key) ?? "", id: (start?.id ?? end?.id) ?? "", startRange: start?.location, endRange: end?.location)
            result.append(mark)
        }
        return result
    }
}
public class RZMarkRange {
    public var key: String = ""
    public var id: String = ""
    public var startRange: NSRange?
    public var endRange: NSRange?
    init(key: String, id: String, startRange: NSRange? = nil, endRange: NSRange? = nil) {
        self.key = key
        self.id = id
        self.startRange = startRange
        self.endRange = endRange
    }
}
