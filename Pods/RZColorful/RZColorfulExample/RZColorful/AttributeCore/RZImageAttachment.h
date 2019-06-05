//
//  RZImageAttachment.h
//  RZColorfulExample
//
//  Created by 乄若醉灬 on 2017/7/28.
//  Copyright © 2017年 rztime. All rights reserved.
//
// 仅添加图片的附件
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RZParagraphStyle.h"
#import "RZShadow.h"

#define RZWARNING(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

@interface RZImageAttachment : NSObject

@property (nonatomic, assign) CGRect imageBounds RZWARNING("该属性不可使用，请使用bounds(CGRectMake(...))方法");

@property (nonatomic, assign, readonly) BOOL hadParagraphStyle;
@property (nonatomic, assign, readonly) BOOL hadShadow;
- (NSDictionary *)code;

/**
 将bounds数据转换成html格式的语句 
 */
- (NSString *)toHTMLStringWithImageUrl:(NSString *)imageUrl;

#pragma mark - 可以设置的属性

/**
 段落样式
 */
- (RZParagraphStyle *)paragraphStyle;

/**
 阴影
 */
- (RZShadow *)shadow;
/**
  设置图片bounds时,origin.x 设置无效 size.width height 可以设置与前后排文字字体大小一样，且适当调整origin.y为负值，可以让图片文本对齐
 如果是通过url设置bounds时，宽设置为0：则宽按照高度自动等比显示，高设置为0亦如此
 
 */
- (RZImageAttachment *(^)(CGRect bounds))bounds;

/** 给图片添加链接，要实现点击，需实现UITextView的delegate的url点击事件 */
- (RZImageAttachment *(^)(NSURL *url))url;
@end
