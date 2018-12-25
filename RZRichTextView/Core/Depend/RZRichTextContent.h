//
//  RZRichTextContent.h
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 支持的功能
 */
typedef NS_ENUM(NSInteger, RZRichTextFunc) {
    RZRichTextFunc_None,
    RZRichTextFunc_image,   // 图片
    RZRichTextFunc_revoke,   // 撤销
    RZRichTextFunc_reagain,   // 恢复
    RZRichTextFunc_bold,   // 粗体
    RZRichTextFunc_italic, // 斜体
    RZRichTextFunc_underLine, // 下划线
    RZRichTextFunc_strikeThrough,  // 删除线
    RZRichTextFunc_font,     // 字体
    RZRichTextFunc_aligment, // 对齐方式
    RZRichTextFunc_markUp,     // 上标记
    RZRichTextFunc_markDwon,     // 下标记
    RZRichTextFunc_stroke,   // 描边
    RZRichTextFunc_expansion, // 拉伸
    RZRichTextFunc_shadown,   // 阴影
    RZRichTextFunc_wordSpace,   // 字间距
    
    RZRichTextFunc_closeEXItemView,  // 关闭扩展的界面
    RZRichTextFunc_closeKeyboard,    // 关闭键盘
};


typedef NS_ENUM(NSInteger, RZRichTextContentMark) {
    RZRichTextContentMark_Defaule, 
    RZRichTextContentMark_Up, // 上标
    RZRichTextContentMark_Down, // 下标
};

@interface RZRichTextContent : NSObject

@property (nonatomic, assign) BOOL rz_bold;   // 粗体

@property (nonatomic, assign) BOOL rz_italic; // 斜体

@property (nonatomic, assign) BOOL rz_underLine; // 下划线

@property (nonatomic, assign) BOOL rz_strikethrough; // 删除线

@property (nonatomic, assign) NSInteger rz_fontSize; // 字体

@property (nonatomic, assign) NSTextAlignment rz_aligment; // 对齐方式

@property (nonatomic, assign) RZRichTextContentMark rz_mark; // 上下标

@property (nonatomic, assign) BOOL rz_stroke; // 描边

@property (nonatomic, assign) BOOL rz_expansion; // 扁平化

@property (nonatomic, assign) BOOL rz_shadown;   // 阴影

@property (nonatomic, assign) NSInteger rz_wordSpace; // 字间距

// 字体颜色
@property (nonatomic, strong) UIColor *rz_textColor; // 字体颜色
@property (nonatomic, strong) UIColor *rz_textBackgroundColor; // 字体背景颜色

// 描边
@property (nonatomic, strong) UIColor *rz_strokeColor;
@property (nonatomic, assign) NSInteger rz_strokeWidth;

@property (nonatomic, assign) CGFloat rz_expansionValue; // 扁平化

// 阴影
@property (nonatomic, strong) UIColor *rz_shadownColor;
@property (nonatomic, assign) NSInteger rz_shadownOffsetX;
@property (nonatomic, assign) NSInteger rz_shadownOffsetY;
@property (nonatomic, assign) NSInteger rz_shadownRadius;

// 将文字按照配置的样式变成富文本
- (NSAttributedString *)rz_factoryByString:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
