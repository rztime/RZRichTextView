//
//  RZRichBoldCell.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichBoldCell.h"

@implementation RZRichBoldCell

- (void)setViewModel:(RZRichTextViewModel *)viewModel {
    [super setViewModel:viewModel];
    __weak typeof(self) weakSelf = self;
    [self.textLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        if (weakSelf.viewModel.textModel.bold) {
            confer.text(@"B").font(RZFontBold(16)).textColor(krz_rich_theme_color);
        } else {
            confer.text(@"B").font(RZFontNormal(15)).textColor(krz_rich_defult_color);
        }
    }];
}
- (void)viewDidClicked {
    self.viewModel.textModel.bold = !self.viewModel.textModel.bold;
    if (self.viewModel.rz_changeRich) {
        self.viewModel.rz_changeRich(YES);
    }
}

@end
