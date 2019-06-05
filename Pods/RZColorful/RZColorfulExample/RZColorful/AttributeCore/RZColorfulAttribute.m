//
//  RZAttribute.m
//  RZAttributedStringText
//
//  Created by 乄若醉灬 on 2017/7/21.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import "RZColorfulAttribute.h"

@interface RZColorfulAttribute ()

@property (nonatomic, strong) NSMutableDictionary *colorfuls;
@property (nonatomic, strong) RZShadow *shadow;
@property (nonatomic, strong) RZParagraphStyle *paragraphStyle;

@end

@implementation RZColorfulAttribute

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (instancetype)init {
    if (self = [super init]) {
        _colorfuls = [NSMutableDictionary new];
    }
    return self;
}

- (RZColorfulAttribute *)and {
    return self;
}
- (RZColorfulAttribute *)with {
    return self;
}

- (NSDictionary *)code {
    if (_hadShadow) {
        [self.colorfuls setObject:[_shadow code] forKey:NSShadowAttributeName];
    }
    if (_hadParagraphStyle) {
        [self.colorfuls setObject:[_paragraphStyle code] forKey:NSParagraphStyleAttributeName];
    }
    return _colorfuls.copy;
}

/**
 设置文本颜色
 */
- (RZColorfulAttribute * (^) (UIColor *)) textColor {
    __weak typeof(self) weakSelf = self;
    return ^id(UIColor *textColor) {
        weakSelf.colorfuls[NSForegroundColorAttributeName] = textColor;
        return weakSelf;
    };
}

/**
 设置字体
 */
- (RZColorfulAttribute *(^)(UIFont *font))font {
    __weak typeof(self) weakSelf = self;
    return ^id(UIFont *font) {
        if (!font) {
            font = [UIFont systemFontOfSize:17];
        }
        weakSelf.colorfuls[NSFontAttributeName] = font;
        return weakSelf;
    };
}

/**
 设置文字背景颜色
 */
- (RZColorfulAttribute *(^)(UIColor *backgroundColor))backgroundColor {
    __weak typeof(self)weakSelf = self;
    return ^id (UIColor *backgroundColor) {
        weakSelf.colorfuls[NSBackgroundColorAttributeName] = backgroundColor;
        return weakSelf;
    };
}

/**
 设置连体字，value = 0,没有连体， =1，有连体
 */
- (RZColorfulAttribute *(^)(NSNumber *ligature))ligature {
    __weak typeof(self)weakSelf = self;
    return ^id (NSNumber *ligature) {
        weakSelf.colorfuls[NSLigatureAttributeName] = ligature;
        return weakSelf;
    };
}

/**
 字间距 >0 加宽  < 0减小间距
 */
- (RZColorfulAttribute *(^)(NSNumber *wordSpace))wordSpace {
    __weak typeof(self)weakSelf = self;
    return ^id (NSNumber *wordSpace) {
        weakSelf.colorfuls[NSKernAttributeName] = wordSpace;
        return weakSelf;
    };
}

/**
 删除线
 */
- (RZColorfulAttribute *(^)(RZLineStyle strikeThrough))strikeThrough {
    __weak typeof(self)weakSelf = self;
    return ^id (RZLineStyle strikeThrough) {
        weakSelf.colorfuls[NSStrikethroughStyleAttributeName] = @(strikeThrough);
        return weakSelf;
    };
}

/**
 删除线颜色
 */
- (RZColorfulAttribute *(^)(UIColor *strikeThroughColor))strikeThroughColor {
    __weak typeof(self)weakSelf = self;
    return ^id (UIColor *strikeThroughColor) {
        weakSelf.colorfuls[NSStrikethroughColorAttributeName] = strikeThroughColor;
        return weakSelf;
    };
}

/**
 下划线样式
 */
- (RZColorfulAttribute *(^)(RZLineStyle underLineStyle))underLineStyle {
    __weak typeof(self)weakSelf = self;
    return ^id (RZLineStyle underLineStyle) {
        weakSelf.colorfuls[NSUnderlineStyleAttributeName] = @(underLineStyle);
        return weakSelf;
    };
}

/**
 下划线颜色
 */
- (RZColorfulAttribute *(^)(UIColor *underLineColor))underLineColor {
    __weak typeof(self)weakSelf = self;
    return ^id (UIColor *underLineColor) {
        weakSelf.colorfuls[NSUnderlineColorAttributeName] = underLineColor;
        return weakSelf;
    };
}

