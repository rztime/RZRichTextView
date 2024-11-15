//
//  RZRichText2Html.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/25.
//

import UIKit
import QuicklySwift

public struct RZRichTempAttributedString {
    let content: NSAttributedString
    let isul: Bool // 无序
    let isol: Bool // 有序
    let isblockquote: Bool // 块
}

public extension RZRichTextView {
    /// 转换时，需要确认附件是否真的上传完成，否则src、poster可能为空
    func code2html() -> String {
        if self.textStorage.length == 0 {
            return ""
        }
        return self.textStorage.code2Html(self.viewModel.spaceRule)
    }
    /// 重新编辑时，将html转换为NSAttributedString
    func html2Attributedstring(html: String?) {
        /// 判断是否和上次数据一样，（在tableVIew中，reload之后和上次一样，contentTextChanged回调会导致额外的错误）
        var isEqualtoLast = false
        defer {
            if !isEqualtoLast {
                self.typingAttributes = self.viewModel.defaultTypingAttributes
                if let d = self.delegate {
                    d.textViewDidChange?(self)
                } else {
                    self.contentTextChanged()
                }
            }
        }
        if html == self.html {
            isEqualtoLast = true
            return
        }
        self.html = html
        let configure = RZRichTextViewConfigure.shared
        /// 1.将html转换为NSAttributedString，图片用透明的png站位
        /// 2.将有序无序等样式统一成textView支持的样式
        /// 3.先通过url拉取本地音视频图片，然后直接写入到NSAttributedString，如果本地没下载图片，则异步线程开启下载拿到图片后，在写入
        guard let t = html?.html2Attributedstring(options:
                .init(options: [.maxWith(self.viewModel.attachmentMaxWidth),
                                .audioHeight(self.viewModel.audioAttachmentHeight),
                                .triming(self.viewModel.spaceRule),
                                .tabEnable(configure.tabEnable),
                                .quoteEnable(configure.quoteEnable),
                                .quoteOrTab(configure.quoteOrTab)
                                ])) else {
            return
        }
        let attr = NSMutableAttributedString(attributedString: t)
        func fix(attachment: NSTextAttachment, range: NSRange) {
            if let info = attachment.rzattachmentInfo, let image = info.image {
                var bounds = attachment.bounds
                /// 获取边距
                let inset = self.isEditable ? configure.imageViewEdgeInsets : configure.imageViewEdgeInsetsNormal
                // 图片的真实size
                let size = image.size.qscaleto(maxWidth: bounds.width - (inset.left + inset.right))
                // 图片与边距组合成一个最终的占位图，写入到attachment中
                let realSize = CGSize.init(width: size.width + (inset.left + inset.right), height: size.height + (inset.top + inset.bottom))
                if bounds.size != realSize {
                    bounds.size = realSize
                    attachment.bounds = bounds
                    self.fixAttachmentInfo(attachment: attachment)
                }
            }
        }
        let ats = attr.rt.attachments()
        for at in ats {
            if let info = at.0.rzattachmentInfo {
                if let _ = info.image {
                    fix(attachment: at.0, range: at.1)
                    continue
                }
                switch info.type {
                case .image, .video:
                    let url = info.poster?.qtoURL ?? info.src?.qtoURL
                    if let url = url?.absoluteString {
                        if let c = RZRichTextViewConfigure.shared.async_imageBy {
                            let complete: ((String?, UIImage?) -> Void)? = { [weak info] source, image in
                                info?.image = image
                                fix(attachment: at.0, range: at.1)
                            }
                            c(url, complete)
                        }
                    }
                case .audio:
                    var bounds = at.0.bounds
                    let inset = self.isEditable ? configure.imageViewEdgeInsets : configure.imageViewEdgeInsetsNormal
                    bounds.size.height = self.viewModel.audioAttachmentHeight + inset.top + inset.bottom
                    at.0.bounds = bounds
                }
            }
        }
        /// 修改链接字体
        attr.enumerateAttribute(.link, in: .init(location: 0, length: attr.length)) { link, range, _ in
            if link != nil {
                attr.removeAttribute(.foregroundColor, range: range)
                attr.removeAttribute(.strokeColor, range: range)
                attr.removeAttribute(.strokeWidth, range: range)
                attr.removeAttribute(.underlineStyle, range: range)
                attr.removeAttribute(.underlineColor, range: range)
                attr.addAttributes(self.linkTextAttributes, range: range)
            }
        }
        self.textStorage.setAttributedString(attr)
        self.selectedRange = .init(location: self.textStorage.length, length: 0)
    }
}
public extension NSAttributedString {
    func code2Html(_ trimmingCharacters: RZRichTextViewModel.RZSpaceRule = .none) -> String {
        /// 转换时，有部分属性用css实现，有部分用标签实现
        /// 用标签实现的有<s> <u> <p> <a> <ol> <li> <ul>
        /// 其他用内连css样式实现
        /// 原理，按段落拆分，每一段成一个<p>
        /// 每一段里，遍历所有的属性，将属性转换为css，写入到span样式里，然后组成一个<p>
        /// 最后将所有的<p>组合成<body>
        let content = self.rt.trimmingCharacters(in: trimmingCharacters)
        /// 分段
        let ranges = content.rt.allParapraghRange()
        var tempAllparagraphContents: [RZRichTempAttributedString] = []
        /// 判断每一段是否是ul，ol
        ranges.enumerated().forEach { idx, range in
            let attr = content.attributedSubstring(from: range)
            if attr.length > 0 {
                let p = attr.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
                let t = RZRichTempAttributedString.init(content: attr, isul: p?.isul ?? false, isol: p?.isol ?? false, isblockquote: p?.isblockquote ?? false)
                tempAllparagraphContents.append(t)
            } else {
                let t = RZRichTempAttributedString.init(content: attr, isul: false, isol: false, isblockquote: false)
                tempAllparagraphContents.append(t)
            }
        }
        /// 这里将有序无序包到段落外
        var realParagraphs: [Any] = []
        /// 如果有ul，ol，则将段前段后加入<ul> <ol> <li>
        tempAllparagraphContents.enumerated().forEach { idx, p in
            let para = p.content.rt.paragraphstyle
            let lastpul = idx > 0 ? (tempAllparagraphContents[qsafe: idx - 1]?.isul ?? false) : false
            let currentpul = p.isul
            let nextpul = tempAllparagraphContents[qsafe: idx + 1]?.isul ?? false
            
            let lastpol = idx > 0 ? (tempAllparagraphContents[qsafe: idx - 1]?.isol ?? false) : false
            let currentpol = p.isol
            let nextpol = tempAllparagraphContents[qsafe: idx + 1]?.isol ?? false
            var style = "<li>"
            if para?.alignment == .center {
                style = #"<li style="text-align:center;">"#
            } else if para?.alignment == .right {
                style = #"<li style="text-align:right;">"#
            }
            if currentpul && !lastpul { realParagraphs.append("<ul>") }
            if currentpol && !lastpol { realParagraphs.append("<ol>") }
            if currentpul || currentpol { realParagraphs.append(style) }
            if p.isblockquote {
                var style = ""
                if para?.alignment == .center {
                    style = #"text-align:center;"#
                } else if para?.alignment == .right {
                    style = #"text-align:right;"#
                }
                if style.isEmpty && RZRichTextViewConfigure.shared.blockquoteStyle.isEmpty {
                    realParagraphs.append("<blockquote>")
                } else {
                    realParagraphs.append("<blockquote style=\"\(style)\(RZRichTextViewConfigure.shared.blockquoteStyle)\">")
                }
            }
            if p.content.string == "\n" {
                if !currentpol && !currentpul {
                    realParagraphs.append("<br/>")
                } 
            } else {
                realParagraphs.append(p.content)
            }
            if p.isblockquote {
                realParagraphs.append("</blockquote>")
            }
            if currentpul || currentpol { realParagraphs.append("</li>") }
            if currentpol && !nextpol { realParagraphs.append("</ol>") }
            if currentpul && !nextpul { realParagraphs.append("</ul>") }
        }
        var html: [String] = []
        for value in realParagraphs {
            if let v = value as? String {
                html.append(v)
                continue
            }
            /// 这里得到每一段，然后加p
            guard let attr = value as? NSAttributedString else { continue }
            var pstar: [String] = []
            var pend: [String] = []
            let font: UIFont? = attr.length > 0 ? attr.attribute(.font, at: 0, effectiveRange: nil) as? UIFont : nil
            if attr.length > 0, let p = attr.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                if !(p.isol || p.isul || p.isblockquote) {
                    pstar.append("<p style=\"\(p.rz2cssStyle(font: font))\">")
                    pend.insert("</p>", at: 0)
                }
            } else {
                pstar.append("<p>")
                pend.insert("</p>", at: 0)
            }
            /// 针对段落里文本属性的不同，遍历返回的样式不同，组成每一个span以及对应的css样式
            attr.enumerateAttributes(in: .init(location: 0, length: attr.length)) { dict, range, _ in
                let tempAttr = attr.attributedSubstring(from: range)
                if tempAttr.string == "\n" {
                    return
                }
                var labelStar: [String] = []
                var labelEnd: [String] = []
                let isS = (dict[.strikethroughStyle] as? NSNumber ?? 0) != 0
                if isS {
                    labelStar.append("<s>")
                    labelEnd.insert("</s>", at: 0)
                }
                let isU = (dict[.underlineStyle] as? NSNumber ?? 0) != 0
                if isU {
                    labelStar.append("<u>")
                    labelEnd.insert("</u>", at: 0)
                }
                if let _ = dict[.attachment] as? NSTextAttachment {
                    labelStar.append("<span>")
                    labelEnd.insert("</span>", at: 0)
                } else  {
                    labelStar.append("<span style=\"\(dict.rz2cssStyle)\">")
                    labelEnd.insert("</span>", at: 0)
                }
                if let url = dict[.link] as? URL {
                    labelStar.append("<a href=\"\(url.absoluteString)\">")
                    labelEnd.insert("</a>", at: 0)
                } else if let url = dict[.link] as? String {
                    labelStar.append("<a href=\"\(url)\">")
                    labelEnd.insert("</a>", at: 0)
                }
                if let attachment = dict[.attachment] as? NSTextAttachment {
                    labelStar.append(attachment.rz2html)
                } else if tempAttr.string.count > 0 {
                    let text = tempAttr.string.replacingOccurrences(of: "\n", with: "").fixHtml()
                    labelStar.append(text)
                }
                let temp = labelStar + labelEnd
                pstar.append(temp.joined())
            }
            let temp = pstar + pend
//            html.append(temp.joined(separator: "\n")) // 加\n在查看html时更友好
            html.append(temp.joined())
        }
        var res = html.joined()//html.joined(separator: "\n")
        res = res.replacingOccurrences(of: "\u{2028}", with: "<br/>")
        return res
    }
}
open class RZHtmlOptions {
    open var maxWidth: CGFloat = qscreenwidth - 20
    open var audioHeight: CGFloat = 60
    open var trimingCharacters: RZRichTextViewModel.RZSpaceRule = .none
    open var tabEnable: Bool = true
    open var quoteEnable = false
    open var quoteOrTab = true
    
