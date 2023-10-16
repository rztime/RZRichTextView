//
//  RZCssAndHtmlExtension.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/25.
//

import UIKit
import RZColorfulSwift

public extension NSParagraphStyle {
    fileprivate struct RZTextListTypeName {
        static var name = "RZTextListTypeName"
    }
    enum RZTextListType: Int {
        case none //
        case ol     // 有序
        case ul     // 无序
    }
    /// 有序无序状态
    var rzTextListType: RZTextListType {
        set {
            objc_setAssociatedObject(self, &RZTextListTypeName.name, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let value = objc_getAssociatedObject(self, &RZTextListTypeName.name) as? RZTextListType {
                return value
            }
            return .none
        }
    }
    /// 是否是有序段落
    var isol: Bool {
        if self.rzTextListType == .ol {
            return true
        }
        var temp = false
        self.textLists.forEach { item in
            if item.markerFormat.rawValue.contains(NSTextList.MarkerFormat.decimal.rawValue) {
               temp = true
            }
        }
        if self.firstLineHeadIndent > 30.08 && self.firstLineHeadIndent < 30.12 &&
            self.headIndent > 30.08 && self.headIndent < 30.12{
            temp = true
        }
        return temp
    }
    /// 是否是无序
    var isul: Bool {
        if self.rzTextListType == .ul {
            return true
        }
        var temp = false
        self.textLists.forEach { item in
            if item.markerFormat.rawValue.contains(NSTextList.MarkerFormat.disc.rawValue) {
               temp = true
            }
        }
        if self.firstLineHeadIndent > 30.28 && self.firstLineHeadIndent < 30.32 &&
            self.headIndent > 30.28 && self.headIndent < 30.32{
            temp = true
        }
        return temp
    }
    /// 将paragraph转换为css对应的样式
    func rz2cssStyle(font: UIFont?) -> String {
        var styles: [String] = []
        if !self.isol && !self.isul {
            styles.append("margin:\(self.paragraphSpacingBefore)px 0.0px \(self.paragraphSpacing)px \(self.headIndent)px;")
        } 
        switch self.alignment {
        case .left, .justified, .natural: break
        case .center: styles.append("text-align:center;")
        case .right: styles.append("text-align:right;")
        @unknown default:
            break
        }
        if self.tailIndent != 0 { styles.append("text-indent:\(self.tailIndent)px;") }
        if let font = font {
            styles.append("font-size:\(font.pointSize)px;")
        }
        return styles.joined()
    }
}
public extension NSMutableParagraphStyle {
    /// 设置列表样式
    func setTextListType(_ type: NSParagraphStyle.RZTextListType) {
        self.rzTextListType = type
        self.textLists = []
        // 30.1 30.3浮点需要，主要用于区分
        switch type {
        case .none:
            self.firstLineHeadIndent = 0
            self.headIndent = 0
        case .ol:
            self.firstLineHeadIndent = 30.1
            self.headIndent = 30.1
        case .ul:
            self.firstLineHeadIndent = 30.3
            self.headIndent = 30.3
        }
    }
}

public extension [NSAttributedString.Key: Any] {
    var rz2cssStyle: String {
        var styletexts:[String] = []
        self.keys.forEach { key in
            let value = self[key]
            switch key {
            case .paragraphStyle, .strikethroughStyle, .underlineStyle, .attachment, .link: break // 外部实现 <p> <s> <u> 附件<图片、音频、视频> <a> // 在外部实现
            case .ligature, .obliqueness: break // 不使用
            case .font:
                if let font = value as? UIFont {
                    styletexts.append("font-size:\(font.pointSize)px;")
                    switch font.fontType {
                    case .boldItalic:
                        styletexts.append("font-weight:bold;")
                        styletexts.append("font-style:italic;")
                    case .bold:
                        styletexts.append("font-weight:bold;")
                    case .italic:
                        styletexts.append("font-style:italic;")
                    case .normal:
                        break
                    } 
                }
            case .foregroundColor:
                if let color = value as? UIColor { styletexts.append("color:#\(color.qhexString);") }
            case .backgroundColor:
                if let color = value as? UIColor { styletexts.append("background-color:#\(color.qhexString);") }
            case .kern:
                if let value = value as? NSNumber, value.floatValue != 0 { styletexts.append("word-spacing:\(value)px;") }
            case .strokeWidth:
                if let value = value as? NSNumber, value.floatValue != 0 {
                    let font = self[.font] as? UIFont
                    let size = font?.pointSize ?? 15
                    let v = CGFloat(value.floatValue) * size / 100.0
                    //strokeColor
                    let color = ((self[.strokeColor] as? UIColor) ?? (self[.foregroundColor] as? UIColor)) ?? .clear
                    if v > 0 {
                        styletexts.append("-webkit-text-stroke:\(v)px #\(color.qhexString);color:#00000000;")
                    } else {
                        styletexts.append("-webkit-text-stroke:\(v)px #\(color.qhexString);")
                    }
                }
            case .shadow:
                if let value = value as? NSShadow {
                    let offset = value.shadowOffset
                    let rad = value.shadowBlurRadius
                    let color = ((value.shadowColor as? UIColor) ?? (self[.foregroundColor] as? UIColor)) ?? .clear
                    styletexts.append("text-shadow:\(offset.width)px \(offset.height)px \(rad)px #\(color.qhexString);")
                }
            case .baselineOffset:
                if let value = value as? NSNumber, value.floatValue != 0 { styletexts.append("vertical-align:\(value)px;") }
            case .expansion:
                if let value = value as? NSNumber, value.floatValue != 0 {
                    styletexts.append("transform:scaleX(\(HtmlTransformRZ.expansionTrans(value.floatValue)));transform-origin: 0 0;display:inline-block;")
                }
            default: break
            }
        }
        return styletexts.joined()
    }
}

public extension NSTextAttachment {
    var rz2html: String {
        guard let info = self.rzattachmentInfo else { return ""}
        switch info.type {
        case .audio:
            return "<audio src=\"\(info.src ?? "")\" controls=\"controls\" style=\"max-width:100%;\">您的浏览器不支持此音频格式</audio>"
        case .image:
            return "<img src=\"\(info.src ?? "")\" style=\"max-width:100%;\">"
        case .video:
            return "<video src=\"\(info.src ?? "")\" poster=\"\(info.poster ?? "")\" controls=\"controls\" style=\"max-width:100%;\">您的浏览器不支持此视频格式</video>"
        }
    }
}

public extension UIFont {
    /// 普通字体
    static var rznormalFont = UIFont.systemFont(ofSize: 16)
    /// 斜体
    static var rzitalicFont = UIFont.init(descriptor: .init(name: ".AppleSystemUIFontItalic", matrix: CGAffineTransform.init(1, 0, 0.2, 1, 0, 0)), size: 16)
    /// 粗体
    static var rzboldFont = UIFont.boldSystemFont(ofSize: 16)
    /// 粗斜体
    static var rzboldItalicFont = UIFont.init(descriptor: .init(name: ".AppleSystemUIFontBoldItalic", matrix: CGAffineTransform.init(1, 0, 0.2, 1, 0, 0)), size: 16)
    
    enum RZFontType {
        case normal
        case boldItalic
        case bold
        case italic
    }
    /// 字体类型
    var fontType: RZFontType {
        let desc = self.description.replacingOccurrences(of: " ", with: "")
        let b = desc.contains("font-weight:bold") || desc.contains("font-weight:Bold")
        let i = desc.contains("font-style:italic") || desc.contains("font-style:Italic")
        if b && i {
            return .boldItalic
        }
        if b { return .bold }
        if i { return .italic}
        return .normal
    }
}
