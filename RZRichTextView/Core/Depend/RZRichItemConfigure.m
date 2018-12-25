//
//  RZRichItemConfigure.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/20.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichItemConfigure.h"

@interface RZRichItemConfigure ()

@property (nonatomic, strong) NSArray *colors;

@end

@implementation RZRichItemConfigure

+ (instancetype)shareManager {
    static RZRichItemConfigure *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RZRichItemConfigure alloc] init];
    });
    return manager;
}
+ (NSInteger)fontSizeCount {
    return 90;
}
+ (NSNumber *)fontSizeByIndex:(NSInteger)index {
    return @(10+index);
}

+ (NSInteger)indexByFontSize:(NSInteger)fontsize {
    return fontsize -10;
}
 
+ (NSInteger)colorCount {
    return 35;
}
+ (UIColor *)colorByIndex:(NSInteger)index {
    NSInteger r = 0;
    NSInteger g = 0;
    NSInteger b = 0;
    
    if (index < 5) {
        r = g = b = 51 * index;
    } else if (index < 10) {
        r = (index- 4) * 51;
    } else if (index < 15) {
        g = (index - 9) * 51;
    } else if (index < 20) {
        b = (index - 14) * 51;
    } else if (index < 25) {
        r = g = (index - 19) * 51;
    } else if (index < 30) {
        g = b = (index - 24) * 51;
    }  else if (index < 35) {
        r = b = (index - 29) * 51;
    }
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

- (NSArray *)colors {
    if (_colors) {
        return _colors;
    }
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < 35; i++) {
        UIColor *color = [RZRichItemConfigure colorByIndex:i];
        [array addObject:color];
    }
    _colors = array.copy;
    return _colors;
}

+ (NSInteger)indexByColor:(UIColor *)color {
    if (!color) {
        return 0;
    }
    __block NSInteger index = 0;
    NSArray *colors = [RZRichItemConfigure shareManager].colors;
    [colors enumerateObjectsUsingBlock:^(UIColor *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGColorEqualToColor(obj.CGColor, color.CGColor)) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

+ (NSInteger)aligmentCount {
    return 3;
}
+ (UIImage *)aligmentByIndex:(NSInteger)index {
    NSArray *images = @[[UIImage imageNamed:@"RZRichResource.bundle/左对齐"],
                        [UIImage imageNamed:@"RZRichResource.bundle/中对齐"],
                        [UIImage imageNamed:@"RZRichResource.bundle/右对齐"]];
    return images[index];
}
+ (NSInteger)indexByAligment:(NSTextAlignment)aligment {
    switch (aligment) {
        case NSTextAlignmentLeft:
            return 0;
        case NSTextAlignmentCenter:
            return 1;
        case NSTextAlignmentRight:
            return 2;
        default:
            break;
    }
    return 0;
}

+ (NSInteger)numberCount {
    return 15;
}
+ (NSInteger)numberByIndex:(NSInteger)index {
    return -7 + index;
}
+ (NSInteger)indexBynumber:(NSInteger)number {
    return number + 7;
}
@end
