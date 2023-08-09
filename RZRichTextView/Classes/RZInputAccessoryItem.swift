//
//  RZInputAccessoryItem.swift
//  RZRichTextView
//
//  Created by rztime on 2023/7/20.
//

import UIKit
/// 工具栏功能类型
public enum RZInputAccessoryType: Int {
    case none
    case fontStyle  /// 字体样式
    case tableStyle      /// 列表（有序、无序）
    case paragraph  /// 段落样式
    case media      /// 媒体资源（图片、视频、音频）
    case link       /// 链接
    case revoke     /// 撤销
    case restore    /// 恢复
    case close      /// 关闭键盘
    
    case image      /// 图片
    case video      /// 视频
    case audio      /// 音频
    
    /// 对齐
    case p_left     /// 左对齐
    case p_center   /// 居中对齐
    case p_right    /// 右对齐
    
    /// 列表属性
    case t_ol       /// 有序
    case t_ul       /// 无序
    
    /// 以下是预留，自定义实现
    case custom1
    case custom2
    case custom3
    case custom4
    case custom5
    case custom6
    case custom7
    case custom8
    case custom9
    case custom10
    case custom11
    case custom12
    case custom13
    case custom14
    case custom15
    case custom16
    case custom17
    case custom18
    case custom19
    case custom20
}

/// 工具栏item
open class RZInputAccessoryItem: NSObject {
    open var type: RZInputAccessoryType = .none
    // 默认显示图片
    open var image: UIImage?
    // 高亮选择时的图片
    open var highlightImage: UIImage?
    
    open var selected: Bool = false
    
    /// 如果当前功能不可用，设置为false
    open var enable = true
    
    public override init() {
        super.init()
    }
    open var displayImage: UIImage? {
        return selected ? (highlightImage ?? image) : image
    }
    public init(type: RZInputAccessoryType, image: UIImage?, highlight: UIImage?, selected: Bool = false, enable: Bool = true) {
        super.init()
        self.selected = selected
        self.type = type
        self.image = image
        self.highlightImage = highlight
        self.enable = enable
    }
}
