//
//  RZAttributedMaker.m
//  RZAttributedStringText
//
//  Created by 乄若醉灬 on 2017/7/21.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import "RZColorfulConferrer.h"
#import "NSAttributedString+RZColorful.h"
#import <CoreGraphics/CGBase.h>

#define rzColorPlainText        @"rzColorPlainText"  // 普通文本
#define rzColorImageText        @"rzColorImageText"  // 图片文本
#define rzColorHTMLText         @"rzColorHTMLText"    // 网页文本
#define rzColorImageUrlText     @"rzColorImageUrlText"  // 只有url的图片

typedef NS_ENUM(NSInteger, RZColorfulAttributeBoxType) {
    RZColorfulAttributeBoxTypePlainText,
    RZColorfulAttributeBoxTypeImage,
    RZColorfulAttributeBoxTypeHTMLText,
    RZColorfulAttributeBoxTypeImageURL,
};

@interface RZColorfulAttributeBox : NSObject

@property (nonatomic, assign) RZColorfulAttributeBoxType type;
@property (nonatomic, copy)   NSString *text;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) RZImageAttachment *attach;
@property (nonatomic, strong) RZColorfulAttribute *attribute;

@end

@implementation RZColorfulAttributeBox

@end

RZColorfulAttributeBox *RZ_ATTRIBUTEBOXBY(id content, RZColorfulAttributeBoxType type) {
    RZColorfulAttributeBox *box = [RZColorfulAttributeBox new];
    box.type = type;
    if (type == RZColorfulAttributeBoxTypePlainText || type == RZColorfulAttributeBoxTypeHTMLText) {
        box.attribute = [[RZColorfulAttribute alloc] init];
    } else {
        box.attach = [[RZImageAttachment alloc] init];
    }
    if ([content isKindOfClass:[NSString class]]) {
        box.text = content;
    } else if ([content isKindOfClass:[UIImage class]]) {
        box.image = content;
    }
    return box;
}

@interface RZColorfulConferrer()

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) RZParagraphStyle *paragraphStyle;
@property (nonatomic, strong) RZShadow       *shadow;
@end

@implementation RZColorfulConferrer

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (NSAttributedString *)confer {
     NSMutableAttributedString *string = [[NSMutableAttributedString alloc]init];
    for (RZColorfulAttributeBox *box in self.contents) {
        switch (box.type) {
            case RZColorfulAttributeBoxTypePlainText: {
                NSMutableDictionary *attr = [box.attribute code].mutableCopy;
                if (_shadow && !box.attribute.hadShadow) {
                    [attr setObject:[_shadow code] forKey:NSShadowAttributeName];
                }
                if (_paragraphStyle && !box.attribute.hadParagraphStyle) {
                    [attr setObject:[_paragraphStyle code] forKey:NSParagraphStyleAttributeName];
                }
                NSAttributedString *text = [[NSAttributedString alloc] initWithString:box.text attributes:attr];
                [string appendAttributedString:text];
                break;
            }
            case RZColorfulAttributeBoxTypeImage: {
                NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
                attchment.image = box.image;
                attchment.bounds = box.attach.imageBounds;
                NSMutableAttributedString *imageString = [NSMutableAttributedString attributedStringWithAttachment:attchment].mutableCopy;
                NSMutableDictionary *dict = [box.attach code].mutableCopy;
                if (_paragraphStyle && !box.attach.hadParagraphStyle) {
                    dict[NSParagraphStyleAttributeName] = [_paragraphStyle code];
                }
                if (_shadow && !box.attach.hadShadow) {
                    dict[NSShadowAttributeName] = [_shadow code];
                }
                [imageString addAttributes:dict range:NSMakeRange(0, imageString.length)];
                [string appendAttributedString:imageString];
                break;
            }
            case RZColorfulAttributeBoxTypeHTMLText: {
                NSMutableAttributedString *html = [NSAttributedString htmlString:box.text].mutableCopy;
                NSMutableDictionary *attr = [box.attribute code].mutableCopy;
                if (_shadow && !box.attribute.hadShadow) {
                    attr[NSShadowAttributeName] = [_shadow code];
                }
                if (_paragraphStyle && !box.attribute.hadParagraphStyle) {
                    attr[NSParagraphStyleAttributeName] = [_paragraphStyle code];   
                }
                [html addAttributes:attr range:NSMakeRange(0, html.length)];
                [string appendAttributedString:html];
                break;
            }
            case RZColorfulAttributeBoxTypeImageURL: {
                NSString *html = [box.attach toHTMLStringWithImageUrl:box.text];
                NSMutableAttributedString *imageString = [NSAttributedString htmlString:html].mutableCopy;
                NSMutableDictionary *dict = [box.attach code].mutableCopy;
                if (_paragraphStyle && !box.attach.hadParagraphStyle) {
                    dict[NSParagraphStyleAttributeName] = [_paragraphStyle code];
                }
                if (_shadow && !box.attach.hadShadow) {
                    dict[NSShadowAttributeName] = [_shadow code];
                }
                [imageString addAttributes:dict range:NSMakeRange(0, imageString.length)];
                [string appendAttributedString:imageString];
                break;
            }
            default:
                break;
        }
    }
    return string.copy;
}

