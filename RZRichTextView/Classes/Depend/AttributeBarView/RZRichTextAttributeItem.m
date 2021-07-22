//
//  RZRichTextAttributeItem.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/21.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRichTextAttributeItem.h"

@implementation RZRichTextAttributeItem

+ (instancetype)initWithType:(RZRichTextAttributeType)type defaultImage:(UIImage *)image1 highlightImage:(UIImage *)image2 highlight:(BOOL)highlight {
    RZRichTextAttributeItem *item = [[RZRichTextAttributeItem alloc] init];
    item.type = type;
    item.defaultImage = image1;
    item.highlightImage = image2;
    item.highlight = highlight;
    return item;
}

- (NSMutableDictionary *)exParams {
    if (!_exParams) {
        _exParams = [NSMutableDictionary new];
    }
    return _exParams;
}

- (UIImage *)displayImage {
    UIImage *image;
    if (self.highlight) {
        image = self.highlightImage;
    }
    if (!image) {
        image = self.defaultImage;
    }
    return image;
}
@end