    public enum Options {
        /// 附件最大宽度
        case maxWith(_ width: CGFloat)
        /// 音频高度
        case audioHeight(_ height: CGFloat)
        /// 截断规则
        case triming(_ rule: RZRichTextViewModel.RZSpaceRule)
        /// 允许textView修复列表ul\ol
        case tabEnable(_ enable: Bool)
        /// 允许列表修复块引用
        case quoteEnable(_ enbale: Bool)
        /// 列表和块引用只能二选一 (false时,可以同时存在)
        case quoteOrTab(_ either: Bool)
    }
    
    public init(options:[RZHtmlOptions.Options]) {
        options.forEach { option in
            switch option {
            case .maxWith(let width):
                self.maxWidth = width
            case .audioHeight(let height):
                self.audioHeight = height
            case .triming(let rule):
                self.trimingCharacters = rule
            case .tabEnable(let enable):
                self.tabEnable = enable
            case .quoteEnable(let enable):
                self.quoteEnable = enable
            case .quoteOrTab(let either):
                self.quoteOrTab = either
            }
        }
    }
    /// 默认 for label 或者普通的仅用于展示的TextView
    public class func defaultForLabel(_ maxWidth: CGFloat, _ audioHeight: CGFloat) -> RZHtmlOptions {
        return RZHtmlOptions.init(options: [.maxWith(maxWidth), .audioHeight(audioHeight), .triming(.removeEnd), .tabEnable(false), .quoteEnable(false), .quoteOrTab(true)])
    }
}


