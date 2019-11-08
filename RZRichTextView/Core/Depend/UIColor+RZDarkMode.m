//
//  UIColor+RZDarkMode.m
//  RZRichTextView
//
//  Created by xk_mac_mini on 2019/11/7.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "UIColor+RZDarkMode.h"

@implementation UIColor (RZDarkMode)

+ (UIColor * (^ __nullable)(UIColor * __nullable defColor, UIColor * __nullable darkModeColor))rz_colorCreater {
    return ^ id (UIColor * __nullable defColor, UIColor * __nullable darkModeColor) {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
             return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle  == UIUserInterfaceStyleDark) {
                    return darkModeColor;
                } else {
                    return defColor;
                }
            }];
        } else
        #endif
        { // Fallback on earlier versions
        #if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            return defColor;
        #endif
        }
    };
}
+ (UIColor * (^ __nullable)(RZUserInterfaceStyle style, UIColor * __nullable defColor, UIColor * __nullable darkModeColor))rz_colorCreaterStyle {
    return ^ id (RZUserInterfaceStyle style, UIColor * __nullable defColor, UIColor * __nullable darkModeColor) {
        if (style == RZUserInterfaceStyleLight) {
            return defColor;
        }
        if (style == RZUserInterfaceStyleDark) {
            return darkModeColor;
        }
        return self.rz_colorCreater(defColor, darkModeColor);
    };
}
@end
