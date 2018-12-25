//
//  RZRichTextViewModel.h
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZRichTextContent.h"

#define rz_rich_image(name) [UIImage imageNamed:[NSString stringWithFormat:@"RZRichResource.bundle/%@", name]]

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kgray RGBA(102,102,102,1)
#define kblue RGBA(37,119,239,1)

#define kRZScreenWidth [UIScreen mainScreen].bounds.size.width

NS_ASSUME_NONNULL_BEGIN

@interface RZRichTextViewModel : NSObject

@property (nonatomic, strong) RZRichTextContent *content;
/**
 RZRichTextFunc
 */
@property (nonatomic, strong) NSArray *editBarSource;
// 撤销的数组
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *historyText;
// 撤销的数组
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *reagainHistoryText;
@property (nonatomic, assign) RZRichTextFunc showFunc;

- (NSAttributedString *)contentByFunc:(RZRichTextFunc)func;

#pragma mark - eidtBar的事件处理
// 需要处理的特殊功能，如 添加图片，撤销，恢复
@property (nonatomic, copy) void(^rz_didhandleExFunc)(RZRichTextFunc func, id __nullable obj);

@property (nonatomic, copy) void(^rz_didEditBarClicked)(RZRichTextFunc func);
//
@property (nonatomic, copy) void(^rz_valueChangedRefreshEditBar)(BOOL refresh);

@property (nonatomic, copy) void(^rz_didEditBarclickedShowExView)(UIView *view);

@end

NS_ASSUME_NONNULL_END
