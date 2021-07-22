//
//  UIColor+RZDarkMode.h
//  RZRichTextView
//
//  Created by xk_mac_mini on 2019/11/7.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RZUserInterfaceStyle) {
    RZUserInterfaceStyleUnspecified,
    RZUserInterfaceStyleLight,
    RZUserInterfaceStyleDark,
};

@interface UIColor (RZDarkMode)

/* 默认颜色（light模式） */
@property (nonatomic, strong) UIColor *rz_defColor;
/** 暗黑颜色 */
@property (nonatomic, strong) UIColor *rz_darkModeColor;

+ (UIColor * (^ __nullable)(UIColor * __nullable defColor, UIColor * __nullable darkModeColor))rz_colorCreater;

+ (UIColor * (^ __nullable)(RZUserInterfaceStyle style, UIColor * __nullable defColor, UIColor * __nullable darkModeColor))rz_colorCreaterStyle;

@end

NS_ASSUME_NONNULL_END
