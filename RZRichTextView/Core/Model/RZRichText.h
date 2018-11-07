//
//  RZRichText.h
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RZRichText : NSObject

@property (nonatomic, assign) BOOL bold;   // 粗体
@property (nonatomic, assign) BOOL italic; // 斜体
@property (nonatomic, assign) BOOL underLine; // 下划线
@property (nonatomic, assign) BOOL strikethrough; // 删除线
@property (nonatomic, assign) NSInteger fontSize; // 字体
@property (nonatomic, strong) UIColor *textColor; // 字体颜色
@property (nonatomic, assign) NSTextAlignment aligment; // 对齐
// 将文字按照配置的样式变成富文本
- (NSAttributedString *)rz_factoryByString:(NSString *)text;


@end

@interface RZRichText (HtmlHelper)
/**
 获取富文本中的的所有图片
 
 @return 按照图片插入顺序排列
 */
+ (NSArray <UIImage *> *)rz_richTextImagesFormAttributed:(NSAttributedString *)attr;
/**
 将富文本转成HTML标签
 
 @param attr 富文本
 @param urls 富文本中的图片的url，如果有则传
 @return html标签语言
 */
+ (NSString *)rz_htmlFactoryByAttributedString:(NSAttributedString *)attr imageURLSIfHad:(NSArray <NSString *> *)urls;
@end
