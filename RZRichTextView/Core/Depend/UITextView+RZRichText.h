//
//  UITextView+RZRichText.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/29.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (RZRichText)

/**
 当前光标所在位置的富文本属性

 @return <#return value description#>
 */
- (NSDictionary <NSAttributedStringKey, id> *)rz_attributesAtSelectedRange;

/**
 所有的url相关的
 */
- (NSArray < NSDictionary <NSAttributedString *, id> *> *)rz_allUrlAttributedString;

@end

NS_ASSUME_NONNULL_END
