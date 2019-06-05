//
//  RZParagraphStyle.m
//  RZColorfulExample
//
//  Created by 乄若醉灬 on 2017/7/31.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import "RZParagraphStyle.h"
#import "RZColorfulAttribute.h"

@interface RZParagraphStyle ()

@property (nonatomic, strong) NSMutableParagraphStyle *paragraph;

@end

@implementation RZParagraphStyle

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


- (RZColorfulAttribute *)and {
    return _colorfulsAttr;
}
- (RZColorfulAttribute *)with {
    return _colorfulsAttr;
}
- (RZColorfulAttribute *)end {
    return _colorfulsAttr;
}

/**
 连接词 如果阴影设置完毕，还想继续设置其他图片附件的信息，请使用andAttach，withAttach，endAttach，之后可以连接设置其他属性
 
 @return <#return value description#>
 */
- (RZImageAttachment *)andAttach {
    return _imageAttach;
}
- (RZImageAttachment *)withAttach {
    return _imageAttach;
}
- (RZImageAttachment *)endAttach {
    return _imageAttach;
}
- (NSMutableParagraphStyle *)code {
    return _paragraph;
}

- (NSMutableParagraphStyle *)paragraph {
    if (!_paragraph) {
        _paragraph = [[NSMutableParagraphStyle alloc] init]; 
    }
    return _paragraph;
}

- (RZParagraphStyle *(^)(CGFloat lineSpacing))lineSpacing {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat lineSpacing) {
        weakSelf.paragraph.lineSpacing = lineSpacing;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat paragraphSpacing))paragraphSpacing {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat paragraphSpacing) {
        weakSelf.paragraph.paragraphSpacing = paragraphSpacing;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(NSTextAlignment alignment))alignment {
    __weak typeof(self)weakSelf = self;
    return ^id (NSTextAlignment alignment) {
        weakSelf.paragraph.alignment = alignment;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat firstLineHeadIndent))firstLineHeadIndent {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat firstLineHeadIndent) {
        weakSelf.paragraph.firstLineHeadIndent = firstLineHeadIndent;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat headIndent))headIndent {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat headIndent) {
        weakSelf.paragraph.headIndent = headIndent;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat tailIndent))tailIndent {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat tailIndent) {
        weakSelf.paragraph.tailIndent = tailIndent;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(NSLineBreakMode lineBreakMode))lineBreakMode {
    __weak typeof(self)weakSelf = self;
    return ^id (NSLineBreakMode lineBreakMode) {
        weakSelf.paragraph.lineBreakMode = lineBreakMode;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat minimumLineHeight))minimumLineHeight {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat minimumLineHeight) {
        weakSelf.paragraph.minimumLineHeight = minimumLineHeight;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat maximumLineHeight))maximumLineHeight {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat maximumLineHeight) {
        weakSelf.paragraph.maximumLineHeight = maximumLineHeight;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(NSWritingDirection baseWritingDirection))baseWritingDirection {
    __weak typeof(self)weakSelf = self;
    return ^id (NSWritingDirection baseWritingDirection) {
        weakSelf.paragraph.baseWritingDirection = baseWritingDirection;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat lineHeightMultiple))lineHeightMultiple {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat lineHeightMultiple) {
        weakSelf.paragraph.lineHeightMultiple = lineHeightMultiple;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat paragraphSpacingBefore))paragraphSpacingBefore {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat paragraphSpacingBefore) {
        weakSelf.paragraph.paragraphSpacingBefore = paragraphSpacingBefore;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(float hyphenationFactor))hyphenationFactor {
    __weak typeof(self)weakSelf = self;
    return ^id (float hyphenationFactor) {
        weakSelf.paragraph.hyphenationFactor = hyphenationFactor;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(CGFloat defaultTabInterval))defaultTabInterval {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat defaultTabInterval) {
        weakSelf.paragraph.defaultTabInterval = defaultTabInterval;
        return weakSelf;
    };
}

- (RZParagraphStyle *(^)(BOOL allowsDefaultTighteningForTruncation))allowsDefaultTighteningForTruncation {
    __weak typeof(self)weakSelf = self;
    return ^id (BOOL allowsDefaultTighteningForTruncation) {
        weakSelf.paragraph.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation;
        return weakSelf;
    };
}

#pragma clang diagnostic pop

@end
