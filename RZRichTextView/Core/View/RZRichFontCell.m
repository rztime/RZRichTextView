//
//  RZRichFontCell.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichFontCell.h"

@implementation RZRichFontCell

- (void)setViewModel:(RZRichTextViewModel *)viewModel {
    [super setViewModel:viewModel];
    __weak typeof(self) weakSelf = self;
    [self.textLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text(@"T").font(RZFontNormal(16)).textColor(krz_rich_theme_color);
        confer.text([NSString stringWithFormat:@"%ld", weakSelf.viewModel.textModel.fontSize]).font(RZFontNormal(12)).textColor(krz_rich_theme_color);
    }];
}
- (void)viewDidClicked {
    
}
@end
