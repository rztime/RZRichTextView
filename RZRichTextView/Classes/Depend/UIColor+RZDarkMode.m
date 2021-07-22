//
//  UIColor+RZDarkMode.m
//  RZRichTextView
//
//  Created by xk_mac_mini on 2019/11/7.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "UIColor+RZDarkMode.h"
#import <objc/runtime.h>

@implementation UIColor (RZDarkMode)

- (void)setRz_defColor:(UIColor *)rz_defColor {
    objc_setAssociatedObject(self, @"rz_defColor", rz_defColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)rz_defColor {
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    UIColor *color = objc_getAssociatedObject(self, @"rz_defColor");
    if (!color) {
        return self;
    }
    return color;
    #endif
    return self;
}

- (void)setRz_darkModeColor:(UIColor *)rz_darkModeColor {
    objc_setAssociatedObject(self, @"rz_darkModeColor", rz_darkModeColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)rz_darkModeColor {
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    UIColor *color = objc_getAssociatedObject(self, @"rz_darkModeColor");
    if (!color) {
        return self;
    }
    return color;
    #endif
    return self;
}

+ (UIColor * (^ __nullable)(UIColor * __nullable defColor, UIColor * __nullable darkModeColor))rz_colorCreater {
    return ^ id (UIColor * __nullable defColor, UIColor * __nullable darkModeColor) {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
             UIColor *color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle  == UIUserInterfaceStyleDark) {
                    return darkModeColor;
                } else {
                    return defColor;
                }
            }];
            color.rz_defColor = defColor;
            color.rz_darkModeColor = darkModeColor;
            return color;
        } else
        #endif
        { // Fallback on earlier versions
        #if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            UIColor *color = defColor.copy;
            color.rz_defColor = defColor;
            color.rz_darkModeColor = darkModeColor;
            return color;
        #endif
        }
    };
}

+ (UIColor * (^ __nullable)(RZUserInterfaceStyle style, UIColor * __nullable defColor, UIColor * __nullable darkModeColor))rz_colorCreaterStyle {
    return ^ id (RZUserInterfaceStyle style, UIColor * __nullable defColor, UIColor * __nullable darkModeColor) {
        UIColor *color;
        if (style == RZUserInterfaceStyleLight) {
            color = defColor.copy;
        }
        if (style == RZUserInterfaceStyleDark) {
            color = darkModeColor.copy;
        }
        if (color) {
            color.rz_defColor = defColor;
            color.rz_darkModeColor = darkModeColor;
            return color;
        }
        return self.rz_colorCreater(defColor, darkModeColor);
    };
}
@end