public extension String {
    ///  将html转换为NSAttributedString
    /// - Parameters:
    ///   - attahcmentMaxWidth: 附件的最大宽度
    ///   - audioHeight: 音频的高度
    ///   - trimmingCharacters: 截断方式
    ///   - loadAttachments: 加载附件，需要调用kf等方式将info里的src、poster加载成图片，用于显示
    func html2Attributedstring(options: RZHtmlOptions, loadAttachments: ((_ infos: [RZAttachmentInfo]) -> Void)? = nil) -> NSAttributedString? {
        let html = self
        guard !html.isEmpty else {
            return nil
        }
        var tempHtml = html as NSString
        // 在真机中，\"  与 ” 转换没问题
        // 在模拟器中，<p style=\"text-align:center;\"> 这种\" 会导致无法居中
        tempHtml = tempHtml.replacingOccurrences(of: #"\""#, with: #"""#) as NSString
        tempHtml = tempHtml.replacingOccurrences(of: "\n", with: "") as NSString
        var attachments: [RZAttachmentInfo] = []
        /// 找音、视频、图片
        let regrule = #"(<video\s+.*?src\s*=\s*([^ <>]+)\b.*?>([\s\S]*?)</video>)|(<audio\s+.*?src\s*=\s*([^ <>]+)\b.*?>([\s\S]*?)</audio>)|(<img\s+.*?src\s*=\s*([^ <>]+)\b.*?>)"#
        if let regex = try? NSRegularExpression.init(pattern: regrule, options: .caseInsensitive) {
            var labels:[RZLabelInfo] = []
            let matches = regex.matches(in: tempHtml as String, range: NSRange.init(location: 0, length: tempHtml.length))
            for matche in matches {
                let element = tempHtml.substring(with: matche.range)
                let labelInfo = RZLabelInfo.init(label: element, range: matche.range)
                labelInfo.width = options.maxWidth
                let info = RZAttachmentInfo.init(type: labelInfo.type, image: nil, asset: nil, filePath: nil, maxWidth: options.maxWidth, audioHeight: options.audioHeight, isReEdit: true)
                info.src = labelInfo.src.isEmpty ? nil : labelInfo.src
                info.poster = labelInfo.poster.isEmpty ? nil : labelInfo.poster
                info.uploadStatus.accept(.complete(success: true, info: nil))
                attachments.append(info)
                labels.append(labelInfo)
            }
            labels.reversed().forEach { info in
                tempHtml = tempHtml.replacingCharacters(in: info.range, with: info.templabel) as NSString
            }
        }
        /// 标记块
        let regruleblockquote = #"<blockquote(.*?)>"#
        let blockquoteStar = "『rzrichtextview-blockquote-star』"
        let blockquoteEnd = "『rzrichtextview-blockquote-end』"
        if options.quoteEnable {
            if let regex = try? NSRegularExpression.init(pattern: regruleblockquote, options: .caseInsensitive) {
                let matches = regex.matches(in: tempHtml as String, range: .init(location: 0, length: tempHtml.length))
                matches.reversed().forEach { match in
                    let element = tempHtml.substring(with: match.range)
                    tempHtml = tempHtml.replacingCharacters(in: match.range, with: "\(element)<span>\(blockquoteStar)</span>") as NSString
                }
            }
            if let regex = try? NSRegularExpression.init(pattern: #"</blockquote>"#, options: .caseInsensitive) {
                let matches = regex.matches(in: tempHtml as String, range: .init(location: 0, length: tempHtml.length))
                matches.reversed().forEach { match in
                    let element = tempHtml.substring(with: match.range)
                    tempHtml = tempHtml.replacingCharacters(in: match.range, with: "\(element)<span>\(blockquoteEnd)</span>") as NSString
                }
            }
        }
        
        let attr = NSAttributedString.rz.colorfulConfer { confer in
            confer.htmlString(tempHtml as String)
        }
        guard let attr = attr else {
            return nil
        }
        let tempAttr = NSMutableAttributedString.init(attributedString: attr)
        /// 设置块
        if options.quoteEnable, let regexblockquoteStar = try? NSRegularExpression.init(pattern: "\(blockquoteStar)", options: .caseInsensitive), let regexblockquoteend = try? NSRegularExpression.init(pattern: "\(blockquoteEnd)", options: .caseInsensitive)  {
            let rangestars = regexblockquoteStar.matches(in: tempAttr.string, range: .init(location: 0, length: tempAttr.length)).compactMap({$0.range})
            let rangeends = regexblockquoteend.matches(in: tempAttr.string, range: .init(location: 0, length: tempAttr.length)).compactMap({$0.range})
            var ranges: [NSRange] = []
            rangestars.enumerated().forEach { idx, rg in
                let star = rg.location
                let end = rangeends[qsafe: idx]?.rt.maxLength() ?? 0
                ranges.append(.init(location: star, length: max(0, end - star)))
            }
            ranges.forEach { range in
                tempAttr.enumerateAttribute(.paragraphStyle, in: range) { p, range, _ in
                    if let p = p as? NSParagraphStyle {
                        let tempa = NSMutableParagraphStyle()
                        tempa.setParagraphStyle(p)
                        tempa.setBlockquote(.blockquote)
                        tempAttr.addAttribute(.paragraphStyle, value: tempa, range: range)
                    }
                }
            }
            var rgs = rangestars + rangeends
            rgs = rgs.sorted { rg1, rg2 in
                return rg1.location <= rg2.location
            }.reversed()
            rgs.forEach { rg in
                tempAttr.replaceCharacters(in: rg, with: "")
            }
        }
        if options.tabEnable {  // 在编辑时，需要统一修复一下序列，否则会显示错误
            var ranges = tempAttr.rt.allParapraghRange()
            /// 将有序无序自动生成的\t1.\t或者\t•\t去掉,  这个地方的会导致最后生成的html多显示
            ranges.reversed().forEach { range in
                let sub = tempAttr.attributedSubstring(from: range)
                if sub.length > 0, let p = sub.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                    if p.isol || p.isul {
                        if let regex = try? NSRegularExpression.init(pattern: "\t.*\t", options: .caseInsensitive) {
                            let matches = regex.matches(in: sub.string, range: NSRange.init(location: 0, length: min(sub.string.count, 8)))
                            if let m = matches.first?.range, m.length > 0 {
                                let r = NSRange.init(location: range.location + m.location, length: m.length)
                                tempAttr.deleteCharacters(in: r)
                            }
                        }
                    }
                }
            }
            ranges = tempAttr.rt.allParapraghRange()
            /// 先将段落样式修改统一, html直接转attr时，ul、ol属性，添加的\t1\t等内容会被当做正文，会导致额外的错误
            ranges.forEach { range in
                let sub = tempAttr.attributedSubstring(from: range)
                if sub.length > 0, let p = sub.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                    let mp = NSMutableParagraphStyle.init()
                    mp.paragraphSpacingBefore = p.paragraphSpacingBefore
                    mp.paragraphSpacing = p.paragraphSpacing
                    mp.headIndent = p.headIndent
                    mp.firstLineHeadIndent = p.firstLineHeadIndent
                    mp.tailIndent = p.tailIndent
                    if p.isol {
                        mp.setTextListType(.ol)
                    } else if p.isul {
                        mp.setTextListType(.ul)
                    }
                    switch p.alignment {
                    case .center, .right: mp.alignment = p.alignment
                    case .left, .natural, .justified: mp.alignment = .left
                    @unknown default:  break
                    }
                    tempAttr.addAttribute(.paragraphStyle, value: mp, range: range)
                }
            }
        }
        /// 修改字体
        tempAttr.enumerateAttribute(.font, in: .init(location: 0, length: tempAttr.length)) { font, range, _ in
            if let font = font as? UIFont {
                let newfont: UIFont
                switch font.fontType {
                case .boldItalic:
                    newfont = UIFont.rzboldItalicFont.withSize(font.pointSize)
                case .bold:
                    newfont = UIFont.rzboldFont.withSize(font.pointSize)
                case .italic:
                    newfont = UIFont.rzitalicFont.withSize(font.pointSize)
                case .normal:
                    newfont = UIFont.rznormalFont.withSize(font.pointSize)
                }
                tempAttr.addAttribute(.font, value: newfont, range: range)
            }
        }
        /// 设置附件的图片，附件的bounds，由textView或者UILabel自己实现
        /// 取未编辑状态的配置
        let configure = RZRichTextViewConfigure.shared.imageViewEdgeInsetsNormal
        let ats : [NSTextAttachment] = tempAttr.rt.attachments().compactMap({$0.0})
        ats.enumerated().forEach { idx, at in
            if let att = attachments[qsafe: idx] {
                at.rzattachmentInfo = att
                switch att.type {
                case .image, .video:
                    let url = att.poster?.qtoURL ?? att.src?.qtoURL
                    if let url = url?.absoluteString, let c = RZRichTextViewConfigure.shared.sync_imageBy {
                        att.image = c(url)
                    }
                case .audio:
                    var bounds = at.bounds
                    bounds.size.height = att.audioViewHeight + configure.top + configure.bottom
                    at.bounds = bounds
                    at.image = RZRichTextViewConfigure.shared.attachBackgroundColor.qtoImage(bounds.size)
                }
            }
        }
        DispatchQueue.main.async {
            /// 加载图片
            let res = ats.filter({$0.rzattachmentInfo?.image == nil && $0.rzattachmentInfo?.type != .audio})
            if !res.isEmpty {
                loadAttachments?(res.compactMap({$0.rzattachmentInfo}))
            }
        }
        return tempAttr.rt.trimmingCharacters(in: options.trimingCharacters)
    }
    func fixHtml() -> String {
        let symbols = [
            ("&", "&amp;"),
            ("<","&lt;"),
            (">","&gt;"),
            (" ","&nbsp;"),  // 这个是空格
            (" ","&nbsp;"),  // 这个是<0xa0>
            ("©","&copy;"),
            ("®","&reg;"),
            ("™","&trade;"),
        ]
        var temp = self
        symbols.forEach { (v1, v2) in
            temp = temp.replacingOccurrences(of: v1, with: v2)
        }
        return temp
    }
}

