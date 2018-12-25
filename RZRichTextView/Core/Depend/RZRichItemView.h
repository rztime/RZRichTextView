//
//  RZRichItemView.h
//  RZRichTextView
//
//  Created by Admin on 2018/12/19.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RZRichItemViewType) {
    RZRichItemViewType_none,
    RZRichItemViewType_fontSize, //  字体大小
    RZRichItemViewType_textColor, // 字体颜色
    RZRichItemViewType_textBgColor, // 字体所在区域背景色
    
    RZRichItemViewType_textAligment, // 对齐方式
    
    RZRichItemViewType_stroke, // 描边
    
    RZRichItemViewType_expansion, // 扁平化
    
    RZRichItemViewType_shadow, // 阴影
    RZRichItemViewType_shadowRadius, // 阴影画笔
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^RZRichItemComplete) (id result);

@interface RZRichItemView : UIView

@property (nonatomic, assign) RZRichItemViewType type;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) CGFloat number;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) NSTextAlignment aligment;

@property (nonatomic, copy) RZRichItemComplete complete;


+ (instancetype)initWithColor:(UIColor *)color type:(RZRichItemViewType)type title:(NSString *)title complete:(RZRichItemComplete)complete;

+ (instancetype)initWithAligment:(NSTextAlignment)aligment title:(NSString *)title complete:(RZRichItemComplete)complete;

+ (instancetype)initWithNumber:(CGFloat)number type:(RZRichItemViewType)type title:(NSString *)title complete:(RZRichItemComplete)complete;

+ (instancetype)initWithFuncEnable:(BOOL)enable title:(NSString *)title complete:(RZRichItemComplete)complete;
@end

NS_ASSUME_NONNULL_END
