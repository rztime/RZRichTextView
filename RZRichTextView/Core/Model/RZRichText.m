//
//  RZRichText.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichText.h"
#import <RZColorful/RZColorful.h>
#import "RZDefine.h" 

@interface RZRichText()

@property (nonatomic, strong) NSDictionary<NSAttributedStringKey,id> *attrs;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSString *text;

@end

@implementation RZRichText


- (instancetype)init {
    if (self = [super init]) {
        _fontSize = 15;
        _textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _aligment = NSTextAlignmentLeft;
    }
    return self;
}

- (NSAttributedString *)rz_factoryByString:(NSString *)text {
    if (text.length == 0) {
        return nil;
    }
    kWeakSelf;
    NSAttributedString *attr = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer *confer) {
        confer.text(text).font(weakSelf.bold? RZFontBold(weakSelf.fontSize): RZFontNormal(weakSelf.fontSize)).textColor(weakSelf.textColor).italic(weakSelf.italic?@0.3:@0).underLineStyle(weakSelf.underLine?1:0).underLineColor(weakSelf.textColor).strikeThrough(weakSelf.strikethrough?1:0).strikeThroughColor(weakSelf.textColor).paragraphStyle.alignment(weakSelf.aligment);
    }];
    return attr.copy;
}

@end
