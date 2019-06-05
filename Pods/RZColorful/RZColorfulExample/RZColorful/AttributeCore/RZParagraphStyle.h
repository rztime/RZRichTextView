//
//  RZParagraphStyle.h
//  RZColorfulExample
//
//  Created by 乄若醉灬 on 2017/7/31.
//  Copyright © 2017年 rztime. All rights reserved.
//

// 段落属性的设置集合


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class RZColorfulAttribute;
@class RZImageAttachment;

#define RZWARNING(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

@interface RZParagraphStyle : NSObject

@property (nonatomic, weak) RZColorfulAttribute *colorfulsAttr  RZWARNING("该属性不可使用，设置富文本属性参照类中block方法内容");
@property (nonatomic, weak) RZImageAttachment *imageAttach RZWARNING("该属性不可使用，设置富文本属性参照类中block方法内容");
- (NSMutableParagraphStyle *)code;

/** 连接词 text、htmlText可使用*/
- (RZColorfulAttribute *)and;
/** 连接词 text、htmlText可使用 */
- (RZColorfulAttribute *)with;
/** 连接词 text、htmlText可使用 */
- (RZColorfulAttribute *)end;

/** 连接词 appendImage、appendImageByUrl可使用*/
- (RZImageAttachment *)andAttach;
/** 连接词 appendImage、appendImageByUrl可使用*/
- (RZImageAttachment *)withAttach;
/** 连接词 appendImage、appendImageByUrl可使用*/
- (RZImageAttachment *)endAttach;
/**
 段落行距
 */
- (RZParagraphStyle *(^)(CGFloat lineSpacing))lineSpacing;

/**
 段与段之间的间距
 */
- (RZParagraphStyle *(^)(CGFloat paragraphSpacingBefore))paragraphSpacingBefore;

/**
 段落后面的间距
 */
- (RZParagraphStyle *(^)(CGFloat paragraphSpacing))paragraphSpacing;

/**
 文本对齐方式
 */
- (RZParagraphStyle *(^)(NSTextAlignment alignment))alignment;

/**
 首行文本缩进
 */
- (RZParagraphStyle *(^)(CGFloat firstLineHeadIndent))firstLineHeadIndent;

/**
 非首行文本缩进
 */
- (RZParagraphStyle *(^)(CGFloat headIndent))headIndent;

/**
 文本缩进
 */
- (RZParagraphStyle *(^)(CGFloat tailIndent))tailIndent;

/**
 文本折行方式
 */
- (RZParagraphStyle *(^)(NSLineBreakMode lineBreakMode))lineBreakMode;

/**
 文本最小行距
 */
- (RZParagraphStyle *(^)(CGFloat minimumLineHeight))minimumLineHeight;

/**
 文本最大行距
 */
- (RZParagraphStyle *(^)(CGFloat maximumLineHeight))maximumLineHeight;

/**
 文本写入方式，即显示方式，从左至右，或从右到左
 */
- (RZParagraphStyle *(^)(NSWritingDirection baseWritingDirection))baseWritingDirection;

/**
 设置文本行间距是默认间距的倍数
 */
- (RZParagraphStyle *(^)(CGFloat lineHeightMultiple))lineHeightMultiple;

/**
 设置每行的最后单词是否截断，在0.0-1.0之间，默认为0.0，越接近1.0单词被截断的可能性越大，
 */
- (RZParagraphStyle *(^)(float hyphenationFactor))hyphenationFactor;

/**
 未知
 */
- (RZParagraphStyle *(^)(CGFloat defaultTabInterval))defaultTabInterval NS_AVAILABLE(10_0, 7_0);

/**
 未知
 */
- (RZParagraphStyle *(^)(BOOL allowsDefaultTighteningForTruncation))allowsDefaultTighteningForTruncation NS_AVAILABLE(10_11, 9_0);


@end
