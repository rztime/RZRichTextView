//
//  RZRichText.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichText.h"
#import <RZColorful/RZColorful.h>
#import "RZDefine.h"

@interface RZRichText()

@property (nonatomic, strong) NSDictionary<NSAttributedStringKey,id> *attrs;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSString *text;

@end

@implementation RZRichText


- (instancetype)init {
    if (self = [super init]) {
        _fontSize = 15;
        _textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _aligment = NSTextAlignmentLeft;
    }
    return self;
}

- (NSAttributedString *)rz_factoryByString:(NSString *)text {
    if (text.length == 0) {
        return nil;
    }
    kWeakSelf;
    NSAttributedString *attr = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer *confer) {
        confer.text(text).font(weakSelf.bold? RZFontBold(weakSelf.fontSize): RZFontNormal(weakSelf.fontSize)).textColor(weakSelf.textColor).italic(weakSelf.italic?@0.3:@0).underLineStyle(weakSelf.underLine?1:0).underLineColor(weakSelf.textColor).strikeThrough(weakSelf.strikethrough?1:0).strikeThroughColor(weakSelf.textColor).paragraphStyle.alignment(weakSelf.aligment);
    }];
    return attr.copy;
}

/**
 获取富文本中的的所有图片
 
 @return 按照图片插入顺序排列
 */
+ (NSArray <UIImage *> *)rz_richTextImagesFormAttributed:(NSAttributedString *)attr {
    NSMutableArray *arrays = [NSMutableArray new];
    [attr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attr.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSTextAttachment class]]) {
            NSTextAttachment *imageMent = value;
            [arrays addObject:imageMent.image];
        }
    }];
    return arrays.copy;
}
/**
 将富文本转成HTML标签
 
 @param attr 富文本
 @param urls 富文本中的图片的url，如果有则传
 @return html标签语言
 */
+ (NSString *)rz_htmlFactoryByAttributedString:(NSAttributedString *)attr imageURLSIfHad:(NSArray <NSString *> *)urls {
    NSMutableAttributedString *tempAttr = attr.mutableCopy;
    // 先转换url
    NSMutableArray *tempUrls = [NSMutableArray new];
    [urls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *img = [NSString stringWithFormat:@"<p style=\"text-align:center;\"> <img style=\"max-width:90%%;height:auto;\" src=\"%@\"> </p>", obj];
        [tempUrls addObject:img];
    }];
    
    // 将URL替换富文本中的图片
    [tempAttr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSTextAttachment class]]) {
            NSString *url = tempUrls.count > 0?[tempUrls lastObject]:nil;
            if (url.length == 0) {
                url = @"<p style=\"text-align:center;\"> <img alt=\"图片缺失\"> </p>";
            }
            [tempAttr replaceCharactersInRange:range withString:url];
            if (tempUrls.count > 0) {
                [tempUrls removeLastObject];
            }
        }
    }];
    // 按照数据不同格式，分区
    NSMutableArray <RZRichText *> *p = [NSMutableArray new];
    [tempAttr enumerateAttributesInRange:NSMakeRange(0, tempAttr.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        RZRichText *helper = [[RZRichText alloc] init];
        helper.attrs = attrs;
        helper.range = range;
        NSString *text = [tempAttr.string substringWithRange:range];
        helper.text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        [p addObject:helper];
    }];
    // 按P分段 分段
    NSMutableArray *paragraphs = [NSMutableArray new];
    __block NSMutableArray *tempP = [NSMutableArray new];
    [p enumerateObjectsUsingBlock:^(RZRichText * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempP addObject:obj];
        if ([obj.text hasSuffix:@"<br/>"]) {
            obj.text = [obj.text substringToIndex:obj.text.length - 5];
            [paragraphs addObject:tempP];
            tempP = [NSMutableArray new];
        }
    }];
    if (tempP.count > 0) {
        [paragraphs addObject:tempP];
    }
    NSMutableArray *texts = [NSMutableArray new];
    [paragraphs enumerateObjectsUsingBlock:^(NSArray *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *spanTexts = [NSMutableArray new];
        if (obj.count > 0) {
            RZRichText *text = obj.firstObject;
            NSParagraphStyle *p = text.attrs[@"NSParagraphStyle"];
            NSTextAlignment algin = p.alignment;
            NSString *alginText;
            if (algin == NSTextAlignmentLeft) {
                alginText = @"left";
            } else if (algin == NSTextAlignmentCenter) {
                alginText = @"center";
            } else if (algin == NSTextAlignmentRight) {
                alginText = @"right";
            }
            [spanTexts addObject:[NSString stringWithFormat:@"<p style=\"text-align: %@;\">", alginText]];
        }
        [obj enumerateObjectsUsingBlock:^(RZRichText * _Nonnull textHelper, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *text = [textHelper richTextToHtml];
            [spanTexts addObject:text];
        }];
        [spanTexts addObject:@"</p>"];
        
        [texts addObject:[spanTexts componentsJoinedByString:@""]];
    }];
    
    return [texts componentsJoinedByString:@" "];
}

- (NSString *)richTextToHtml {
    NSString *tempText = self.text;
    // 斜体
    CGFloat NSObliqueness = [self.attrs[@"NSObliqueness"] floatValue];
    if (NSObliqueness > 0.1) {
        tempText = [NSString stringWithFormat:@"<i>%@</i>", tempText];
    }
    // 下划线
    CGFloat NSUnderline = [self.attrs[@"NSUnderline"] floatValue];
    if (NSUnderline > 0.1) {
        tempText = [NSString stringWithFormat:@"<u>%@</u>", tempText];
    }
    // 删除线
    CGFloat NSStrikethrough = [self.attrs[@"NSStrikethrough"] floatValue];
    if (NSStrikethrough > 0.1) {
        tempText = [NSString stringWithFormat:@"<s>%@</s>", tempText];
    }
    UIFont *font = self.attrs[@"NSFont"];
    NSString *fontDes = font.description;
    if ([fontDes containsString:@"font-weight: bold"]) {
        fontDes = @"bold";
    } else {
        fontDes = @"normal";
    }
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
    UIColor *color = self.attrs[@"NSColor"];
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    NSString *html = [NSString stringWithFormat:@"<span  style=\"font-size: %.0fpx;font-weight: %@; color: rgba(%.0f, %.0f, %.0f, %.1f);\">%@</span>", font.pointSize, fontDes, r*255, g*255, b*255, a, tempText];
    return html;
}
@end
