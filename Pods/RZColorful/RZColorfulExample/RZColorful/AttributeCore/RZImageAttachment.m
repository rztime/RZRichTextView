//
//  RZImageAttachment.m
//  RZColorfulExample
//
//  Created by 乄若醉灬 on 2017/7/28.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import "RZImageAttachment.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface RZImageAttachment ()

/** 设置段落样式  */
@property (nonatomic, strong) RZParagraphStyle *paragraphStyle;
/** 阴影 */
@property (nonatomic, strong) RZShadow *shadow;

@property (nonatomic, strong) NSURL *URL;
@end

@implementation RZImageAttachment

- (NSDictionary *)code {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (_hadParagraphStyle) {
        dict[NSParagraphStyleAttributeName] = [_paragraphStyle code];
    }
    if (_hadShadow) {
        dict[NSShadowAttributeName] = [_shadow code];
    }
    if (_URL) {
        dict[NSLinkAttributeName] = _URL;
    }
    return dict;
}

- (RZImageAttachment *(^)(CGRect bounds))bounds {
    __weak typeof(self)weakSelf = self;
    return ^id (CGRect bounds) {
        weakSelf.imageBounds = bounds;
        return weakSelf;
    };
}

/**
 设置点击
 */
- (RZImageAttachment *(^)(NSURL *url))url {
    __weak typeof(self)weakSelf = self;
    return ^id (NSURL *url) {
        weakSelf.URL = url;
        return weakSelf;
    };
}

/**
 将bounds数据转换成html格式的语句
 
 @param imageUrl 图片url
 @return <#return value description#>
 */
- (NSString *)toHTMLStringWithImageUrl:(NSString *)imageUrl {
    NSString *width = @"";
    NSString *height = @"";
    if (_imageBounds.size.width > 0) {
        width = [NSString stringWithFormat:@"width:%fpx;", _imageBounds.size.width];
    }
    if (_imageBounds.size.height > 0) {
        height = [NSString stringWithFormat:@"height:%fpx;", _imageBounds.size.height];
    }
    NSString *html = [NSString stringWithFormat:@"<img style=\"%@%@\" src=\"%@\"/>", width, height, imageUrl];
    return html;
}

/**
 段落样式，具体设置请看 RZParagraphStyle.h
 
 @return <#return value description#>
 */
- (RZParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[RZParagraphStyle alloc] init];
        _paragraphStyle.imageAttach = self;
        _hadParagraphStyle = YES;
    }
    return _paragraphStyle;
}

- (RZShadow *)shadow {
    if (!_shadow) {
        _shadow = [[RZShadow alloc] init];
        _shadow.imageAttach = self;
        _hadShadow = YES;
    }
    return _shadow;
}
#pragma clang diagnostic pop
@end