- (RZColorfulAttribute *(^)(NSString *text))text{
    __weak typeof(self) weakSelf = self;
    return ^id(NSString *text) {
        if (!text) {
            text = @"";
        }
        RZColorfulAttributeBox *box = RZ_ATTRIBUTEBOXBY(text, RZColorfulAttributeBoxTypePlainText);
        [weakSelf.contents addObject:box];
        return box.attribute;
    };
}

/**
 添加html格式的内容
 */
- (RZColorfulAttribute *(^)(NSString *htmlText))htmlText {
    __weak typeof(self) weakSelf = self;
    return ^id (NSString *htmlText) {
        if (!htmlText) {
            htmlText = @"";
        }
        RZColorfulAttributeBox *box = RZ_ATTRIBUTEBOXBY(htmlText, RZColorfulAttributeBoxTypeHTMLText);
        [weakSelf.contents addObject:box];
        return box.attribute;
    };
}

- (RZImageAttachment *(^)(UIImage *appendImage))appendImage {
    __weak typeof(self) weakSelf = self;
    return ^id (UIImage *appendImage){
        if (!appendImage) {
            appendImage = [[UIImage alloc] init];
        }
        RZColorfulAttributeBox *box = RZ_ATTRIBUTEBOXBY(appendImage, RZColorfulAttributeBoxTypeImage);
        [weakSelf.contents addObject:box];
        return box.attach;
    };
}

/**
 通过url添加图片
 */
- (RZImageAttachment *(^)(NSString * _Nullable imageUrl))appendImageByUrl {
    __weak typeof(self) weakSelf = self;
    return ^id (NSString *imageUrl){
        if (!imageUrl) {
            imageUrl = @"";
        }
        RZColorfulAttributeBox *box = RZ_ATTRIBUTEBOXBY(imageUrl, RZColorfulAttributeBoxTypeImageURL);
        [weakSelf.contents addObject:box];
        return box.attach;
    };
}

/**
 设置当前控件对象统一段落样式
 */
- (RZParagraphStyle * _Nullable)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[RZParagraphStyle alloc] init];
    }
    return _paragraphStyle;
}


/**
 设置统一阴影对象

 @return <#return value description#>
 */
- (RZShadow * _Nullable)shadow {
    if (!_shadow) {
        _shadow = [[RZShadow alloc] init];
    }
    return _shadow;
}

- (NSMutableArray *)contents {
    if (!_contents) {
        _contents = [NSMutableArray new];
    }
    return _contents;
}
#pragma clang diagnostic pop
@end
