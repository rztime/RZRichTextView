//
//  RZShadow.h
//  RZColorfulExample
//
//  Created by 乄若醉灬 on 2017/7/28.
//  Copyright © 2017年 rztime. All rights reserved.
//

// 阴影的设置集合

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class RZColorfulAttribute;
@class RZImageAttachment;

#define RZWARNING(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)


@interface RZShadow : NSObject

@property (nonatomic, weak) RZColorfulAttribute *colorfulsAttr RZWARNING("该属性不可使用，设置富文本属性参照类中block方法内容");
@property (nonatomic, weak) RZImageAttachment *imageAttach RZWARNING("该属性不可使用，设置富文本属性参照类中block方法内容");

- (NSShadow *)code;

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
 阴影偏移量
 */
- (RZShadow *(^)(CGSize offset))offset;

/**
 // blur radius of the shadow in default user space units
 // 值越大，越模糊
 */
- (RZShadow *(^)(CGFloat radius))radius;

/**
 阴影颜色
 */
- (RZShadow *(^)(UIColor *color))color;

@end
