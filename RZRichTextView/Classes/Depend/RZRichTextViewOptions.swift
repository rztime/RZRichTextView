//
//  RZRichTextViewOptions.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/15.
//

import UIKit
import Photos

// 输入键盘上的工具条
@objc public enum RZTextViewToolbarItem : NSInteger {
    case endEdit        = 0
    case image          = 1 // 插入图片
    case font           = 2  // 文本样式设置
    case baseOfline     = 3 // 偏移设置 ，可以实现上下标功能，即设置当前文本向上偏移，减少字体大小，即可
    case stroken        = 4 // 描边
    case shadow         = 5 // 阴影
    case expansion      = 6 // 拉伸
    case paragraph      = 7 // 段落
    case link           = 8      // 链接（附件）
    case tabStyle       = 9 // 列表
    case quote          = 10 // 引用
}
/// 所涉及到的属性配置
@objc public enum RZTextViewFontStyle : NSInteger {
    case none                                  = 1   //
    case bold                                  = 2   // 粗体
    case oblique                               = 3   // 斜体
    case underline                             = 4   // 下划线
    case deleteLine                            = 5   // 删除线
    case fontSize                              = 6   // 字体size
    case fontColor                             = 7   // 字体颜色
    case fontBackgroundColor                   = 8   // 字体所在背景色
    case baseOfline                            = 9   // 偏移
    case stroken                               = 10   // 描边
    case shadow                                = 11   // 阴影
    case expansion                             = 12    // 拉伸
    case paragraphAlignment                    = 13   // 对齐方式
    case paragraphlineMultiple                 = 14   // 多倍行距
    case paragraphlineSpace                    = 15   // 固定行距
    case paragraphspace                        = 16   // 段间距
    case paragraphspaceBefore                  = 17   // 段后间距
    case paragraphFirstLineHeadIndent          = 18   //文本首行缩进
    case paragraphHeadIndent                   = 19   //非首行缩进
    case paragraphTailIndent                   = 20   //整体缩进
    case linkAttachment                        = 21   // 链接 附件
    case tabStyle                              = 22   // 列表
}

/// 配置工具条，及相关的属性功能
@objcMembers
open class RZRichTextViewOptions: NSObject {
    /// 默认使用单例
    public static var shared: RZRichTextViewOptions = .init()
    
