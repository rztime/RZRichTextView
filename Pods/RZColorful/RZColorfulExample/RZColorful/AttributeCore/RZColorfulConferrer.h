//
//  RZAttributedMaker.h
//  RZAttributedStringText
//
//  Created by 乄若醉灬 on 2017/7/21.
//  Copyright © 2017年 rztime. All rights reserved.
//
// 富文本的控制集合

#import <Foundation/Foundation.h>
#import "RZImageAttachment.h"
#import "RZColorfulAttribute.h"

typedef NS_ENUM(NSInteger, rzConferInsertPosition) {
    rzConferInsertPositionDefault = 0,  // 默认位置 默认加到光标处
    rzConferInsertPositionHeader  = 1,  // 加到头部
    rzConferInsertPositionEnd     = 2,  // 加到尾部
    
    rzConferInsertPositionCursor  = 4,  // 加到光标处
};

#define RZWARNING(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

NS_ASSUME_NONNULL_BEGIN

@interface RZColorfulConferrer : NSObject

- (NSAttributedString *)confer RZWARNING("请勿使用及修改此方法, 具体设置请参照RZColorfulConferrer的其他属性");


/**
 普通文本内容 要设置其属性，使用"."语法直接连接属性，属性参考RZColorfulAttribute.h
 如: confer.text(@"内容").textColor([UIColor redColor]).font(FONT(16)); 即设置 “内容”显示为红色,16号字体
 text.之后的属性，仅对当前text()内容有效
 */
- (RZColorfulAttribute *(^)(NSString * _Nullable text))text;


/**
 添加html格式的内容(网页源码)，会通过将源码转换成普通文本内容
 */
- (RZColorfulAttribute *(^)(NSString * _Nullable htmlText))htmlText;


/**
 添加图片，为使图片与前后排文字对齐，可设置其bounds的size高度和文字大小一样。且origin.y适当的取负值，即可对齐
 设置图片bounds时,origin.x 设置无效
 */
- (RZImageAttachment *(^)(UIImage * _Nullable appendImage))appendImage;

/**
 通过url添加图片
 */
- (RZImageAttachment *(^)(NSString * _Nullable imageUrl))appendImageByUrl;
/**
 设置当前控件对象统一段落样式, 这里设置段落之后，请勿使用and等连接词
 在text中设置了段落样式，则text的段落样式优先级高于统一段落样式
 */
- (RZParagraphStyle * _Nullable)paragraphStyle;

/**
 设置统一阴影对象 , 请勿使用and等连接词
  在text中设置了阴影样式，则text的阴影样式优先级高于统一阴影样式
 @return <#return value description#>
 */
- (RZShadow * _Nullable)shadow;

@end
NS_ASSUME_NONNULL_END
