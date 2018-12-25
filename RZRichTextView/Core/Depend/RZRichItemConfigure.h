//
//  RZRichItemConfigure.h
//  RZRichTextView
//
//  Created by Admin on 2018/12/20.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RZRichItemConfigure : NSObject
// 字体
+ (NSInteger)fontSizeCount;
+ (NSNumber *)fontSizeByIndex:(NSInteger)index;
+ (NSInteger)indexByFontSize:(NSInteger)fontsize;
// 颜色
+ (NSInteger)colorCount;
+ (UIColor *)colorByIndex:(NSInteger)index;
+ (NSInteger)indexByColor:(UIColor *)color;
// 对齐方式
+ (NSInteger)aligmentCount;
+ (UIImage *)aligmentByIndex:(NSInteger)index;
+ (NSInteger)indexByAligment:(NSTextAlignment)aligment;
// 其他数字
+ (NSInteger)numberCount;
+ (NSInteger)numberByIndex:(NSInteger)index;
+ (NSInteger)indexBynumber:(NSInteger)number;
@end

NS_ASSUME_NONNULL_END