/**
 描边的颜色
 */
- (RZColorfulAttribute *(^)(UIColor *strokeColor))strokeColor {
    __weak typeof(self)weakSelf = self;
    return ^id (UIColor *strokeColor) {
        weakSelf.colorfuls[NSStrokeColorAttributeName] = strokeColor;
        return weakSelf;
    };
}

/**
 描边的笔画宽度 为3时，空心
 */
- (RZColorfulAttribute *(^)(NSNumber *strokeWidth))strokeWidth {
    __weak typeof(self)weakSelf = self;
    return ^id (NSNumber *strokeWidth) {
        weakSelf.colorfuls[NSStrokeWidthAttributeName] = strokeWidth;
        return weakSelf;
    };
}

/**
 横竖排版 0：横版 1：竖版
 */
- (RZColorfulAttribute *(^)(NSNumber *verticalGlyphForm))verticalGlyphForm {
    __weak typeof(self)weakSelf = self;
    return ^id (NSNumber *verticalGlyphForm) {
        weakSelf.colorfuls[NSVerticalGlyphFormAttributeName] = verticalGlyphForm;
        return weakSelf;
    };
}

/**
 斜体字
 */
- (RZColorfulAttribute *(^)(NSNumber *italic))italic {
    __weak typeof(self)weakSelf = self;
    return ^id (NSNumber *italic) {
        weakSelf.colorfuls[NSObliquenessAttributeName] = italic;
        return weakSelf;
    };
}

/**
 扩张，即拉伸文字 >0 拉伸 <0压缩
 */
- (RZColorfulAttribute *(^)(NSNumber *expansion))expansion {
    __weak typeof(self)weakSelf = self;
    return ^id (NSNumber *expansion) {
        weakSelf.colorfuls[NSExpansionAttributeName] = expansion;
        return weakSelf;
    };
}
/**
 上下标
 */
- (RZColorfulAttribute *(^)(NSNumber *baselineOffset))baselineOffset {
    __weak typeof(self)weakSelf = self;
    return ^id (NSNumber *baselineOffset) {
        weakSelf.colorfuls[NSBaselineOffsetAttributeName] = baselineOffset;
        return weakSelf;
    };
}


/**
 书写方向
 */
- (RZColorfulAttribute *(^)(RZWriteDirection rzwriteDirection))writingDirection {
    __weak typeof(self)weakSelf = self;
    return ^id (RZWriteDirection rzwriteDirection) {
        id value;
        if (rzwriteDirection == RZWDLeftToRight) {
            if (@available(iOS 9.0, *)) {
                value = @[@(NSWritingDirectionLeftToRight | NSWritingDirectionOverride)];
            } else {
                // Fallback on earlier versions
                value = @[@(NSWritingDirectionLeftToRight | NSTextWritingDirectionOverride)];
            }
        } else {
            if (@available(iOS 9.0, *)) {
                value = @[@(NSWritingDirectionRightToLeft | NSWritingDirectionOverride)];
            } else {
                // Fallback on earlier versions
                value = @[@(NSWritingDirectionRightToLeft | NSTextWritingDirectionOverride)];
            }
        }
        weakSelf.colorfuls[NSWritingDirectionAttributeName] = value;
        return weakSelf;
    };
}
/**
 给文本添加链接，并且可点击跳转浏览器打开
 */
- (RZColorfulAttribute *(^)(NSURL *url))url {
    __weak typeof(self)weakSelf = self;
    return ^id (NSURL *url) { 
        weakSelf.colorfuls[NSLinkAttributeName] = url;
        return weakSelf;
    };
}

// 阴影
- (RZShadow *)shadow {
    if (!_shadow) {
        _shadow = [[RZShadow alloc] init];
        _shadow.colorfulsAttr = self;
        _hadShadow = YES;
    }
    return _shadow;
}


/**
 段落样式，具体设置请看 RZParagraphStyle.h

 @return <#return value description#>
 */
- (RZParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[RZParagraphStyle alloc]init];
        _paragraphStyle.colorfulsAttr = self;
        _hadParagraphStyle = YES;
    }
    return _paragraphStyle;
}
#pragma clang diagnostic pop
@end
