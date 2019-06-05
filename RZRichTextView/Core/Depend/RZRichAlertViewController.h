//
//  RZRichAlertViewController.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/6/3.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZRichAlertViewController : UIViewController

- (instancetype)init NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "请使用initWithType:方法初始化");

- (instancetype)initWithType:(RZRichAlertViewType)type;

- (instancetype)initWithType:(RZRichAlertViewType)type title:(NSString * __nullable)title;

/**
 以字典的形式传入标题和图片，
 key的值可以随意传（key值不重要）,
 string类型的value将被作为文字显示，
 UIImage类型的value将被作为图片显示
 UIColor类型的vaule将被作为文字显示的颜色（不传则为默认颜色）
 如：titles : NSDictionary {@"title": @"我的标题" , @"image":[UIImage], @"textColor":[UIColor]}
 */
@property (nonatomic, strong) NSArray <NSDictionary *> *titles;

/**
 是否显示取消按钮 默认YES：显示
 */
@property (nonatomic, assign) BOOL showCancelButton;

/**
 选择结束之后的回调，isCancel为YES时，表示取消，或者index为NSNotFound时表示取消
 */
@property (nonatomic, copy) void(^didSelected)(NSUInteger index, BOOL isCancel);

// 高亮显示的index
@property (nonatomic, assign) NSInteger highLightIndex;
// 高亮显示的文字颜色，默认主题蓝色
@property (nonatomic, strong) UIColor *highLightTextColor;
// 标题
@property (nonatomic, copy) NSString *titleString;

- (void)show;

@end

NS_ASSUME_NONNULL_END
