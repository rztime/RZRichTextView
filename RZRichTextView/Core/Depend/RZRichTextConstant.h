//
//  RZRichTextConstant.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/21.
//  Copyright © 2019 Rztime. All rights reserved.
//

#ifndef RZRichTextConstant_h
#define RZRichTextConstant_h

typedef NS_ENUM(NSInteger, RZRichTextAttributeType) {
    RZRichTextAttributeTypeNone         = 0,  //
    RZRichTextAttributeTypeAttachment   = 1,  // 图片附件
    RZRichTextAttributeTypeRevoke       = 2,  // 撤销
    RZRichTextAttributeTypeRestore      = 3,  // 还原（恢复）
    RZRichTextAttributeTypeFontSize     = 4,  // 字体大小
    RZRichTextAttributeTypeFontColor    = 5,  // 字体颜色
    RZRichTextAttributeTypeFontBackgroundColor = 6, // 字体所在背景颜色
    RZRichTextAttributeTypeBold         = 7,  // 粗体
    RZRichTextAttributeTypeItalic       = 8,  // 斜体
    RZRichTextAttributeTypeUnderline    = 9,  // 下划线
    RZRichTextAttributeTypeStrikeThrough = 10, // 删除线
    RZRichTextAttributeTypeMarkUp       = 11,  // 上标
    RZRichTextAttributeTypeMarkDown     = 12,  // 下标
    RZRichTextAttributeTypeAligment     = 13,  // 对齐方式
    RZRichTextAttributeTypeParagraph    = 14,  // 段落样式
    RZRichTextAttributeTypeStroke       = 15,  // 描边
    RZRichTextAttributeTypeExpansion    = 16,  // 拉伸
    RZRichTextAttributeTypeShadown      = 17,  // 阴影
    RZRichTextAttributeTypeURL          = 18,  // 链接
    RZRichTextAttributeTypeEndEdit      = 19,  // 结束编辑
};

typedef NS_ENUM(NSInteger, RZRichAlertViewType) {
    
    RZRichAlertViewTypeList = 0, // 列表模式 （tableview样式）
    RZRichAlertViewTypeGrid = 1, // 格子样式 (collerctionview样式)
};

#define k_rz_richImage(name) [UIImage imageNamed:[NSString stringWithFormat:@"RZRichResource.bundle/%@", name]]

#define rz_rgba(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define rz_rgb(r, g, b) rz_rgba(r, g, b, 1)

#define rz_k_screen_width (UIScreen.mainScreen.bounds.size.width)
#define rz_k_screen_height (UIScreen.mainScreen.bounds.size.height)

#define rz_weakObj(obj)     __weak typeof(obj) obj##Weak = obj;

#define rz_font(size) [UIFont systemFontOfSize:size]
#define rz_fontBold(size) [UIFont boldSystemFontOfSize:size]

// 是否是iPhone X
#define rz_iPhoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))
// 是否是iPhone XR
#define rz_iPhoneXR (CGSizeEqualToSize(CGSizeMake(414.f, 896.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(896.f, 414.f), [UIScreen mainScreen].bounds.size))
// 是否有刘海屏
#define rz_iPhone_liuhai (rz_iPhoneX || rz_iPhoneXR)
// 底部安全边距
#define rz_kSafeBottomMargin (rz_iPhone_liuhai ? 34.f: 0.f)

#endif /* RZRichTextConstant_h */
