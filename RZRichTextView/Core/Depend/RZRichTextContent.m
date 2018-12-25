//
//  RZRichTextContent.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichTextContent.h"
#import <RZColorful/RZColorful.h> 
#import "UIView+RZFrame.h"

@implementation RZRichTextContent

- (instancetype)init {
    if (self = [super init]) {
        _rz_bold = NO;
        _rz_italic = NO;
        _rz_underLine = NO;
        _rz_strikethrough = NO;
        _rz_fontSize = 17;
        _rz_aligment = NSTextAlignmentLeft;
        _rz_mark = RZRichTextContentMark_Defaule;
        
        _rz_stroke = NO;
        _rz_expansion = 0;
        _rz_shadown = NO;
        
        _rz_wordSpace = 0;
        
        _rz_textColor = [UIColor blackColor];
        _rz_textBackgroundColor = nil;
        
        _rz_strokeColor = [UIColor blackColor];
        _rz_strokeWidth = 0;
        
        _rz_shadownColor = [UIColor blackColor];
        _rz_shadownOffsetX = 1;
        _rz_shadownOffsetY = 1;
        _rz_shadownRadius = 1;
    }
    return self;
}

// 将文字按照配置的样式变成富文本
- (NSAttributedString *)rz_factoryByString:(NSString *)text {
    if (text.length == 0) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    NSAttributedString *attrString = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer *confer) {
        RZColorfulAttribute *attr = confer.text(text);
        CGFloat fontsize = weakSelf.rz_fontSize;
        if (weakSelf.rz_mark == RZRichTextContentMark_Up) {
            fontsize = fontsize / 2.0;
            attr.baselineOffset(@(fontsize));
        } else if (weakSelf.rz_mark == RZRichTextContentMark_Down) {
            fontsize = fontsize / 2.0;
            attr.baselineOffset(@(-fontsize));
        }
        
        if (weakSelf.rz_bold) {
            attr.font([UIFont boldSystemFontOfSize:fontsize]);
        } else {
            attr.font([UIFont systemFontOfSize:fontsize]);
        }
        attr.textColor(weakSelf.rz_textColor);
        if (weakSelf.rz_textBackgroundColor) {
            attr.backgroundColor(weakSelf.rz_textBackgroundColor);
        }
        
        if (weakSelf.rz_italic) {
            attr.italic(@0.3);
        }
        
        if (weakSelf.rz_underLine) {
            attr.underLineStyle(MAX(1, fontsize/25)).underLineColor(weakSelf.rz_textColor);
        }
        if (weakSelf.rz_strikethrough) {
            attr.strikeThrough(MAX(1, fontsize/25)).strikeThroughColor(weakSelf.rz_textColor);
        }
        attr.wordSpace(@(weakSelf.rz_wordSpace));
        attr.paragraphStyle.alignment(weakSelf.rz_aligment);
        
        if (weakSelf.rz_stroke) {
            attr.strokeWidth(@(weakSelf.rz_strokeWidth)).strokeColor(weakSelf.rz_strokeColor);
        }
        if (weakSelf.rz_expansion) {
            attr.expansion(@(weakSelf.rz_expansionValue/10.f));
        }
        if (weakSelf.rz_shadown) {
            attr.shadow.offset(CGSizeMake(weakSelf.rz_shadownOffsetX, weakSelf.rz_shadownOffsetY)).color(weakSelf.rz_shadownColor).radius((MAX(1, weakSelf.rz_shadownRadius * fontsize/10.f)));
        }
    }];
    return attrString.copy;
}

@end
