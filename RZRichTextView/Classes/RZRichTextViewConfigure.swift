//
//  RZRichTextViewConfigure.swift
//  RZRichTextView
//
//  Created by rztime on 2024/8/23.
//

import UIKit

open class RZRichTextViewConfigure: NSObject {
    public static var shared: RZRichTextViewConfigure = .init()
    /// 同步获取图片
    public var sync_imageBy: ((_ source: String?) -> UIImage?)?
    /// 异步获取图片，complete里的source需要于图片对应
    public var async_imageBy: ((_ source: String?, _ complete: ((_ source: String?, _ image: UIImage?) -> Void)?) -> Void)?
}
