//
//  RZRichTextAttributeItem.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/21.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RZRichTextConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZRichTextAttributeItem : NSObject

@property (nonatomic, assign) RZRichTextAttributeType type;

@property (nonatomic, strong, nullable) UIImage *defaultImage;

@property (nonatomic, assign) BOOL highlight;  // 是否高亮
@property (nonatomic, strong, nullable) UIImage *highlightImage;

/**
 自定义的信息 当item以上信息不能满足时，可以通过字典来保存你需要的数据
 */
@property (nonatomic, strong) NSMutableDictionary *exParams;

+ (instancetype)initWithType:(RZRichTextAttributeType)type defaultImage:(UIImage * __nullable)image1 highlightImage:(UIImage * __nullable)image2 highlight:(BOOL)highlight;


/**
 显示的图片，如果高亮，则返回 highlightImage 
 */
- (UIImage *)displayImage;

@end

NS_ASSUME_NONNULL_END
