//
//  RZShadow.m
//  RZColorfulExample
//
//  Created by 乄若醉灬 on 2017/7/28.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import "RZShadow.h"
#import "RZColorfulAttribute.h"

@interface RZShadow ()

@property (nonatomic, strong) NSShadow *shadow;

@end

@implementation RZShadow

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


- (RZColorfulAttribute *)and {
    return _colorfulsAttr;
}
- (RZColorfulAttribute *)with {
    return _colorfulsAttr;
}
- (RZColorfulAttribute *)end {
    return _colorfulsAttr;
}

- (RZImageAttachment *)andAttach {
    return _imageAttach;
}
- (RZImageAttachment *)withAttach {
    return _imageAttach;
}
- (RZImageAttachment *)endAttach {
    return _imageAttach;
}

- (NSShadow *)code {
    return _shadow;
}

- (NSShadow *)shadow {
    if (!_shadow) {
        _shadow = [[NSShadow alloc] init];
    }
    return _shadow;
}

- (RZShadow *(^)(CGSize offSet))offset {
    __weak typeof(self)weakSelf = self;
    return ^id (CGSize offset) {
        weakSelf.shadow.shadowOffset = offset;
        return weakSelf;
    };
}

- (RZShadow *(^)(CGFloat radius))radius {
    __weak typeof(self)weakSelf = self;
    return ^id (CGFloat radius) {
        weakSelf.shadow.shadowBlurRadius = radius;
        return weakSelf;
    };
}

- (RZShadow *(^)(UIColor *color))color {
    __weak typeof(self)weakSelf = self;
    return ^id (UIColor *color) {
        weakSelf.shadow.shadowColor = color;
        return weakSelf;
    };
}
#pragma clang diagnostic pop
@end
