//
//  UIImage+RZRichTextView.h
//  RZRichTextView
//
//  Created by xk_mac_mini on 2019/10/31.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NSBundle (TZImagePicker)


@end

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (RZRichTextView)

+ (UIImage *)rz_imageName:(NSString *)name;

@end

BOOL rz_iPhone_liuhai_adj(void);
CGFloat rz_kSafeBottomMargin_adj(void);

NS_ASSUME_NONNULL_END
