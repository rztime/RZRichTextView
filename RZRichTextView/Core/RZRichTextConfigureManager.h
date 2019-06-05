//
//  RZRichTextConfigureManager.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/21.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZRichTextAttributeItem.h"

NS_ASSUME_NONNULL_BEGIN

@class RZRichTextView;

@interface RZRichTextConfigureManager : NSObject

@property (nonatomic, strong) UIColor *themeColor;  // 主题色
@property (nonatomic, strong) UIImage *sliderImage;  // 滑块图片

/** 单例  */
+ (instancetype)manager;

#pragma mark - 自定义键盘上的工具栏的cell相关信息
/** 键盘上的工具条功能数组，可新增、删除、交换位置
    如果要添加自定义的功能，添加的RZRichTextAttributeType 请尽量从100以后添加，
 */
@property (nonatomic, copy) NSMutableArray <RZRichTextAttributeItem *> *rz_attributeItems;
/**此为Get方法， 注册的键盘上的工具条的cell  <cell的identifier， cell的类>
 注册时，请用下边的[registerRZRichTextAttributeItemClass:forAccessoryItemCellWithIdentifier]方法*/
- (NSMutableDictionary <NSString *, id> *)registerCells;
/** 自定义 注册的键盘上的工具条的cell */
- (void)registerRZRichTextAttributeItemClass:(Class)classNa forAccessoryItemCellWithIdentifier:(NSString *)identifier;
/** 根据item，可自定义键盘工具栏的功能cell 不需要自定义时，return nil; （在工具条刷新的时候会调用）*/
@property (nonatomic, copy) UICollectionViewCell *(^cellForItemAtIndePath)(UICollectionView *collectionView, NSIndexPath *indexPath, RZRichTextAttributeItem *item);

/** 点击了某个功能， 需要自定义处理时，返回YES*/
@property (nonatomic, copy) BOOL(^didClickedCell)(RZRichTextView *textView, RZRichTextAttributeItem *item);

#pragma mark - 全局的对富文本将要插入的图片进行的处理的方法
/** 实现此block，可以对将要插入的图片进行处理 */
@property (nonatomic, copy) UIImage * __nullable (^rz_shouldInserImage)(UIImage * __nullable image);

#pragma mark - 其他方法
// 获取当前屏幕最顶层的viewcontroller
+ (UIViewController *)rz_currentViewController;
// 模态弹出框，背景将显示出来
+ (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@interface NSArray (RZSafe)

- (id __nullable)rz_safeObjAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
