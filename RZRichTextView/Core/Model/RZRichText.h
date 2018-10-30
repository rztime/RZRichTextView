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

- (NSAttributedString *)rz_factoryByString:(NSString *)text;

@end
