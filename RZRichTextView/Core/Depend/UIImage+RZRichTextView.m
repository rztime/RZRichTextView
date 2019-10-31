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
    NSURL *url = [bundle URLForResource:@"RZRichResource" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

@end

@implementation UIImage (RZRichTextView)

+ (UIImage *)rz_imageName:(NSString *)name {
    NSBundle *imageBundle = [NSBundle rz_mainBundle];
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end
