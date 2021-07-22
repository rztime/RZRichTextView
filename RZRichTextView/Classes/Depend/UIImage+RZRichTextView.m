//
//  UIImage+RZRichTextView.m
//  RZRichTextView
//
//  Created by xk_mac_mini on 2019/10/31.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "UIImage+RZRichTextView.h"
#import "RZRichTextView.h"

@implementation NSBundle (RZRichTextView)

+ (NSBundle *)rz_mainBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[RZRichTextView class]];
    NSURL *url = [bundle URLForResource:@"RZRichTextView" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

@end

@implementation UIImage (RZRichTextView)

+ (UIImage *)rz_imageName:(NSString *)name {
    NSBundle *imageBundle = [NSBundle rz_mainBundle];
    NSString *fileName = [NSString stringWithFormat:@"%@@2x", name];
    NSString *imagePath = [imageBundle pathForResource:fileName ofType:@"png"];
    if (imagePath == nil) {
        fileName = [NSString stringWithFormat:@"RZRichTextView.bundle/%@@2x", name];
        imagePath = [imageBundle pathForResource:fileName ofType:@"png"];
    }
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end
BOOL rz_iPhone_liuhai_adj(void) {
    if (@available(iOS 11.0, *)) {
        CGFloat height = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        return (height > 0);
    } else {
        return NO;
    }
}

CGFloat rz_kSafeBottomMargin_adj(void) {
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
    } else {
        return 0;
    }
}
