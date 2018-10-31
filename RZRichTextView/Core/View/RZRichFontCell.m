//
//  RZRichFontCell.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichFontCell.h"
#import "RZFontConfigureView.h"


@implementation RZRichFontCell

- (void)setViewModel:(RZRichTextViewModel *)viewModel {
    [super setViewModel:viewModel];
    [self setUI];
}
- (void)viewDidClicked {
    UIWindow * window= [UIApplication sharedApplication].keyWindow;
    CGRect selfRect= [self convertRect: self.bounds toView:window];

    if (self.viewModel.rz_showFontView) {
        self.viewModel.rz_showFontView(selfRect.origin.x, NO);
    }
}

- (void)setUI {
    __weak typeof(self) weakSelf = self;
    [self.textLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text(@"T").font(RZFontNormal(16)).textColor(weakSelf.viewModel.textModel.textColor).strokeWidth(@(-0.1)).strokeColor(rgb(225, 225, 225));
        confer.text([NSString stringWithFormat:@"%ld", (long)weakSelf.viewModel.textModel.fontSize]).font(RZFontNormal(12)).textColor(weakSelf.viewModel.textModel.textColor).strokeWidth(@(-1)).strokeColor(rgb(225, 225, 225));
    }];
}

@end
