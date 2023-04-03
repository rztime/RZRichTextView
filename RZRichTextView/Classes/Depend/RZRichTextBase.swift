//
//  RZRichTextBase.swift
//  RZRichTextView
//
//  Created by rztime on 2021/11/16.
//

import UIKit

public struct RZRichTextBase<T> {
    public let rt: T
    public init(rt: T) {
        self.rt = rt
    }
}
public protocol RZRichTextProtocol { }
public extension RZRichTextProtocol {
    static var rt: RZRichTextBase<Self>.Type {
        get { return RZRichTextBase<Self>.self }
        set { }
    }
    var rt: RZRichTextBase<Self> {
        get { return RZRichTextBase.init(rt: self) }
        set { }
    }
}

extension Dictionary                : RZRichTextProtocol {}
extension NSAttributedString.Key    : RZRichTextProtocol {}
extension NSRange                   : RZRichTextProtocol {}
extension NSAttributedString        : RZRichTextProtocol {}
extension NSParagraphStyle          : RZRichTextProtocol {}
extension String                    : RZRichTextProtocol {}
extension UITextView                : RZRichTextProtocol {}
