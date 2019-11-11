//
//  RZRichTextView.h
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextView+RZRichText.h"
#import "RZRichTextAttributeItem.h"
#import <RZColorful/RZColorful.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import "RZRichTextConfigureManager.h"
#import "UIColor+RZDarkMode.h"
#import "NSString+RZCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZRichTextView : UITextView
/**
 在光标位置处的富文本属性
 */
@property (nonatomic, strong) NSMutableDictionary <NSAttributedStringKey, id> *rz_attributedDictionays;

#pragma mark - 键盘上的工具条信息
/**
 键盘上的工具条功能（可新增、删除、交换位置）
 */
@property (nonatomic, strong) NSMutableArray <RZRichTextAttributeItem *> *rz_attributeItems;

/** 根据item，可自定义键盘工具栏的功能cell 不需要自定义时，return nil; （在工具条刷新的时候会调用）这里会覆盖[RZRichTextConfigureManager]中的方法*/
@property (nonatomic, copy) UICollectionViewCell *(^cellForItemAtIndePath)(UICollectionView *collectionView, NSIndexPath *indexPath, RZRichTextAttributeItem *item);
/** 点击了某个功能， 需要自定义处理时，返回YES ,在自定义处理完成之后，请调用[rz_reloadAttributeData]刷新工具条内容的状态*/
@property (nonatomic, copy) BOOL(^didClickedCell)(RZRichTextView *textView, RZRichTextAttributeItem *item);

/**
 刷新工具条的cell
 */
- (void)rz_reloadAttributeData;


/**
 最大输入记录 默认20  （即可撤回20步以内的数据输入）
 */
@property (nonatomic, assign) NSUInteger rz_maxrevoke;


/** 实现此block，可以对将要插入的图片进行处理 */
@property (nonatomic, copy) UIImage * __nullable (^rz_shouldInserImage)(UIImage * __nullable image);

/**
 手动插入图片
 */
- (void)insertImage:(UIImage *)image;

/**
 文字改变之后的回调
 */
@property (nonatomic, copy) void(^rz_didChangedText)(RZRichTextView *textView);

/**
 获取输入框中的所有图片
 
 @return 按照图片插入顺序排列
 */
- (NSArray <UIImage *> *)rz_richTextImages;

/**
 将富文本内容转换成HTML标签语言
 @param urls 图片的链接，如果有图片，则请将图片先上传至自己的服务器中，得到地址。然后在转换成HTML时，urls图片顺序将与[- (NSArray <UIImage *> *)rz_rictTextImages]方法得到的图片顺序一致 倒叙方式插入，缺失可能导致图片顺序不准确）
 @return HTML标签string。
 */
- (NSString *)rz_codingToHtmlWithImageURLS:(NSArray <NSString *> *)urls;

#pragma mark - delegate 富文本的delegate请替换成block形式
@property (nonatomic, copy) BOOL (^rz_textViewShouldBeginEditing)(RZRichTextView *textView);
@property (nonatomic, copy) BOOL (^rz_textViewShouldEndEditing)(RZRichTextView *textView);

@property (nonatomic, copy) void (^rz_textViewDidBeginEditing)(RZRichTextView *textView);
@property (nonatomic, copy) void (^rz_textViewDidEndEditing)(RZRichTextView *textView);

@property (nonatomic, copy) BOOL (^rz_shouldChangeTextInRange)(RZRichTextView *textView, NSRange inRange, NSString *replacementText);

@property (nonatomic, copy) void (^rz_textViewDidChange)(RZRichTextView *textView) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "Use rz_didChangedText instead");


@property (nonatomic, copy) void (^rz_textViewDidChangeSelection)(RZRichTextView *textView);

@property (nonatomic, copy) BOOL (^rz_shouldInteractWithURL)(RZRichTextView *textView, NSURL *url, NSRange inRange, UITextItemInteraction interaction) NS_AVAILABLE_IOS(10_0);

@property (nonatomic, copy) BOOL (^rz_shouldInteractWithTextAttachment)(RZRichTextView *textView, NSTextAttachment *textAttachment, NSRange inRange, UITextItemInteraction interaction) NS_AVAILABLE_IOS(10_0);

@property (nonatomic, copy) BOOL (^rz_shouldInteractWithURL_ios7)(RZRichTextView *textView, NSURL *url, NSRange inRange) NS_DEPRECATED_IOS(7_0, 10_0, "Use shouldInteractWithURL instead");

@property (nonatomic, copy) BOOL (^rz_shouldInteractWithTextAttachment_ios7)(RZRichTextView *textView, NSTextAttachment *textAttachment, NSRange inRange) NS_DEPRECATED_IOS(7_0, 10_0, "Use shouldInteractWithTextAttachment instead");
@end

NS_ASSUME_NONNULL_END
