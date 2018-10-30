//
//  RZRichItalicCell.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichItalicCell.h"

@implementation RZRichItalicCell

- (void)setViewModel:(RZRichTextViewModel *)viewModel {
    [super setViewModel:viewModel];
    __weak typeof(self) weakSelf = self;
    [self.textLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        if (weakSelf.viewModel.textModel.italic) {
            confer.text(@"I").font(RZFontNormal(16)).textColor(krz_rich_theme_color).italic(@0.3);
        } else {
            confer.text(@"I").font(RZFontNormal(15)).textColor(krz_rich_defult_color).italic(@0.3);
        }
    }];
}
- (void)viewDidClicked {
    self.viewModel.textModel.italic = !self.viewModel.textModel.italic;
    if (self.viewModel.rz_changeRich) {
        self.viewModel.rz_changeRich(YES);
    }
}
@end