    /// 正常字体
    open var normalFont: UIFont = .systemFont(ofSize: 17)
    /// 斜体，系统本身的斜体字，不支持中文斜体，所以如果有设置斜体，需要自己添加一个斜体字库（demo里有可参考，版权问题需自行处理）
    open var obliqueFont: UIFont = UIFont.italicSystemFont(ofSize: 17)
    /// 粗体
    open var boldFont: UIFont = .boldSystemFont(ofSize: 17)
    /// 粗斜体 ，不支持中文斜体，所以如果有设置粗斜体，需要自己添加一个粗斜体字库（demo里有可参考，版权问题需自行处理）
    open var boldObliqueFont: UIFont = .boldSystemFont(ofSize: 17)
    /// 是否支持(有序、无序)列表功能，当支持时，在changeRaneg, text改变时，将会在列表文本处理一些复杂任务，比如增删序号
    /// 如果为false，需要移除toolbarItems里的RZTextViewToolbarItem.tabStyle的item
    open var enableTabStyle = true
    /// 在输入的时候，是否删除textView.typingAttributes里的link属性，默认为true, 输入时无link属性
    /// false时，光标在link之外的地方，或者范围过界，则无link，也就是可以直接修改link的文本
    open var shouldRemoveLinkWhenEditing = true
    ///  rgba 设定可选颜色 
    open var colors: [RZRichColor] = [
        .init(0, 0, 0, 0),
        .init(0, 0, 0, 1),
        .init(51, 51, 51, 1),
        .init(102, 102, 102, 1),
        .init(153, 153, 153, 1),
        .init(204, 204, 204, 1),
        .init(238, 238, 238, 1),
        .init(255, 255, 255, 1),
        .init(130, 60, 20, 1),
        .init(252, 13, 27, 1),
        .init(251, 104, 104, 1),
        .init(255, 127, 34, 1),
        .init(255, 209, 103, 1),
        .init(255, 255, 59, 1),
        .init(230, 250, 74, 1),
        .init(84, 128, 57, 1),
        .init(41, 255, 49, 1),
        .init(109, 249, 127, 1),
        .init(11, 36, 246, 1),
        .init(55, 157, 255, 1),
        .init(153, 38, 255, 1),
        .init(120, 100, 200, 1),
    ]
    /// 可以自行修改图片
    open var icon_image: UIImage? = RZRichTextImage.imageWith(name: "rz_image") // 工具条 图片
    open var icon_font: UIImage? = RZRichTextImage.imageWith(name: "rz_font")     // // 字体
    open var icon_endEdit: UIImage? =  RZRichTextImage.imageWith(name: "rz_endEdit") // 关闭键盘
    open var icon_baseofline: UIImage? =  RZRichTextImage.imageWith(name: "rz_baseofline") // 偏移
    open var icon_stroken: UIImage? =  RZRichTextImage.imageWith(name: "rz_stroken") // 描边
    open var icon_shadow: UIImage? =  RZRichTextImage.imageWith(name: "rz_shadow") //  阴影
    open var icon_expansion: UIImage? =  RZRichTextImage.imageWith(name: "rz_extension") // 扩展
    open var icon_dqdefault: UIImage? =  RZRichTextImage.imageWith(name: "rz_dq_default") // 对齐 默认
    open var icon_dqleft: UIImage? =  RZRichTextImage.imageWith(name: "rz_dq_left") //   对齐 居左
    open var icon_dqcenter: UIImage? =  RZRichTextImage.imageWith(name: "rz_dq_center") // 对齐 居中
    open var icon_dqright: UIImage? =  RZRichTextImage.imageWith(name: "rz_dq_right") // 对齐 居右
    open var icon_paragraph: UIImage? =  RZRichTextImage.imageWith(name: "rz_paragraphy") // 段落
    open var icon_link: UIImage? =  RZRichTextImage.imageWith(name: "rz_fujian") //     链接
    open var icon_attachment: UIImage? =  RZRichTextImage.imageWith(name: "rz_fujian_add") // 附件
    open var icon_revoke: UIImage? =  RZRichTextImage.imageWith(name: "rz_revoke") // 撤销 亮
    open var icon_revokeEnable: UIImage? =  RZRichTextImage.imageWith(name: "rz_revoke_enable") // 撤销 暗
    open var icon_restore: UIImage? =  RZRichTextImage.imageWith(name: "rz_restore") // 恢复 亮
    open var icon_restoreEnable: UIImage? =  RZRichTextImage.imageWith(name: "rz_restore_enable") // 恢复 暗
    open var icon_delete: UIImage? =  RZRichTextImage.imageWith(name: "rz_delete") // 删除按钮
    open var icon_tab: UIImage? =  RZRichTextImage.imageWith(name: "rz_liebiao") // 列表
    open var icon_wuxu: UIImage? =  RZRichTextImage.imageWith(name: "rz_wuxu") // 无序列表
    open var icon_youxu: UIImage? =  RZRichTextImage.imageWith(name: "rz_youxu") // 有序列表
    open var icon_quote: UIImage? = RZRichTextImage.imageWith(name: "rz_quote")     // 引用
    open var icon_quote_s: UIImage? = RZRichTextImage.imageWith(name: "rz_quote_s")     // 引用 高亮
    /// 键盘上显示的工具条条目
    open lazy var toolbarItems: [RZToolBarItem] = [
        .init(type: RZTextViewToolbarItem.image.rawValue, image: icon_image), // 插入图片
        .init(type: RZTextViewToolbarItem.font.rawValue, image: icon_font, items: fontStyleItems), // 文本设置
        .init(type: RZTextViewToolbarItem.quote.rawValue, image: icon_quote, selectedImage: icon_quote_s), // 引用
        .init(type: RZTextViewToolbarItem.tabStyle.rawValue, image: icon_tab, items: tabStyleItems), // 列表
        .init(type: RZTextViewToolbarItem.baseOfline.rawValue, image: icon_baseofline, items: baseoflineItems), // 偏移设置
        .init(type: RZTextViewToolbarItem.stroken.rawValue, image: icon_stroken, items: strokenItems), // 描边设置
        .init(type: RZTextViewToolbarItem.shadow.rawValue, image: icon_shadow, items: shadowItems), // 阴影设置
        .init(type: RZTextViewToolbarItem.expansion.rawValue, image: icon_expansion, items: expansionItems), // 拉伸设置
        .init(type: RZTextViewToolbarItem.paragraph.rawValue, image: icon_paragraph, items: paragraphItems), // 段落设置
        .init(type: RZTextViewToolbarItem.link.rawValue, image: icon_link, items: linkItems), // 链接
        
    ]
    // 字体样式设置
    open lazy var fontStyleItems: [NSInteger] = [
        RZTextViewFontStyle.bold.rawValue, RZTextViewFontStyle.oblique.rawValue, RZTextViewFontStyle.underline.rawValue, RZTextViewFontStyle.deleteLine.rawValue,
        RZTextViewFontStyle.fontSize.rawValue,
        RZTextViewFontStyle.fontColor.rawValue,
        RZTextViewFontStyle.fontBackgroundColor.rawValue,
    ]
    // 偏移量，上下标功能
    open lazy var baseoflineItems: [NSInteger] = [
        RZTextViewFontStyle.baseOfline.rawValue,
        RZTextViewFontStyle.fontSize.rawValue,
        RZTextViewFontStyle.fontColor.rawValue,
        RZTextViewFontStyle.fontBackgroundColor.rawValue,
    ]
    // 描边
    open lazy var strokenItems: [NSInteger] = [
        RZTextViewFontStyle.stroken.rawValue,
    ]
    // 阴影
    open lazy var shadowItems: [NSInteger] = [
        RZTextViewFontStyle.shadow.rawValue,
    ]
    // 拉伸
    open lazy var expansionItems: [NSInteger] = [
        RZTextViewFontStyle.expansion.rawValue,
    ]
    // 段落样式
    open lazy var paragraphItems: [NSInteger] = [
        RZTextViewFontStyle.paragraphAlignment.rawValue,
        RZTextViewFontStyle.paragraphlineMultiple.rawValue,
        RZTextViewFontStyle.paragraphlineSpace.rawValue,
        RZTextViewFontStyle.paragraphspace.rawValue,
//      RZTextViewFontStyle.paragraphspaceBefore.rawValue, // 这个需求不大，也可以加入
        RZTextViewFontStyle.paragraphFirstLineHeadIndent.rawValue,
        RZTextViewFontStyle.paragraphHeadIndent.rawValue,
        RZTextViewFontStyle.paragraphTailIndent.rawValue,
    ]
    // 链接
    open lazy var linkItems: [NSInteger] = [
        RZTextViewFontStyle.linkAttachment.rawValue,
    ]
    // 列表
    open lazy var tabStyleItems: [NSInteger] = [
        RZTextViewFontStyle.tabStyle.rawValue,
    ]
    public override init () {
        super.init()
    }
    /// 工具条要自定义时，可以注册cell identifier
    open var willRegisterAccessoryViewCell: ((UICollectionView) -> Void)?
    /// 键盘上的工具条cell，如果不需要自定义，就不用设置，或者返回nil
    open var accessoryViewCellFor:((UICollectionView, RZToolBarItem, IndexPath) -> UICollectionViewCell?)?
    
