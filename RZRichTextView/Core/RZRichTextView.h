//
//  RZRichTextView.h
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  请勿对RZRichTextView的delegate替换赋值
 */
@interface RZRichTextView : UITextView

/**
 文字改变之后的回调
 */
@property (nonatomic, copy) void(^didChanegdText)(RZRichTextView *textView);
/**
 获取输入框中的所有图片

 @return 按照图片插入顺序排列
 */
- (NSArray <UIImage *> *)rz_richTextImages;

/**
 将富文本内容转换成HTML标签语言 urls需与图片顺序、数量一致（倒叙方式插入，缺失可能导致图片顺序不准确）

 @param urls 图片的链接，如果有图片，则请将图片先上传至自己的服务器中，得到地址。然后在转换成HTML时，urls图片顺序将与[- (NSArray <UIImage *> *)rz_rictTextImages]方法得到的图片顺序一致
 @return HTML标签string。
 */
- (NSString *)rz_codingToHtmlWithImageURLS:(NSArray <NSString *> *)urls;
@end