public class RZLabelInfo {
    let label: String
    let range: NSRange
    
    var type: RZAttachmentInfo.AttachmentType = .image
    
    var src: String = ""
    var poster: String = ""
    
    var width: CGFloat = 300
    
    init(label: String, range: NSRange) {
        self.label = label
        self.range = range
        
        if label.hasPrefix("<img") {type = .image}
        else if label.hasPrefix("<video") {type = .video}
        else if label.hasPrefix("<audio") {type = .audio}
        // 使用NSString，是因为有些表情，长度不为1
        let text = label.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\\", with: "") as NSString
        
        guard let srcRegex = try? NSRegularExpression(pattern: #"src=("|')(.*?)("|')"#, options: .caseInsensitive) else { return }
        let srcrange = NSRange(location: 0, length: text.length)
        let srcresult = srcRegex.matches(in: text as String, range: srcrange)
        
        if let match = srcresult.first {
            let src = text.substring(with: match.range)
            self.src = src.replacingOccurrences(of: "src='", with: "").replacingOccurrences(of: #"src=""#, with: "").replacingOccurrences(of: #"""#, with: "")
        }
        if self.type != .video { return }
        
        guard let posterRegex = try? NSRegularExpression(pattern: #"poster=("|')(.*?)("|')"#, options: .caseInsensitive) else { return }
        let posterrange = NSRange(location: 0, length: text.length)
        let posterresult = posterRegex.matches(in: text as String, range: posterrange)
        
        if let match = posterresult.first {
            let poster = text.substring(with: match.range)
            self.poster = poster.replacingOccurrences(of: "poster='", with: "").replacingOccurrences(of: #"poster=""#, with: "").replacingOccurrences(of: #"""#, with: "")
        }
    }
    var templabel: String {
        let image = RZRichTextViewConfigure.shared.attachBackgroundColor.qtoImage(.init(width: 16.0, height: 9.0))
        let base64 = image?.qtoPngData()?.base64EncodedString() ?? ""
        return "<img src=\"data:image/jpeg;base64,\(base64)\" style=\"width:\(width)px; height:\(width * 9.0 / 16.0)px;\">"
    }
}