    /// 点击了toolbar上的item，return false时，即需自行实现点击事件。。。 默认 return true
    open var didSelectedToolbarItem: ((_ item: RZToolBarItem, _ index: Int) -> Bool)?
    
    /// 将要插入图片时，可对图片进行预处理，然后返回图片
    open var willInsetImage:((UIImage) -> UIImage?)?
    
    /// 插入了一个附件（图片，PHAsset， 视频，等等，可以在maskView上处理一些UI和上传等等操作）
    open var didInsetAttachment:((NSTextAttachment) -> Void)?
    /// 删除了附件之后将会回调
    open var didRemovedAttachment:(([NSTextAttachment]) -> Void)?
    /// 打开相册，去选择图片或者视频,完成之后，返回图片，如果有PHAsset，就返回，图片必须要有，否则无法添加进textView
    open var openPhotoLibrary:((_ complete:@escaping((UIImage?, PHAsset?) -> Void)) -> Void)?
}

class RZRichTextImage {
    class func imageWith(name: String) -> UIImage? {
        let bundle = Bundle.init(for: RZRichTextImage.self)
        guard let url = bundle.url(forResource: "RZRichTextView", withExtension: "bundle") else {
            return nil
        }
        let imagebundle = Bundle.init(url: url)
        
        let fileName = "\(name)@3x"
        var imagePath = imagebundle?.path(forResource: fileName, ofType: "png")
        if let imagePath = imagePath {
            return UIImage.init(contentsOfFile: imagePath)
        }
        imagePath = imagebundle?.path(forResource: "RZRichTextView.bundle/\(fileName)", ofType: "png")
        if let imagePath = imagePath {
            return .init(contentsOfFile: imagePath)
        }
        return nil
    }
}
@objcMembers
open class RZRichColor: NSObject {
    open var r: CGFloat = 0
    open var g: CGFloat = 0
    open var b: CGFloat = 0
    open var a: CGFloat = 0
    public init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    open var color: UIColor {
        return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}
